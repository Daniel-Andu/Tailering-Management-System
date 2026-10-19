import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailoring_system/services/firebase_service.dart';

/// Firebase Authentication service
class AuthService {
  final FirebaseService _firebase = FirebaseService();

  FirebaseAuth get _auth => _firebase.auth;

  // Current user
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously (for trial users)
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Link anonymous account with email/password
  Future<UserCredential> linkWithEmailPassword(String email, String password) async {
    final credential = EmailAuthProvider.credential(email: email, password: password);
    return await currentUser!.linkWithCredential(credential);
  }
}
