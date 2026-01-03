import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final bool firebaseAvailable;

  // Demo mode state
  bool _isDemoMode = false;
  User? _demoUser;
  final _demoAuthController = StreamController<firebase_auth.User?>.broadcast();

  AuthRepository({
    required ApiService apiService,
    firebase_auth.FirebaseAuth? firebaseAuth,
    this.firebaseAvailable = true,
  })  : _apiService = apiService,
        _firebaseAuth = firebaseAvailable
            ? (firebaseAuth ?? firebase_auth.FirebaseAuth.instance)
            : null;

  bool get isDemoMode => _isDemoMode;

  Stream<firebase_auth.User?> get authStateChanges {
    if (!firebaseAvailable || _firebaseAuth == null) {
      return _demoAuthController.stream;
    }
    return _firebaseAuth!.authStateChanges();
  }

  firebase_auth.User? get currentUser {
    if (!firebaseAvailable || _firebaseAuth == null) {
      return null;
    }
    return _firebaseAuth!.currentUser;
  }

  /// Enter demo mode without Firebase authentication
  Future<User> enterDemoMode() async {
    _isDemoMode = true;
    _demoUser = User(
      id: 'demo-user',
      email: 'demo@example.com',
      createdAt: DateTime.now(),
    );
    _demoAuthController.add(null); // Trigger update
    return _demoUser!;
  }

  Future<User> signInWithEmail(String email, String password) async {
    if (!firebaseAvailable || _firebaseAuth == null) {
      // Demo mode - simulate login
      return enterDemoMode();
    }

    final credential = await _firebaseAuth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign in failed');
    }

    try {
      return await _apiService.registerUser(
        credential.user!.uid,
        credential.user!.email!,
      );
    } catch (e) {
      // If backend is not available, return demo user
      return User(
        id: credential.user!.uid,
        email: credential.user!.email!,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<User> signUpWithEmail(String email, String password) async {
    if (!firebaseAvailable || _firebaseAuth == null) {
      // Demo mode - simulate signup
      return enterDemoMode();
    }

    final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign up failed');
    }

    try {
      return await _apiService.registerUser(
        credential.user!.uid,
        credential.user!.email!,
      );
    } catch (e) {
      // If backend is not available, return demo user
      return User(
        id: credential.user!.uid,
        email: credential.user!.email!,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> signOut() async {
    if (_isDemoMode) {
      _isDemoMode = false;
      _demoUser = null;
      _demoAuthController.add(null);
      return;
    }

    if (_firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
  }

  Future<void> updateFcmToken(String token) async {
    if (_isDemoMode) return;

    try {
      await _apiService.updateFcmToken(token);
    } catch (e) {
      // Ignore FCM token update failures
    }
  }

  Future<User> getCurrentUser() async {
    if (_isDemoMode && _demoUser != null) {
      return _demoUser!;
    }

    try {
      return await _apiService.getCurrentUser();
    } catch (e) {
      // If backend not available, return demo user
      final firebaseUser = currentUser;
      return User(
        id: firebaseUser?.uid ?? 'demo-user',
        email: firebaseUser?.email ?? 'demo@example.com',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (_firebaseAuth != null) {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    }
  }

  void dispose() {
    _demoAuthController.close();
  }
}
