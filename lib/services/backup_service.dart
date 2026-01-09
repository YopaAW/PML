import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/reminder_model.dart';
import '../models/category_model.dart' as app_models;
import 'unified_database_service.dart';
import 'local_storage_service.dart';

class BackupService {
  // Export data to JSON
  static Future<String> exportToJson() async {
    final reminders = await UnifiedDatabaseService.getAllReminders();
    final categories = await UnifiedDatabaseService.getAllCategories();

    final data = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
    };

    return jsonEncode(data);
  }

  // Export and save to file
  static Future<File> exportToFile() async {
    final jsonString = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/ingatin_backup_$timestamp.json');
    
    await file.writeAsString(jsonString);
    return file;
  }

  // Export and share
  static Future<void> exportAndShare() async {
    final file = await exportToFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Ingat.in Backup',
      text: 'Backup data Ingat.in - ${DateTime.now().toString()}',
    );
  }

  // Import data from JSON
  static Future<Map<String, dynamic>> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final remindersList = (data['reminders'] as List)
          .map((json) => Reminder.fromJson(json))
          .toList();
      
      final categoriesList = (data['categories'] as List)
          .map((json) => app_models.Category.fromJson(json))
          .toList();

      return {
        'reminders': remindersList,
        'categories': categoriesList,
        'count': remindersList.length + categoriesList.length,
      };
    } catch (e) {
      throw Exception('Format file tidak valid: $e');
    }
  }

  // Import and restore data
  static Future<void> importAndRestore(String jsonString, {bool merge = false}) async {
    final imported = await importFromJson(jsonString);
    final reminders = imported['reminders'] as List<Reminder>;
    final categories = imported['categories'] as List<app_models.Category>;

    if (!merge) {
      // Clear existing data first (replace mode)
      final existingReminders = await UnifiedDatabaseService.getAllReminders();
      for (final reminder in existingReminders) {
        await UnifiedDatabaseService.deleteReminder(reminder.id);
      }
      
      final existingCategories = await UnifiedDatabaseService.getAllCategories();
      for (final category in existingCategories) {
        if (category.isCustom) {
          await UnifiedDatabaseService.deleteCategory(category.id);
        }
      }
    }

    // Import categories first
    for (final category in categories) {
      if (category.isCustom) {
        await UnifiedDatabaseService.insertCategory(category);
      }
    }

    // Import reminders
    for (final reminder in reminders) {
      await UnifiedDatabaseService.insertReminder(reminder);
    }
  }

  // Get data info
  static Future<Map<String, int>> getDataInfo() async {
    final reminders = await UnifiedDatabaseService.getAllReminders();
    final categories = await UnifiedDatabaseService.getAllCategories();

    return {
      'reminders': reminders.length,
      'categories': categories.length,
      'customCategories': categories.where((c) => c.isCustom).length,
    };
  }

  // Manual sync (force refresh from cloud for logged-in users)
  static Future<void> manualSync() async {
    // This will trigger a refresh from the database
    // The UnifiedDatabaseService will handle whether it's Firebase or local
    await UnifiedDatabaseService.init();
  }

  // Get last sync time (for logged-in users)
  static Future<DateTime?> getLastSyncTime() async {
    final isGuest = await LocalStorageService.isGuestMode();
    if (isGuest) return null;
    
    // Return current time as last sync (since Firebase is real-time)
    return DateTime.now();
  }
}
