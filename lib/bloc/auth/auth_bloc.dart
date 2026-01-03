import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/notification_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthDemoModeRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final bool isDemoMode;

  const AuthAuthenticated(this.user, {this.isDemoMode = false});

  @override
  List<Object?> get props => [user, isDemoMode];
}

class AuthUnauthenticated extends AuthState {
  final bool firebaseAvailable;

  const AuthUnauthenticated({this.firebaseAvailable = true});

  @override
  List<Object?> get props => [firebaseAvailable];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final NotificationService _notificationService;
  final bool firebaseAvailable;
  StreamSubscription? _authSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required NotificationService notificationService,
    this.firebaseAvailable = true,
  })  : _authRepository = authRepository,
        _notificationService = notificationService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthDemoModeRequested>(_onDemoModeRequested);

    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null && !_authRepository.isDemoMode) {
        add(AuthCheckRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // If already in demo mode, stay authenticated
    if (_authRepository.isDemoMode) {
      try {
        final user = await _authRepository.getCurrentUser();
        emit(AuthAuthenticated(user, isDemoMode: true));
      } catch (e) {
        emit(AuthUnauthenticated(firebaseAvailable: firebaseAvailable));
      }
      return;
    }

    // If Firebase is not available, go to unauthenticated state
    // User can choose to enter demo mode
    if (!firebaseAvailable) {
      emit(AuthUnauthenticated(firebaseAvailable: false));
      return;
    }

    final firebaseUser = _authRepository.currentUser;

    if (firebaseUser == null) {
      emit(AuthUnauthenticated(firebaseAvailable: firebaseAvailable));
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();
      await _updateFcmToken();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthUnauthenticated(firebaseAvailable: firebaseAvailable));
    }
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signInWithEmail(
        event.email,
        event.password,
      );
      await _updateFcmToken();
      emit(AuthAuthenticated(user, isDemoMode: _authRepository.isDemoMode));
    } catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.signUpWithEmail(
        event.email,
        event.password,
      );
      await _updateFcmToken();
      emit(AuthAuthenticated(user, isDemoMode: _authRepository.isDemoMode));
    } catch (e) {
      emit(AuthError(_mapAuthError(e)));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated(firebaseAvailable: firebaseAvailable));
  }

  Future<void> _onDemoModeRequested(
    AuthDemoModeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authRepository.enterDemoMode();
      emit(AuthAuthenticated(user, isDemoMode: true));
    } catch (e) {
      emit(AuthError('Error al entrar en modo demo'));
    }
  }

  Future<void> _updateFcmToken() async {
    try {
      final token = _notificationService.fcmToken;
      if (token != null) {
        await _authRepository.updateFcmToken(token);
      }
    } catch (e) {
      // Ignore FCM token update failures
    }
  }

  String _mapAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('user-not-found')) {
      return 'Usuario no encontrado';
    } else if (errorString.contains('wrong-password')) {
      return 'Contraseña incorrecta';
    } else if (errorString.contains('email-already-in-use')) {
      return 'El email ya está registrado';
    } else if (errorString.contains('weak-password')) {
      return 'La contraseña es muy débil';
    } else if (errorString.contains('invalid-email')) {
      return 'Email inválido';
    } else if (errorString.contains('network')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Error de autenticación';
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
