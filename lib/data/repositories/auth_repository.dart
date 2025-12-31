import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepository({
    required ApiService apiService,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _apiService = apiService,
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign in failed');
    }

    return _apiService.registerUser(
      credential.user!.uid,
      credential.user!.email!,
    );
  }

  Future<User> signUpWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) {
      throw Exception('Sign up failed');
    }

    return _apiService.registerUser(
      credential.user!.uid,
      credential.user!.email!,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateFcmToken(String token) async {
    await _apiService.updateFcmToken(token);
  }

  Future<User> getCurrentUser() async {
    return _apiService.getCurrentUser();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
