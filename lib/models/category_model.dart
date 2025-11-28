import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final bool isCustom;
  @HiveField(3)
  final bool isPremium;

  const Category({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.isPremium = false,
  });

  Category copyWith({
    int? id,
    String? name,
    bool? isCustom,
    bool? isPremium,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      isCustom: json['isCustom'] as bool,
      isPremium: json['isPremium'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCustom': isCustom,
      'isPremium': isPremium,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.isCustom == isCustom &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isCustom.hashCode ^ isPremium.hashCode;
  }
}