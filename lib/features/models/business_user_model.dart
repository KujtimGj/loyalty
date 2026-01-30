class BusinessUser {
  final String id;
  final String businessId;
  final String locationId;
  final String name;
  final String email;
  final String role; // "admin", "manager", "staff"

  BusinessUser({
    required this.id,
    required this.businessId,
    required this.locationId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    return BusinessUser(
      id: json['_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] is String
          ? json['business_id']
          : json['business_id']?['_id'] ?? json['business_id']?['id'] ?? '',
      locationId: json['location_id'] is String
          ? json['location_id']
          : json['location_id']?['_id'] ?? json['location_id']?['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'business_id': businessId,
      'location_id': locationId,
      'name': name,
      'email': email,
      'role': role,
    };
  }
}
