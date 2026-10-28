import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailoring_system/services/firebase_service.dart';
import 'package:tailoring_system/services/sendliberty_service.dart';

/// OTP verification service
class OtpService {
  final FirebaseService _firebase = FirebaseService();
  final SendlibertyService _emailService = SendlibertyService();

  FirebaseFirestore get _firestore => _firebase.firestore;

  static const String _collectionName = 'otp_codes';
  static const int _otpLength = 6;
  static const int _otpValidityMinutes = 10;
  static const int _maxAttemptsPerHour = 3;

  /// Generate random 6-digit OTP
  String _generateOtp() {
    final random = Random.secure();
    final otp = List.generate(_otpLength, (_) => random.nextInt(10)).join();
    print('🔐 Generated OTP: $otp');
    return otp;
  }

  /// Send OTP to email
  Future<Map<String, dynamic>> sendOtp({
    required String email,
    required String recipientName,
  }) async {
    try {
      print('📧 Sending OTP to: $email');

      // Check rate limiting
      final canSend = await _checkRateLimit(email);
      if (!canSend) {
        return {
          'success': false,
          'message': 'Too many OTP requests. Please try again in an hour.',
        };
      }

      // Generate OTP
      final otp = _generateOtp();
      final expiresAt = DateTime.now().add(Duration(minutes: _otpValidityMinutes));

      // Save OTP to Firestore
      await _firestore.collection(_collectionName).doc(email).set({
        'otp': otp,
        'email': email,
        'recipientName': recipientName,
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'verified': false,
        'attempts': 0,
      });

      print('💾 OTP saved to Firestore');

      // Send email via Sendliberty
      final emailSent = await _emailService.sendOtpEmail(
        to: email,
        otp: otp,
        recipientName: recipientName,
      );

      if (!emailSent) {
        return {
          'success': false,
          'message': 'Failed to send email. Please try again.',
        };
      }

      return {
        'success': true,
        'message': 'OTP sent successfully to $email',
        'expiresAt': expiresAt.toIso8601String(),
      };
    } catch (e) {
      print('❌ Error sending OTP: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Verify OTP code
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔍 Verifying OTP for: $email');

      // Get OTP document
      final doc = await _firestore.collection(_collectionName).doc(email).get();

      if (!doc.exists) {
        return {
          'success': false,
          'message': 'No OTP found. Please request a new one.',
        };
      }

      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiresAt = DateTime.parse(data['expiresAt'] as String);
      final verified = data['verified'] as bool;
      final attempts = (data['attempts'] as int?) ?? 0;

      // Check if already verified
      if (verified) {
        return {
          'success': false,
          'message': 'This OTP has already been used.',
        };
      }

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection(_collectionName).doc(email).delete();
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Check max attempts (prevent brute force)
      if (attempts >= 5) {
        await _firestore.collection(_collectionName).doc(email).delete();
        return {
          'success': false,
          'message': 'Too many failed attempts. Please request a new OTP.',
        };
      }

      // Verify OTP
      if (otp.trim() == storedOtp) {
        // Mark as verified
        await _firestore.collection(_collectionName).doc(email).update({
          'verified': true,
          'verifiedAt': DateTime.now().toIso8601String(),
        });

        print('✅ OTP verified successfully');
        return {
          'success': true,
          'message': 'Email verified successfully!',
        };
      } else {
        // Increment failed attempts
        await _firestore.collection(_collectionName).doc(email).update({
          'attempts': attempts + 1,
        });

        print('❌ Invalid OTP');
        return {
          'success': false,
          'message': 'Invalid OTP. ${4 - attempts} attempts remaining.',
        };
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return {
        'success': false,
        'message': 'Verification error: $e',
      };
    }
  }

  /// Check rate limiting (max 3 OTPs per hour per email)
  Future<bool> _checkRateLimit(String email) async {
    try {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

      final query = await _firestore
          .collection(_collectionName)
          .where('email', isEqualTo: email)
          .where('createdAt', isGreaterThan: oneHourAgo.toIso8601String())
          .get();

      final count = query.docs.length;
      print('🔍 OTP requests in last hour: $count/$_maxAttemptsPerHour');

      return count < _maxAttemptsPerHour;
    } catch (e) {
      print('⚠️ Rate limit check error: $e');
      // On error, allow sending (fail open)
      return true;
    }
  }

  /// Resend OTP (with rate limiting)
  Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String recipientName,
  }) async {
    print('🔄 Resending OTP to: $email');
    
    // Delete old OTP
    try {
      await _firestore.collection(_collectionName).doc(email).delete();
    } catch (e) {
      print('⚠️ Could not delete old OTP: $e');
    }

    // Send new OTP
    return await sendOtp(email: email, recipientName: recipientName);
  }

  /// Clean up expired OTPs (call periodically or via Cloud Function)
  Future<void> cleanupExpiredOtps() async {
    try {
      final now = DateTime.now().toIso8601String();
      final query = await _firestore
          .collection(_collectionName)
          .where('expiresAt', isLessThan: now)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }

      print('🧹 Cleaned up ${query.docs.length} expired OTPs');
    } catch (e) {
      print('❌ Error cleaning up OTPs: $e');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified(String email) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(email).get();
      
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      return data['verified'] == true;
    } catch (e) {
      print('❌ Error checking verification status: $e');
      return false;
    }
  }
}
