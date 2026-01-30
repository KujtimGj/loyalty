String _stringOrId(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    final m = value;
    return m['_id']?.toString() ?? m['id']?.toString() ?? '';
  }
  return '';
}

class CustomerLoyaltyCard {
  final String id;
  final String businessCustomerId;
  final String loyaltyProgramId;
  final int currentStamps;
  final int completedCycles;
  final DateTime createdAt;

  CustomerLoyaltyCard({
    required this.id,
    required this.businessCustomerId,
    required this.loyaltyProgramId,
    required this.currentStamps,
    required this.completedCycles,
    required this.createdAt,
  });

  factory CustomerLoyaltyCard.fromJson(Map<String, dynamic> json) {
    return CustomerLoyaltyCard(
      id: json['_id'] ?? json['id'] ?? '',
      businessCustomerId: _stringOrId(
        json['business_customer_id'] ?? json['business_id'],
      ),
      loyaltyProgramId: _stringOrId(json['loyalty_program_id']),
      currentStamps: json['current_stamps'] ?? json['stamps_earned'] ?? 0,
      completedCycles: json['completed_cycles'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'business_customer_id': businessCustomerId,
      'loyalty_program_id': loyaltyProgramId,
      'current_stamps': currentStamps,
      'completed_cycles': completedCycles,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
