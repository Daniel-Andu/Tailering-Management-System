import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SmsMessage {
  const SmsMessage({
    required this.to,
    required this.message,
    required this.languageCode,
    this.reference,
  });

  final String to;
  final String message;
  final String languageCode;
  final String? reference;
}

class SmsSendResult {
  const SmsSendResult({
    required this.success,
    this.providerMessageId,
    this.errorMessage,
  });

  final bool success;
  final String? providerMessageId;
  final String? errorMessage;
}

abstract class SmsGateway {
  Future<SmsSendResult> send(SmsMessage message);
}

class DisabledSmsGateway implements SmsGateway {
  @override
  Future<SmsSendResult> send(SmsMessage message) async {
    return const SmsSendResult(
      success: false,
      errorMessage:
          'SMS gateway is not configured. Messages are queued for a real SMS provider.',
    );
  }
}

class HttpSmsGateway implements SmsGateway {
  HttpSmsGateway({
    required this.endpoint,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String endpoint;
  final http.Client _client;

  @override
  Future<SmsSendResult> send(SmsMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'Sign in before sending SMS notifications.',
      );
    }
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'Could not authenticate with the SMS gateway.',
      );
    }

    final uri = Uri.parse(endpoint);
    if ((uri.scheme != 'https' && uri.host != 'localhost') ||
        uri.host.isEmpty) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'SMS gateway must use a secure HTTPS endpoint.',
      );
    }

    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'to': message.to,
            'message': message.message,
            'reference': message.reference,
            'language_code': message.languageCode,
          }),
        )
        .timeout(const Duration(seconds: 20));
    final body =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          body is Map<String, dynamic> ? body['message']?.toString() : null;
      return SmsSendResult(
        success: false,
        errorMessage:
            error ?? 'SMS provider returned HTTP ${response.statusCode}.',
      );
    }
    if (body is! Map<String, dynamic> || body['accepted'] != true) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'SMS provider did not confirm message acceptance.',
      );
    }
    return SmsSendResult(
      success: true,
      providerMessageId: body['message_id']?.toString(),
    );
  }
}

class AndroidSmsGateway implements SmsGateway {
  @override
  Future<SmsSendResult> send(SmsMessage message) async {
    final recipient = message.to.trim();
    if (recipient.isEmpty) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'Recipient phone number is missing.',
      );
    }

    final uri = Uri(
      scheme: 'sms',
      path: recipient,
      queryParameters: {'body': message.message},
    );

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      return const SmsSendResult(
        success: false,
        errorMessage: 'Unable to open the device SMS app.',
      );
    }

    return SmsSendResult(
      success: true,
      providerMessageId: uri.toString(),
    );
  }
}
