import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_bloc.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/search_screen.dart';
import '../ui/screens/property_detail_screen.dart';
import '../ui/screens/alerts_screen.dart';
import '../ui/screens/favorites_screen.dart';
import '../ui/screens/splash_screen.dart';
import '../data/models/search_filter.dart';
import '../data/models/property.dart';

/// Converts a Stream into a Listenable for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    debugPrint('🛣️ [ROUTER] GoRouterRefreshStream created');
    _subscription = stream.listen((event) {
      debugPrint('🛣️ [ROUTER] Stream event received: $event');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  late final GoRouter router;

  AppRouter({required this.authBloc}) {
    debugPrint('🛣️ [ROUTER] AppRouter constructor called');
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoading = authState is AuthInitial || authState is AuthLoading;
        final isLoggedIn = authState is AuthAuthenticated;
        final isOnLoginPage = state.matchedLocation == '/login';
        final isOnSplashPage = state.matchedLocation == '/splash';

        debugPrint('🛣️ [ROUTER] redirect called:');
        debugPrint('🛣️ [ROUTER]   - authState: $authState');
        debugPrint('🛣️ [ROUTER]   - isLoading: $isLoading');
        debugPrint('🛣️ [ROUTER]   - isLoggedIn: $isLoggedIn');
        debugPrint('🛣️ [ROUTER]   - matchedLocation: ${state.matchedLocation}');

        // Show splash screen while checking auth status
        if (isLoading) {
          final redirect = isOnSplashPage ? null : '/splash';
          debugPrint('🛣️ [ROUTER]   -> Redirecting to: $redirect (loading state)');
          return redirect;
        }

        // Not logged in - redirect to login
        if (!isLoggedIn) {
          final redirect = isOnLoginPage ? null : '/login';
          debugPrint('🛣️ [ROUTER]   -> Redirecting to: $redirect (not logged in)');
          return redirect;
        }

        // Logged in - redirect away from login/splash
        if (isLoggedIn && (isOnLoginPage || isOnSplashPage)) {
          debugPrint('🛣️ [ROUTER]   -> Redirecting to: / (logged in, leaving auth pages)');
          return '/';
        }

        debugPrint('🛣️ [ROUTER]   -> No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) {
            debugPrint('🛣️ [ROUTER] Building SplashScreen');
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            debugPrint('🛣️ [ROUTER] Building LoginScreen');
            return const LoginScreen();
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            debugPrint('🛣️ [ROUTER] Building MainShell');
            return MainShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) {
                debugPrint('🛣️ [ROUTER] Building HomeScreen');
                return const HomeScreen();
              },
            ),
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) {
                final queryParams = state.uri.queryParameters;
                final filter = SearchFilter(
                  city: queryParams['city'],
                  postalCode: queryParams['postalCode'],
                  operationType: _parseOperationType(queryParams['operation']),
                  propertyType: _parsePropertyType(queryParams['propertyType']),
                  minPrice: double.tryParse(queryParams['minPrice'] ?? ''),
                  maxPrice: double.tryParse(queryParams['maxPrice'] ?? ''),
                  minRooms: int.tryParse(queryParams['minRooms'] ?? ''),
                  minBathrooms: int.tryParse(queryParams['minBathrooms'] ?? ''),
                  minArea: double.tryParse(queryParams['minArea'] ?? ''),
                  maxArea: double.tryParse(queryParams['maxArea'] ?? ''),
                );
                return SearchScreen(initialFilter: filter);
              },
            ),
            GoRoute(
              path: '/property/:id',
              name: 'property',
              builder: (context, state) => PropertyDetailScreen(
                propertyId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: '/alerts',
              name: 'alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    );
    debugPrint('🛣️ [ROUTER] GoRouter created');
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    debugPrint('🛣️ [MAINSHELL] Building MainShell widget');
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('🛣️ [MAINSHELL] AuthState changed: $state');
        if (state is AuthUnauthenticated) {
          debugPrint('🛣️ [MAINSHELL] Navigating to /login');
          context.go('/login');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (index) => _onItemTapped(index, context),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alertas',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search') || location.startsWith('/property')) {
      return 1;
    }
    if (location.startsWith('/alerts')) return 2;
    if (location.startsWith('/favorites')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/alerts');
        break;
      case 3:
        context.go('/favorites');
        break;
    }
  }
}

OperationType? _parseOperationType(String? value) {
  if (value == null) return null;
  switch (value.toUpperCase()) {
    case 'VENTA':
      return OperationType.venta;
    case 'ALQUILER':
      return OperationType.alquiler;
    default:
      return null;
  }
}

PropertyType? _parsePropertyType(String? value) {
  if (value == null) return null;
  switch (value.toUpperCase()) {
    case 'PISO':
      return PropertyType.piso;
    case 'CASA':
      return PropertyType.casa;
    case 'CHALET':
      return PropertyType.chalet;
    case 'ATICO':
      return PropertyType.atico;
    case 'ESTUDIO':
      return PropertyType.estudio;
    default:
      return null;
  }
}
