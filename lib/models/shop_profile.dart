/// Shop/Tailor business profile model
class ShopProfile {
  final String? id;
  final String userId;
  final String shopName;
  final String ownerName;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final String? businessType; // 'tailor', 'alteration', 'custom_design'
  final String? specialization; // 'Men', 'Women', 'Both', 'Custom', 'Alterations'
  final int? yearsOfExperience;
  final String? currency;
  final String? language;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSetupComplete;

  // Convenience getters
  String get phoneNumber => phone; // Alias for compatibility

  ShopProfile({
    this.id,
    required this.userId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.country,
    this.businessType,
    this.specialization,
    this.yearsOfExperience,
    this.currency,
    this.language,
    required this.createdAt,
    this.updatedAt,
    this.isSetupComplete = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'businessType': businessType,
      'specialization': specialization,
      'yearsOfExperience': yearsOfExperience,
      'currency': currency,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSetupComplete': isSetupComplete,
    };
  }

  factory ShopProfile.fromMap(Map<String, dynamic> map, String id) {
    return ShopProfile(
      id: id,
      userId: map['userId'] ?? '',
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      city: map['city'],
      country: map['country'],
      businessType: map['businessType'],
      specialization: map['specialization'],
      yearsOfExperience: map['yearsOfExperience'],
      currency: map['currency'],
      language: map['language'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isSetupComplete: map['isSetupComplete'] ?? false,
    );
  }

  ShopProfile copyWith({
    String? id,
    String? userId,
    String? shopName,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? businessType,
    String? specialization,
    int? yearsOfExperience,
    String? currency,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSetupComplete,
  }) {
    return ShopProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      businessType: businessType ?? this.businessType,
      specialization: specialization ?? this.specialization,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
    );
  }
}
