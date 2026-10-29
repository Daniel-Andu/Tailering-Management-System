import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tailoring_system/services/auth_service.dart';
import 'package:tailoring_system/services/shop_service.dart';
import 'package:tailoring_system/services/otp_service.dart';
import 'package:tailoring_system/models/shop_profile.dart';

/// Authentication state management
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ShopService _shopService = ShopService();
  final OtpService _otpService = OtpService();

  User? _user;
  ShopProfile? _shopProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;

  // Getters
  User? get user => _user;
  User? get currentUser => _user;  // Alias for consistency
  ShopProfile? get shopProfile => _shopProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isSetupComplete => _shopProfile?.isSetupComplete ?? false;
  bool get isEmailVerified => _isEmailVerified;

  AuthProvider() {
    print('🔧 AuthProvider: Initializing...');
    _initAuth();
  }

  /// Initialize auth state listener
  void _initAuth() {
    print('🔧 AuthProvider: Setting up auth state listener...');
    
    // First check current user immediately
    _user = _authService.currentUser;
    if (_user != null) {
      print('✅ AuthProvider: Found existing user: ${_user!.email}');
      _loadShopProfile();
    } else {
      print('⚠️ AuthProvider: No existing user found');
    }
    
    // Then listen for auth state changes
    _authService.authStateChanges.listen((User? user) async {
      print('🔔 AuthProvider: Auth state changed');
      _user = user;
      
      if (user != null) {
        print('✅ User logged in: ${user.email}');
        await _loadShopProfile();
      } else {
        print('⚠️ User logged out');
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
      print('🔐 Starting registration for: $email');
      
      // Create Firebase auth account
      User user;
      try {
        user = await _authService.registerWithEmailPassword(email, password);
        print('✅ Firebase auth account created: ${user.uid}');
      } catch (authError) {
        print('❌ Firebase Auth error: $authError');
        throw Exception('Auth failed: $authError');
      }
      
      // Create shop profile
      final profile = ShopProfile(
        userId: user.uid,
        shopName: shopName,
        ownerName: ownerName,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
        isSetupComplete: false,
      );
      
      print('📝 Creating shop profile in Firestore...');
      print('📝 User ID: ${user.uid}');
      print('📝 Shop Name: $shopName');
      
      try {
        await _shopService.createShopProfile(profile);
        print('✅ Shop profile created successfully');
      } catch (firestoreError) {
        print('❌ Firestore error: $firestoreError');
        // Registration succeeded in Auth but failed in Firestore
        // Don't fail completely - user can complete profile later
        _errorMessage = 'Account created but profile setup incomplete. Please complete setup.';
      }
      
      _user = user;
      _shopProfile = profile;
      
      _isLoading = false;
      notifyListeners();
      print('✅ Registration completed');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Registration error: $e');
      _errorMessage = 'Registration error: ${e.toString()}';
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
      print('🔐 Starting login for: $email');
      
      final credential = await _authService.signInWithEmailPassword(email, password);
      print('✅ Firebase auth successful: ${credential.user!.uid}');
      
      _user = credential.user;
      await _loadShopProfile();
      
      _isLoading = false;
      notifyListeners();
      print('✅ Login completed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ Login error: $e');
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
    print('🔍 Checking auth status...');
    _user = _authService.currentUser;
    
    if (_user != null) {
      print('✅ User found: ${_user!.uid}');
      await _loadShopProfile();
    } else {
      print('⚠️ No user found');
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

  /// Send OTP to user's email for verification
  Future<Map<String, dynamic>> sendOtpVerification(String email, String recipientName) async {
    return await _otpService.sendOtp(
      email: email,
      recipientName: recipientName,
    );
  }

  /// Verify OTP code
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final result = await _otpService.verifyOtp(email: email, otp: otp);
    
    if (result['success']) {
      _isEmailVerified = true;
      notifyListeners();
    }
    
    return result;
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email, String recipientName) async {
    return await _otpService.resendOtp(
      email: email,
      recipientName: recipientName,
    );
  }

  /// Check if email is verified
  Future<bool> checkEmailVerified(String email) async {
    final verified = await _otpService.isEmailVerified(email);
    _isEmailVerified = verified;
    notifyListeners();
    return verified;
  }
}
