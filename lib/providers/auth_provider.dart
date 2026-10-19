import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailoring_system/services/auth_service.dart';
import 'package:tailoring_system/services/shop_service.dart';
import 'package:tailoring_system/models/shop_profile.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ShopService _shopService = ShopService();

  User? _user;
  ShopProfile? _shopProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  User? get currentUser => _user;  // Alias for consistency
  ShopProfile? get shopProfile => _shopProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isSetupComplete => _shopProfile?.isSetupComplete ?? false;

  AuthProvider() {
    _initAuth();
  }

  /// Initialize auth state listener
  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      
      if (user != null) {
        await _loadShopProfile();
      } else {
        _shopProfile = null;
      }
      
      notifyListeners();
    });
  }

  /// Load shop profile
  Future<void> _loadShopProfile() async {
    try {
      _shopProfile = await _shopService.getShopProfile();
      notifyListeners();
    } catch (e) {
      print('Error loading shop profile: $e');
    }
  }

  /// Register new tailor account
  Future<bool> register(String email, String password, String shopName, String ownerName, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create Firebase auth account
      final credential = await _authService.registerWithEmailPassword(email, password);
      
      // Create shop profile
      final profile = ShopProfile(
        userId: credential.user!.uid,
        shopName: shopName,
        ownerName: ownerName,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
        isSetupComplete: false,
      );
      
      await _shopService.createShopProfile(profile);
      
      _user = credential.user;
      _shopProfile = profile;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login existing tailor
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signInWithEmailPassword(email, password);
      
      _user = credential.user;
      await _loadShopProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _shopProfile = null;
    notifyListeners();
  }

  /// Logout (alias for signOut for consistency)
  Future<void> logout() async {
    await signOut();
  }

  /// Check authentication status (for app initialization)
  Future<void> checkAuthStatus() async {
    _user = _authService.currentUser;
    if (_user != null) {
      await _loadShopProfile();
    }
    notifyListeners();
  }

  /// Complete shop onboarding
  Future<void> completeOnboarding(ShopProfile updatedProfile) async {
    try {
      final completeProfile = updatedProfile.copyWith(
        isSetupComplete: true,
        updatedAt: DateTime.now(),
      );
      
      await _shopService.updateShopProfile(completeProfile);
      _shopProfile = completeProfile;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication error: $code';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
