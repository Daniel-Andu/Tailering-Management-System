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
  /// Returns the User directly, handling the PigeonUserDetails bug gracefully
  Future<User> registerWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Registration successful via normal path');
      return credential.user!;
    } catch (e) {
      print('⚠️ AuthService: createUserWithEmailAndPassword threw error: $e');
      
      // Check if this is the known PigeonUserDetails type casting bug
      final errorStr = e.toString();
      if (errorStr.contains('PigeonUserDetails') || 
          errorStr.contains('List<Object?>') ||
          errorStr.contains('type cast')) {
        print('🔍 Detected type casting bug - checking if user was actually created...');
        
        // Wait for Firebase to process the registration
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Check if a user is now authenticated
        var user = _auth.currentUser;
        
        // If no user, try reloading auth state
        if (user == null) {
          print('⏳ No current user yet, waiting and checking again...');
          await Future.delayed(const Duration(milliseconds: 500));
          user = _auth.currentUser;
        }
        
        if (user != null && user.email == email) {
          print('✅ User was created successfully despite error! UID: ${user.uid}');
          return user;
        } else {
          print('❌ User was NOT created - registration actually failed');
          throw FirebaseAuthException(
            code: 'registration-failed',
            message: 'Registration failed: $errorStr',
          );
        }
      }
      
      // Not the known bug - rethrow original error
      rethrow;
    }
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
