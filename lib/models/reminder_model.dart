class Reminder {
  final int id;
  final String title;
  final DateTime eventDate;
  final bool isCompleted;

  const Reminder({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.isCompleted,
  });

  Reminder copyWith({
    int? id,
    String? title,
    DateTime? eventDate,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}


