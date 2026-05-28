class Order {
  final int? id;
  final int? customerId;
  final String clothType;
  final double price;
  final String? deliveryDate;
  final String status;
  final String? notes;
  final String createdAt;
  final String? paymentMethod;
  final String? transactionId;
  final String? paymentStatus;
  // Measurement fields
  final String? gender;
  final double? chest;
  final double? shoulder;
  final double? hip;
  final double? breast;
  final double? waist;
  final double? length;
  final double? sleeve;
  final double? neck;
  // Cloth photo
  final String? clothPhoto;

  Order({
    this.id,
    this.customerId,
    required this.clothType,
    required this.price,
    this.deliveryDate,
    required this.status,
    this.notes,
    required this.createdAt,
    this.paymentMethod,
    this.transactionId,
    this.paymentStatus,
    this.gender,
    this.chest,
    this.shoulder,
    this.hip,
    this.breast,
    this.waist,
    this.length,
    this.sleeve,
    this.neck,
    this.clothPhoto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'clothType': clothType,
      'price': price,
      'deliveryDate': deliveryDate,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentStatus': paymentStatus,
      'gender': gender,
      'chest': chest,
      'shoulder': shoulder,
      'hip': hip,
      'breast': breast,
      'waist': waist,
      'length': length,
      'sleeve': sleeve,
      'neck': neck,
      'clothPhoto': clothPhoto,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id']?.toInt(),
      customerId: map['customerId']?.toInt(),
      clothType: map['clothType'],
      price: map['price']?.toDouble() ?? 0.0,
      deliveryDate: map['deliveryDate'],
      status: map['status'],
      notes: map['notes'],
      createdAt: map['createdAt'],
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      paymentStatus: map['paymentStatus'],
      gender: map['gender'],
      chest: map['chest']?.toDouble(),
      shoulder: map['shoulder']?.toDouble(),
      hip: map['hip']?.toDouble(),
      breast: map['breast']?.toDouble(),
      waist: map['waist']?.toDouble(),
      length: map['length']?.toDouble(),
      sleeve: map['sleeve']?.toDouble(),
      neck: map['neck']?.toDouble(),
      clothPhoto: map['clothPhoto'],
    );
  }

  Order copyWith({
    int? id,
    int? customerId,
    String? clothType,
    double? price,
    String? deliveryDate,
    String? status,
    String? notes,
    String? createdAt,
    String? paymentMethod,
    String? transactionId,
    String? paymentStatus,
    String? gender,
    double? chest,
    double? shoulder,
    double? hip,
    double? breast,
    double? waist,
    double? length,
    double? sleeve,
    double? neck,
    String? clothPhoto,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      clothType: clothType ?? this.clothType,
      price: price ?? this.price,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      gender: gender ?? this.gender,
      chest: chest ?? this.chest,
      shoulder: shoulder ?? this.shoulder,
      hip: hip ?? this.hip,
      breast: breast ?? this.breast,
      waist: waist ?? this.waist,
      length: length ?? this.length,
      sleeve: sleeve ?? this.sleeve,
      neck: neck ?? this.neck,
      clothPhoto: clothPhoto ?? this.clothPhoto,
    );
  }
}
