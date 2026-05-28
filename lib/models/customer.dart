class Customer {
  final int? id;
  final String customerId;
  final String name;
  final String? businessName;
  final String? phone;
  final String? email;
  final String date;
  final String? notes;

  Customer({
    this.id,
    required this.customerId,
    required this.name,
    this.businessName,
    this.phone,
    this.email,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'name': name,
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'date': date,
      'notes': notes,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toInt(),
      customerId: map['customerId'] ?? '',
      name: map['name'],
      businessName: map['businessName'],
      phone: map['phone'],
      email: map['email'],
      date: map['date'] ?? '',
      notes: map['notes'],
    );
  }

  Customer copyWith({
    int? id,
    String? customerId,
    String? name,
    String? businessName,
    String? phone,
    String? email,
    String? date,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
