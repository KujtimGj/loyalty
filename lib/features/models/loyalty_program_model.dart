class LoyaltyProgramImage {
  final String imageUrl;
  final String? signedUrl;

  LoyaltyProgramImage({
    required this.imageUrl,
    this.signedUrl,
  });

  factory LoyaltyProgramImage.fromJson(Map<String, dynamic> json) {
    return LoyaltyProgramImage(
      imageUrl: json['image_url'] ?? '',
      signedUrl: json['signedUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      if (signedUrl != null) 'signedUrl': signedUrl,
    };
  }
}

class LoyaltyProgram {
  final String id;
  final String businessId;
  final String name;
  final int stampsRequired;
  final String rewardDescription;
  final String rewardType;
  final List<LoyaltyProgramImage> images;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final String? businessName; // Populated from business_id
  final String? businessLogoUrl; // Populated from business_id.logo
  final String? businessIndustry; // Populated from business_id.industry
  final int? currentStamps; // Current stamps earned by the customer (if available)
  final int? completedCycles; // Times customer has collected/redeemed this reward

  LoyaltyProgram({
    required this.id,
    required this.businessId,
    required this.name,
    required this.stampsRequired,
    required this.rewardDescription,
    required this.rewardType,
    required this.images,
    required this.price,
    required this.isActive,
    required this.createdAt,
    this.businessName,
    this.businessLogoUrl,
    this.businessIndustry,
    this.currentStamps,
    this.completedCycles,
  });

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) {
    // Handle images array
    List<LoyaltyProgramImage> images = [];
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List)
          .map((img) {
            if (img is Map<String, dynamic>) {
              return LoyaltyProgramImage.fromJson(img);
            } else if (img is Map) {
              // Convert Map<dynamic, dynamic> to Map<String, dynamic>
              final Map<String, dynamic> convertedMap = {};
              for (final entry in img.entries) {
                convertedMap[entry.key.toString()] = entry.value;
              }
              return LoyaltyProgramImage.fromJson(convertedMap);
            } else {
              return LoyaltyProgramImage.fromJson({'image_url': img.toString()});
            }
          })
          .toList();
    }

    // Handle business_id - can be string or populated object
    String businessId = '';
    String? businessName;
    String? businessLogoUrl;
    String? businessIndustry;
    if (json['business_id'] != null) {
      if (json['business_id'] is String) {
        businessId = json['business_id'];
      } else if (json['business_id'] is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic> for safe access
        final Map<String, dynamic> businessMap;
        if (json['business_id'] is Map<String, dynamic>) {
          businessMap = json['business_id'] as Map<String, dynamic>;
        } else {
          businessMap = {};
          for (final entry in (json['business_id'] as Map).entries) {
            businessMap[entry.key.toString()] = entry.value;
          }
        }
        
        businessId = businessMap['_id'] ?? businessMap['id'] ?? '';
        businessName = businessMap['name'];
        businessIndustry = businessMap['industry'];
        
        // Extract logo URL from business logo object
        if (businessMap['logo'] != null) {
          if (businessMap['logo'] is Map) {
            final Map<String, dynamic> logoMap;
            if (businessMap['logo'] is Map<String, dynamic>) {
              logoMap = businessMap['logo'] as Map<String, dynamic>;
            } else {
              logoMap = {};
              for (final entry in (businessMap['logo'] as Map).entries) {
                logoMap[entry.key.toString()] = entry.value;
              }
            }
            businessLogoUrl = logoMap['signedUrl'] ?? logoMap['image_url'];
          } else if (businessMap['logo'] is String) {
            businessLogoUrl = businessMap['logo'] as String;
          }
        }
      }
    }

    return LoyaltyProgram(
      id: json['_id'] ?? json['id'] ?? '',
      businessId: businessId,
      name: json['name'] ?? '',
      stampsRequired: json['stamps_required'] ?? 0,
      rewardDescription: json['reward_description'] ?? '',
      rewardType: json['reward_type'] ?? '',
      images: images,
      price: (json['price'] ?? 0).toDouble(),
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      businessName: businessName,
      businessLogoUrl: businessLogoUrl,
      businessIndustry: businessIndustry,
      currentStamps: json['current_stamps'],
      completedCycles: json['completed_cycles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'business_id': businessId,
      'name': name,
      'stamps_required': stampsRequired,
      'reward_description': rewardDescription,
      'reward_type': rewardType,
      'images': images.map((img) => img.toJson()).toList(),
      'price': price,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LoyaltyProgram copyWith({
    String? id,
    String? businessId,
    String? name,
    int? stampsRequired,
    String? rewardDescription,
    String? rewardType,
    List<LoyaltyProgramImage>? images,
    double? price,
    bool? isActive,
    DateTime? createdAt,
    String? businessName,
    String? businessLogoUrl,
    String? businessIndustry,
    int? currentStamps,
    int? completedCycles,
  }) {
    return LoyaltyProgram(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      stampsRequired: stampsRequired ?? this.stampsRequired,
      rewardDescription: rewardDescription ?? this.rewardDescription,
      rewardType: rewardType ?? this.rewardType,
      images: images ?? this.images,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      businessName: businessName ?? this.businessName,
      businessLogoUrl: businessLogoUrl ?? this.businessLogoUrl,
      businessIndustry: businessIndustry ?? this.businessIndustry,
      currentStamps: currentStamps ?? this.currentStamps,
      completedCycles: completedCycles ?? this.completedCycles,
    );
  }

  /// Get the first image URL, or null if no images
  String? get firstImageUrl => images.isNotEmpty 
      ? (images.first.signedUrl ?? images.first.imageUrl)
      : null;
}
