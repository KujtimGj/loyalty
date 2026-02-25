class BusinessLocation {
  final String id;
  final String businessId;
  final String name;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessLocation({
    required this.id,
    required this.businessId,
    required this.name,
    required this.address,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessLocation.fromJson(Map<String, dynamic> json) {
    return BusinessLocation(
      id: json['_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] ?? json['businessId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'business_id': businessId,
      'name': name,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
