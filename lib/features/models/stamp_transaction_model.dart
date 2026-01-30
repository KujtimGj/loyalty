class StampTransaction {
  final String id;
  final String customerLoyaltyCardId;
  final String businessUserId;
  final String locationId;
  final int stampsAdded;
  final String source; // "purchase", "manual", "promotion", "referral"
  final DateTime createdAt;

  StampTransaction({
    required this.id,
    required this.customerLoyaltyCardId,
    required this.businessUserId,
    required this.locationId,
    required this.stampsAdded,
    required this.source,
    required this.createdAt,
  });

  factory StampTransaction.fromJson(Map<String, dynamic> json) {
    return StampTransaction(
      id: json['_id'] ?? json['id'] ?? '',
      customerLoyaltyCardId: json['customer_loyalty_card_id'] is String
          ? json['customer_loyalty_card_id']
          : json['customer_loyalty_card_id']?['_id'] ?? json['customer_loyalty_card_id']?['id'] ?? '',
      businessUserId: json['business_user_id'] is String
          ? json['business_user_id']
          : json['business_user_id']?['_id'] ?? json['business_user_id']?['id'] ?? '',
      locationId: json['location_id'] is String
          ? json['location_id']
          : json['location_id']?['_id'] ?? json['location_id']?['id'] ?? '',
      stampsAdded: json['stamps_added'] ?? 0,
      source: json['source'] ?? 'manual',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customer_loyalty_card_id': customerLoyaltyCardId,
      'business_user_id': businessUserId,
      'location_id': locationId,
      'stamps_added': stampsAdded,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
