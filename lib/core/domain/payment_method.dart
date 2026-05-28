class PaymentMethods {
  static const cash = 'cash';
  static const bankTransfer = 'bank_transfer';
  static const telebirr = 'telebirr';
  static const cbeBirr = 'cbe_birr';
  static const chapa = 'chapa';
  static const mobileMoney = 'mobile_money';
  static const card = 'card';
  static const other = 'other';

  static const values = [
    cash,
    bankTransfer,
    telebirr,
    cbeBirr,
    chapa,
    mobileMoney,
    card,
    other,
  ];
}

class PaymentTypes {
  static const advance = 'advance';
  static const partial = 'partial';
  static const full = 'full';
  static const refund = 'refund';
}
