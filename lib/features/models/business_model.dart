class Business {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String subscriptionStatus;
  final String plan;
  final DateTime createdAt;
  final String? logoUrl;

  Business({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.subscriptionStatus,
    required this.plan,
    required this.createdAt,
    this.logoUrl,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    // Handle logo field - it can be an object with image_url or signedUrl
    String? logoUrl;
    if (json['logo'] != null) {
      if (json['logo'] is Map) {
        logoUrl = json['logo']['image_url'] ?? json['logo']['signedUrl'];
      } else if (json['logo'] is String) {
        logoUrl = json['logo'];
      }
    }
    
    return Business(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      subscriptionStatus: json['subscription_status'] ?? 'inactive',
      plan: json['plan'] ?? 'free',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      logoUrl: logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'subscription_status': subscriptionStatus,
      'plan': plan,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subscriptionStatus,
    String? plan,
    DateTime? createdAt,
    String? logoUrl,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
