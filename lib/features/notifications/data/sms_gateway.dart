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
      errorMessage: 'SMS gateway is not configured',
    );
  }
}
