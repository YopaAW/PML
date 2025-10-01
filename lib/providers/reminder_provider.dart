// lib/providers/reminder_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';

class ReminderListNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    return [
      Reminder(
        id: 1,
        title: 'Rapat tim mingguan',
        eventDate: DateTime.now().add(const Duration(hours: 2)),
        isCompleted: false,
      ),
      Reminder(
        id: 2,
        title: 'Mengerjakan tugas Flutter',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
      ),
      Reminder(
        id: 3,
        title: 'Beli susu',
        eventDate: DateTime.now().subtract(const Duration(hours: 3)),
        isCompleted: true,
      ),
    ];
  }

  void addReminder(String title, DateTime eventDate) {
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      eventDate: eventDate,
      isCompleted: false,
    );
    state = [...state, newReminder];
  }

  void toggle(int id) {
    state = [
      for (final reminder in state)
        if (reminder.id == id)
          reminder.copyWith(isCompleted: !reminder.isCompleted)
        else
          reminder,
    ];
  }

  void remove(int id) {
    state = state.where((reminder) => reminder.id != id).toList();
  }
}

final reminderListProvider = NotifierProvider<ReminderListNotifier, List<Reminder>>(
  ReminderListNotifier.new,
);