import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../database_hive.dart'; // Import the Hive database



class ReminderListNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    _loadReminders(); // Load reminders from DB
    return []; // Initial state, will be updated by _loadReminders
  }

  Future<void> _loadReminders() async {
    DatabaseService.watchAllReminders().listen((reminders) {
      state = reminders;
    });
  }

  Future<void> addReminder(String title, DateTime eventDate, {int? categoryId, String? description, RecurrenceType recurrence = RecurrenceType.none, int? recurrenceValue, RecurrenceUnit? recurrenceUnit}) async {
    final newReminder = Reminder(
      id: 0, // Will be updated by insertReminder
      title: title,
      eventDate: eventDate,
      isCompleted: false,
      categoryId: categoryId,
      description: description,
      recurrence: recurrence,
      recurrenceValue: recurrenceValue,
      recurrenceUnit: recurrenceUnit,
    );
    await DatabaseService.insertReminder(newReminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await DatabaseService.updateReminder(reminder);
  }

  Future<void> toggleCompletion(int id) async {
    final reminder = state.firstWhere((r) => r.id == id);
    final updatedReminder = reminder.copyWith(isCompleted: !reminder.isCompleted);
    if (updatedReminder.isCompleted) {
      // await NotificationService().cancelNotification(id);
    }
    await updateReminder(updatedReminder);
  }

  Future<void> removeReminder(int id) async {
    // await NotificationService().cancelNotification(id);
    await DatabaseService.deleteReminder(id);
  }
}

final reminderListProvider = NotifierProvider<ReminderListNotifier, List<Reminder>>(
  ReminderListNotifier.new,
);
