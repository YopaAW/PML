import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../services/unified_database_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';


class ReminderListNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    // Watch auth state to trigger rebuild on login/logout
    ref.watch(authStateProvider);
    
    _loadReminders(); // Load reminders from DB
    return []; // Initial state
  }

  Future<void> _loadReminders() async {
    final subscription = UnifiedDatabaseService.watchAllReminders().listen((reminders) {
      state = reminders;
    });
    
    // Dispose subscription when provider is disposed
    ref.onDispose(() {
      subscription.cancel();
    });
  }

  Future<Reminder> addReminder(String title, DateTime eventDate, {String? categoryId, String? description, RecurrenceType recurrence = RecurrenceType.none, int? recurrenceValue, RecurrenceUnit? recurrenceUnit}) async {
    final newReminder = Reminder(
      id: '', // Will be updated by insertReminder
      title: title,
      eventDate: eventDate,
      isCompleted: false,
      categoryId: categoryId,
      description: description,
      recurrence: recurrence,
      recurrenceValue: recurrenceValue,
      recurrenceUnit: recurrenceUnit,
    );
    return await UnifiedDatabaseService.insertReminder(newReminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await UnifiedDatabaseService.updateReminder(reminder);
  }

  Future<void> toggleCompletion(String id) async {
    final reminder = state.firstWhere((r) => r.id == id);
    final updatedReminder = reminder.copyWith(isCompleted: !reminder.isCompleted);
    
    // Logic: If marking as completed AND it's a looping reminder
    if (updatedReminder.isCompleted && reminder.recurrence != RecurrenceType.none) {
       // Create the NEXT reminder
       await _createNextOccurrence(reminder);
       // The current one is just marked completed (and filtered out from used slots)
    }

    await updateReminder(updatedReminder);
  }

  Future<void> _createNextOccurrence(Reminder current) async {
    DateTime? nextDate = _calculateNextDate(current);
    
    if (nextDate != null) {
      final newReminder = Reminder(
        id: '', // New ID will be generated
        title: current.title,
        description: current.description,
        eventDate: nextDate,
        isCompleted: false, // New one is active
        categoryId: current.categoryId,
        recurrence: current.recurrence, // Keep looping
        recurrenceValue: current.recurrenceValue, // Keep anchor day / interval
        recurrenceUnit: current.recurrenceUnit,
      );
      
      await UnifiedDatabaseService.insertReminder(newReminder);
      await NotificationService().scheduleNotification(newReminder);
    }
  }

  DateTime? _calculateNextDate(Reminder reminder) {
    final eventDate = reminder.eventDate;
    
    switch (reminder.recurrence) {
      case RecurrenceType.daily:
        return eventDate.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return eventDate.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        // STICKY DATE LOGIC
        // recurrenceValue stores the "Anchor Day" (e.g., 31)
        final anchorDay = reminder.recurrenceValue ?? eventDate.day;
        
        // Move to next month
        // We start from current record's eventDate. 
        // Note: Use DateTime(year, month + 1) handles year rollover automatically
        var targetMonth = DateTime(eventDate.year, eventDate.month + 1, 1);
        
        // Find last day of that target month
        var lastDayOfTargetMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
        
        // Actual day is min(anchorDay, lastDayOfTargetMonth)
        // e.g. Anchor 31, Feb has 28 -> use 28.
        // e.g. Anchor 31, Apr has 30 -> use 30.
        // e.g. Anchor 31, Mar has 31 -> use 31.
        var actualDay = anchorDay > lastDayOfTargetMonth ? lastDayOfTargetMonth : anchorDay;
        
        return DateTime(
          targetMonth.year, 
          targetMonth.month, 
          actualDay, 
          eventDate.hour, 
          eventDate.minute
        );
        
      case RecurrenceType.yearly:
        return DateTime(
          eventDate.year + 1,
          eventDate.month,
          eventDate.day,
          eventDate.hour,
          eventDate.minute,
        );
      case RecurrenceType.custom:
        // Handle custom recurrence logic
        if (reminder.recurrenceValue == null || reminder.recurrenceUnit == null) return null;
        final value = reminder.recurrenceValue!;
        
        switch (reminder.recurrenceUnit!) {
           case RecurrenceUnit.day:
             return eventDate.add(Duration(days: value));
           case RecurrenceUnit.week:
             return eventDate.add(Duration(days: value * 7));
           case RecurrenceUnit.month:
             // Simple Add Month logic
             var newDate = DateTime(eventDate.year, eventDate.month + value, eventDate.day, eventDate.hour, eventDate.minute);
             // Handle simple overflow (e.g. Jan 31 + 1 month -> Mar 3 or Feb 28 depending on implementation of DateTime constructor)
             // Dart DateTime handles overflow by wrapping. Jan 31 + 1 month -> Feb 31 -> March 3 (non-leap)
             // If we want "last day", we'd need similar logic, but for "Custom" simple addition might be enough 
             // or we apply sticky logic if needed. For now sticking to simple DateTime addition behavior or 
             // better: use the same month logic if we want consistency.
             // Let's stick to safe month addition that clamps:
              var targetMonth = DateTime(eventDate.year, eventDate.month + value, 1);
              var lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
              var day = eventDate.day > lastDay ? lastDay : eventDate.day;
              return DateTime(targetMonth.year, targetMonth.month, day, eventDate.hour, eventDate.minute);

           case RecurrenceUnit.year:
             return DateTime(eventDate.year + value, eventDate.month, eventDate.day, eventDate.hour, eventDate.minute);
        }
      case RecurrenceType.none:
        return null;
    }
  }

  Future<void> removeReminder(String id) async {
    await NotificationService().cancelNotification(id);
    await UnifiedDatabaseService.deleteReminder(id);
  }
}

final reminderListProvider = NotifierProvider<ReminderListNotifier, List<Reminder>>(
  ReminderListNotifier.new,
);
