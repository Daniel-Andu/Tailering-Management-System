import 'package:tailoring_system/utils/database_helper.dart';

class ReceiptRepository {
  Future<ReceiptData?> receiptForPayment(int paymentId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT p.*, o.order_number, o.total_amount, o.paid_amount, o.balance_amount,
             c.name AS customer_name, c.phone AS customer_phone
      FROM payments p
      INNER JOIN orders o ON o.id = p.order_id
      INNER JOIN customers c ON c.id = p.customer_id
      WHERE p.id = ?
      LIMIT 1
      ''',
      [paymentId],
    );
    if (rows.isEmpty) return null;

    final settingsRows = await db.query('app_settings');
    final settings = {
      for (final row in settingsRows) row['key'] as String: row['value'] as String?,
    };

    return ReceiptData.fromMap(rows.first, settings);
  }

  String buildPlainTextReceipt(ReceiptData receipt, {String languageCode = 'en'}) {
    if (languageCode == 'am') {
      return '''
${receipt.shopName}
ደረሰኝ: ${receipt.receiptNumber}
ቀን: ${receipt.paidAt}

ደንበኛ: ${receipt.customerName}
ስልክ: ${receipt.customerPhone ?? '-'}
ትዕዛዝ: ${receipt.orderNumber}

የተከፈለ: ${receipt.amount.toStringAsFixed(2)} ${receipt.currency}
የክፍያ ዘዴ: ${receipt.paymentMethod}
ጠቅላላ: ${receipt.totalAmount.toStringAsFixed(2)} ${receipt.currency}
ቀሪ: ${receipt.balanceAmount.toStringAsFixed(2)} ${receipt.currency}

${receipt.footer ?? ''}
''';
    }

    return '''
${receipt.shopName}
Receipt: ${receipt.receiptNumber}
Date: ${receipt.paidAt}

Customer: ${receipt.customerName}
Phone: ${receipt.customerPhone ?? '-'}
Order: ${receipt.orderNumber}

Paid: ${receipt.amount.toStringAsFixed(2)} ${receipt.currency}
Payment Method: ${receipt.paymentMethod}
Total: ${receipt.totalAmount.toStringAsFixed(2)} ${receipt.currency}
Balance: ${receipt.balanceAmount.toStringAsFixed(2)} ${receipt.currency}

${receipt.footer ?? ''}
''';
  }
}

class ReceiptData {
  const ReceiptData({
    required this.receiptNumber,
    required this.paymentNumber,
    required this.orderNumber,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.totalAmount,
    required this.balanceAmount,
    required this.paidAt,
    required this.shopName,
    required this.currency,
    this.customerPhone,
    this.footer,
  });

  final String receiptNumber;
  final String paymentNumber;
  final String orderNumber;
  final String customerName;
  final String? customerPhone;
  final double amount;
  final String paymentMethod;
  final double totalAmount;
  final double balanceAmount;
  final String paidAt;
  final String shopName;
  final String currency;
  final String? footer;

  factory ReceiptData.fromMap(
    Map<String, Object?> map,
    Map<String, String?> settings,
  ) {
    return ReceiptData(
      receiptNumber: map['receipt_number'] as String? ?? '-',
      paymentNumber: map['payment_number'] as String? ?? '-',
      orderNumber: map['order_number'] as String? ?? '-',
      customerName: map['customer_name'] as String? ?? '-',
      customerPhone: map['customer_phone'] as String?,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String? ?? '-',
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      balanceAmount: (map['balance_amount'] as num?)?.toDouble() ?? 0,
      paidAt: map['paid_at'] as String? ?? '-',
      shopName: settings['shop.name'] ?? 'Tailoring System',
      currency: settings['shop.currency'] ?? 'ETB',
      footer: settings['receipt.footer'],
    );
  }
}
