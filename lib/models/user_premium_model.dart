class UserPremium {
  final String userId;
  final int totalLoopingSlots;
  final List<PurchaseHistory> purchases;

  const UserPremium({
    required this.userId,
    this.totalLoopingSlots = 10, // Default 10 slot gratis
    this.purchases = const [],
  });

  UserPremium copyWith({
    String? userId,
    int? totalLoopingSlots,
    List<PurchaseHistory>? purchases,
  }) {
    return UserPremium(
      userId: userId ?? this.userId,
      totalLoopingSlots: totalLoopingSlots ?? this.totalLoopingSlots,
      purchases: purchases ?? this.purchases,
    );
  }

  factory UserPremium.fromJson(Map<String, dynamic> json) {
    return UserPremium(
      userId: json['userId'] as String,
      totalLoopingSlots: json['totalLoopingSlots'] as int? ?? 10,
      purchases: (json['purchases'] as List?)
              ?.map((p) => PurchaseHistory.fromJson(p))
              .toList() ??
          [],
    );
  }

  factory UserPremium.fromFirestore(Map<String, dynamic> data, String userId) {
    return UserPremium(
      userId: userId,
      totalLoopingSlots: data['totalLoopingSlots'] as int? ?? 10,
      purchases: (data['purchases'] as List?)
              ?.map((p) => PurchaseHistory.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalLoopingSlots': totalLoopingSlots,
      'purchases': purchases.map((p) => p.toJson()).toList(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalLoopingSlots': totalLoopingSlots,
      'purchases': purchases.map((p) => p.toJson()).toList(),
    };
  }
}

class PurchaseHistory {
  final String productId;
  final int slotsAdded;
  final DateTime purchaseDate;
  final String paymentMethod; // 'google_play' or 'dana'
  final String? transactionId;

  const PurchaseHistory({
    required this.productId,
    required this.slotsAdded,
    required this.purchaseDate,
    required this.paymentMethod,
    this.transactionId,
  });

  factory PurchaseHistory.fromJson(Map<String, dynamic> json) {
    return PurchaseHistory(
      productId: json['productId'] as String,
      slotsAdded: json['slotsAdded'] as int,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'slotsAdded': slotsAdded,
      'purchaseDate': purchaseDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }
}
