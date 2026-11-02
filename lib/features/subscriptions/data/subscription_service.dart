import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SubscriptionService {
  SubscriptionService({http.Client? client})
      : _client = client ?? http.Client();

  static const _apiUrl = String.fromEnvironment('SUBSCRIPTION_API_URL');
  final http.Client _client;

  bool get isConfigured => _apiUrl.trim().isNotEmpty;

  Future<CheckoutSession> startCheckout({
    required String planId,
    required String deviceId,
    required String idempotencyKey,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'Chapa subscriptions are not configured. Set SUBSCRIPTION_API_URL to your secure billing backend.',
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in before starting checkout.');
    final response = await _client
        .post(
          _uri('/subscriptions/checkout'),
          headers: {...await _headers(user), 'Idempotency-Key': idempotencyKey},
          body: jsonEncode({'plan_id': planId, 'device_id': deviceId}),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decodeResponse(response);
    final checkoutUrl = data['checkout_url'];
    if (checkoutUrl is! String || checkoutUrl.trim().isEmpty) {
      throw const FormatException(
        'Billing backend did not return a Chapa checkout URL.',
      );
    }

    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const FormatException('Billing backend returned an invalid URL.');
    }
    final merchantReference = data['merchant_reference'];
    if (merchantReference is! String || merchantReference.trim().isEmpty) {
      throw const FormatException(
        'Billing backend did not return a payment reference.',
      );
    }
    return CheckoutSession(
      checkoutUrl: uri,
      merchantReference: merchantReference,
    );
  }

  Future<bool> openCheckout(Uri checkoutUri) {
    return launchUrl(checkoutUri, mode: LaunchMode.externalApplication);
  }

  Future<SubscriptionStatus> verifyCheckout(String merchantReference) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to verify the payment.');
    final response = await _client
        .post(
          _uri('/subscriptions/verify'),
          headers: await _headers(user),
          body: jsonEncode({'merchant_reference': merchantReference}),
        )
        .timeout(const Duration(seconds: 20));
    final data = _decodeResponse(response);
    return SubscriptionStatus(
      isActive: data['active'] == true,
      planId: data['plan_id'] as String?,
      expiresAt: data['expires_at'] is String
          ? DateTime.tryParse(data['expires_at'] as String)
          : null,
      paymentStatus: data['payment_status'] as String?,
    );
  }

  Future<SubscriptionStatus?> loadStatus() async {
    if (!isConfigured) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to check subscription status.');

    final response = await _client
        .get(_uri('/subscriptions/status'), headers: await _headers(user))
        .timeout(const Duration(seconds: 20));
    final data = _decodeResponse(response);
    return SubscriptionStatus(
      isActive: data['active'] == true,
      planId: data['plan_id'] as String?,
      expiresAt: data['expires_at'] is String
          ? DateTime.tryParse(data['expires_at'] as String)
          : null,
    );
  }

  Uri _uri(String path) {
    final base = _apiUrl.endsWith('/')
        ? _apiUrl.substring(0, _apiUrl.length - 1)
        : _apiUrl;
    final uri = Uri.parse('$base$path');
    final localHttp = uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
    if (uri.host.isEmpty || (uri.scheme != 'https' && !localHttp)) {
      throw StateError('Billing backend must use HTTPS.');
    }
    return uri;
  }

  Future<Map<String, String>> _headers(User user) async {
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Could not authenticate with the billing backend.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  String createIdempotencyKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(
        message ?? 'Billing backend returned HTTP ${response.statusCode}.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Billing backend returned invalid JSON.');
    }
    return decoded;
  }
}

class CheckoutSession {
  const CheckoutSession({
    required this.checkoutUrl,
    required this.merchantReference,
  });

  final Uri checkoutUrl;
  final String merchantReference;
}

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isActive,
    this.planId,
    this.expiresAt,
    this.paymentStatus,
  });

  final bool isActive;
  final String? planId;
  final DateTime? expiresAt;
  final String? paymentStatus;
}
