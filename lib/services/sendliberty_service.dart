import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sendliberty email service for transactional emails
class SendlibertyService {
  static const String _baseUrl = 'https://sendliberty.com/api';
  
  // TODO: Add these to your environment config or Firebase Remote Config
  static const String _apiKey = 'sl_ea0197c9_ef0b7ea5669dd77846d91e8672d1e1b483e0e03ee55e18bbb2d8301a'; // Get from https://sendliberty.com/dashboard
  static const String _senderEmail = 'getnettewodros77@gmail.com'; // Gmail you connected to Sendliberty
  static const String _senderName = 'Tailoring System';

  /// Send transactional email via Sendliberty
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlBody,
    String? textBody,
  }) async {
    try {
      print('📧 Sending email via Sendliberty to: $to');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _senderEmail,
          'to': to,
          'subject': subject,
          'html': htmlBody,
          if (textBody != null) 'text': textBody,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Email sent successfully');
        return true;
      } else {
        print('❌ Failed to send email: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending email: $e');
      return false;
    }
  }

  /// Send OTP verification email
  Future<bool> sendOtpEmail({
    required String to,
    required String otp,
    required String recipientName,
  }) async {
    final htmlBody = _buildOtpEmailHtml(otp, recipientName);
    final textBody = _buildOtpEmailText(otp, recipientName);

    return await sendEmail(
      to: to,
      subject: 'Verify Your Email - OTP Code',
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Build HTML email template for OTP
  String _buildOtpEmailHtml(String otp, String recipientName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 0; }
    .container { max-width: 600px; margin: 40px auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 32px 24px; text-align: center; }
    .header h1 { margin: 0; font-size: 28px; font-weight: 600; }
    .content { padding: 32px 24px; }
    .otp-box { background: #f8f9fa; border: 2px dashed #667eea; border-radius: 8px; padding: 24px; text-align: center; margin: 24px 0; }
    .otp-code { font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #667eea; font-family: 'Courier New', monospace; }
    .info-text { color: #6b7280; font-size: 14px; line-height: 1.6; margin: 16px 0; }
    .footer { background: #f8f9fa; padding: 24px; text-align: center; color: #6b7280; font-size: 12px; }
    .button { display: inline-block; background: #667eea; color: white; padding: 12px 32px; border-radius: 6px; text-decoration: none; font-weight: 600; margin: 16px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🧵 $_senderName</h1>
    </div>
    <div class="content">
      <h2 style="color: #1f2937; margin-top: 0;">Hello $recipientName! 👋</h2>
      <p style="color: #4b5563; font-size: 16px; line-height: 1.6;">
        Thank you for registering with $_senderName. To complete your registration and verify your email address, please use the One-Time Password (OTP) below:
      </p>
      
      <div class="otp-box">
        <p style="margin: 0 0 8px 0; color: #6b7280; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;">Your OTP Code</p>
        <div class="otp-code">$otp</div>
        <p style="margin: 16px 0 0 0; color: #ef4444; font-size: 14px; font-weight: 500;">⏰ Valid for 10 minutes</p>
      </div>

      <div class="info-text">
        <p><strong>Security Tips:</strong></p>
        <ul style="padding-left: 20px;">
          <li>Never share this code with anyone</li>
          <li>Our team will never ask for this code</li>
          <li>If you didn't request this, please ignore this email</li>
        </ul>
      </div>

      <p style="color: #6b7280; font-size: 14px; margin-top: 24px;">
        Need help? Contact our support team anytime.
      </p>
    </div>
    <div class="footer">
      <p>© ${DateTime.now().year} $_senderName. All rights reserved.</p>
      <p>This is an automated email. Please do not reply to this message.</p>
    </div>
  </div>
</body>
</html>
''';
  }

  /// Build plain text email for OTP (fallback)
  String _buildOtpEmailText(String otp, String recipientName) {
    return '''
Hello $recipientName!

Thank you for registering with $_senderName.

Your verification code is: $otp

This code is valid for 10 minutes.

Security Tips:
- Never share this code with anyone
- Our team will never ask for this code
- If you didn't request this, please ignore this email

Need help? Contact our support team.

© ${DateTime.now().year} $_senderName. All rights reserved.
''';
  }
}
