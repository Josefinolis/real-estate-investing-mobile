import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_config.dart';
import 'config/routes.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/property_repository.dart';
import 'data/repositories/alert_repository.dart';
import 'data/repositories/favorite_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/notification_service.dart';
import 'bloc/auth/auth_bloc.dart';

void main() async {
  debugPrint('🚀 [MAIN] App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 [MAIN] WidgetsFlutterBinding initialized');

  // Initialize Firebase (optional - app works without it in demo mode)
  bool firebaseAvailable = false;
  try {
    debugPrint('🚀 [MAIN] Initializing Firebase...');
    await Firebase.initializeApp();
    firebaseAvailable = true;
    debugPrint('🚀 [MAIN] Firebase initialized successfully');
  } catch (e) {
    debugPrint('🚀 [MAIN] Firebase not available: $e');
  }

  // Initialize services
  debugPrint('🚀 [MAIN] Creating ApiService...');
  final apiService = ApiService(baseUrl: AppConfig.apiBaseUrl);
  final notificationService = NotificationService();

  try {
    debugPrint('🚀 [MAIN] Initializing NotificationService...');
    await notificationService.initialize();
    debugPrint('🚀 [MAIN] NotificationService initialized');
  } catch (e) {
    debugPrint('🚀 [MAIN] Notification service not available: $e');
  }

  // Initialize repositories
  debugPrint('🚀 [MAIN] Creating repositories...');
  final authRepository = AuthRepository(
    apiService: apiService,
    firebaseAvailable: firebaseAvailable,
  );
  final propertyRepository = PropertyRepository(apiService: apiService);
  final alertRepository = AlertRepository(apiService: apiService);
  final favoriteRepository = FavoriteRepository(apiService: apiService);

  // Initialize AuthBloc before creating the router
  debugPrint('🚀 [MAIN] Creating AuthBloc...');
  final authBloc = AuthBloc(
    authRepository: authRepository,
    notificationService: notificationService,
    firebaseAvailable: firebaseAvailable,
  )..add(AuthCheckRequested());
  debugPrint('🚀 [MAIN] AuthBloc created, AuthCheckRequested added');

  // Create router with AuthBloc
  debugPrint('🚀 [MAIN] Creating AppRouter...');
  final appRouter = AppRouter(authBloc: authBloc);
  debugPrint('🚀 [MAIN] AppRouter created');

  debugPrint('🚀 [MAIN] Calling runApp...');
  runApp(
    MyApp(
      authBloc: authBloc,
      appRouter: appRouter,
      authRepository: authRepository,
      propertyRepository: propertyRepository,
      alertRepository: alertRepository,
      favoriteRepository: favoriteRepository,
      notificationService: notificationService,
    ),
  );
  debugPrint('🚀 [MAIN] runApp called');
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AppRouter appRouter;
  final AuthRepository authRepository;
  final PropertyRepository propertyRepository;
  final AlertRepository alertRepository;
  final FavoriteRepository favoriteRepository;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.authBloc,
    required this.appRouter,
    required this.authRepository,
    required this.propertyRepository,
    required this.alertRepository,
    required this.favoriteRepository,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 [MYAPP] Building MyApp widget...');
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: propertyRepository),
        RepositoryProvider.value(value: alertRepository),
        RepositoryProvider.value(value: favoriteRepository),
        RepositoryProvider.value(value: notificationService),
      ],
      child: BlocProvider.value(
        value: authBloc,
        child: MaterialApp.router(
          title: 'Real State Investing',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E88E5),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E88E5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          routerConfig: appRouter.router,
        ),
      ),
    );
  }
}
