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
      errorMessage: 'SMS gateway is not configured. Messages are queued for a real SMS provider.',
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
