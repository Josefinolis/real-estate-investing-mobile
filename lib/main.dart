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
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (optional - app works without it in demo mode)
  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } catch (e) {
    debugPrint('Firebase not available: $e');
  }

  // Initialize services
  final apiService = ApiService(baseUrl: AppConfig.apiBaseUrl);
  final notificationService = NotificationService();

  try {
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Notification service not available: $e');
  }

  // Initialize repositories
  final authRepository = AuthRepository(
    apiService: apiService,
    firebaseAvailable: firebaseAvailable,
  );
  final propertyRepository = PropertyRepository(apiService: apiService);
  final alertRepository = AlertRepository(apiService: apiService);
  final favoriteRepository = FavoriteRepository(apiService: apiService);

  runApp(
    MyApp(
      authRepository: authRepository,
      propertyRepository: propertyRepository,
      alertRepository: alertRepository,
      favoriteRepository: favoriteRepository,
      notificationService: notificationService,
      firebaseAvailable: firebaseAvailable,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final PropertyRepository propertyRepository;
  final AlertRepository alertRepository;
  final FavoriteRepository favoriteRepository;
  final NotificationService notificationService;
  final bool firebaseAvailable;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.propertyRepository,
    required this.alertRepository,
    required this.favoriteRepository,
    required this.notificationService,
    required this.firebaseAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: propertyRepository),
        RepositoryProvider.value(value: alertRepository),
        RepositoryProvider.value(value: favoriteRepository),
        RepositoryProvider.value(value: notificationService),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: authRepository,
          notificationService: notificationService,
          firebaseAvailable: firebaseAvailable,
        )..add(AuthCheckRequested()),
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
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
