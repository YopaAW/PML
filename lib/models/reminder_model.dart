import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Reminder {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime eventDate;
  @HiveField(3)
  final bool isCompleted;
  @HiveField(4)
  final int? categoryId;
  @HiveField(5)
  final String? description;

  const Reminder({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.isCompleted,
    this.categoryId,
    this.description,
  });

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? eventDate,
    bool? isCompleted,
    int? categoryId,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      categoryId: json['categoryId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'isCompleted': isCompleted,
      'categoryId': categoryId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Reminder &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.eventDate == eventDate &&
        other.isCompleted == isCompleted &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        eventDate.hashCode ^
        isCompleted.hashCode ^
        categoryId.hashCode;
  }
}