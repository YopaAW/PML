import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ingatin/models/reminder_model.dart' as models;
import 'package:ingatin/models/category_model.dart' as models;
import 'package:ingatin/services/local_storage_service.dart';

/// Unified database service that handles both Firebase and local storage
/// based on user authentication status
/// 
/// OPTIMIZED: Menggunakan caching untuk menghindari pengecekan berulang
class UnifiedDatabaseService {
  // Singleton instance
  static final UnifiedDatabaseService _instance = UnifiedDatabaseService._internal();
  factory UnifiedDatabaseService() => _instance;
  UnifiedDatabaseService._internal();

  // Helper properties
  static bool get _isAuthenticated => FirebaseAuth.instance.currentUser != null;

  // Invalidate cache (kept for compatibility but no-op now)
  static void invalidateCache() {
    // No cache to invalidate
  }

  // Initialize database
  static Future<void> init() async {
    try {
      // Still init Firebase Auth/User if needed for UI, but data will be local
      if (_isAuthenticated) {
         try {
           await FirebaseAuth.instance.currentUser?.reload();
         } catch (_) {
           // Ignore network errors in init
         }
      }
      
      // Always init default categories for local storage
      await LocalStorageService.initDefaultCategories();
    } catch (e) {
      debugPrint("Database init failed but continuing with defaults: $e");
    }
  }

  // Reminder operations
  static Future<List<models.Reminder>> getAllReminders() async {
    try {
      return await LocalStorageService.getAllReminders();
    } catch (e) {
      debugPrint("Error fetching local reminders: $e");
      return [];
    }
  }

  static Stream<List<models.Reminder>> watchAllReminders() async* {
    try {
      // Emit initial data
      yield await LocalStorageService.getAllReminders();
    } catch (_) {}
    
    // Then listen to stream for updates
    yield* LocalStorageService.remindersStream;
  }

  static Future<models.Reminder?> getReminderById(String id) async {
    try {
      return await LocalStorageService.getReminderById(id);
    } catch (_) {
      return null;
    }
  }

  static Future<models.Reminder> insertReminder(models.Reminder reminder) async {
    return await LocalStorageService.insertReminder(reminder);
  }

  static Future<void> updateReminder(models.Reminder reminder) async {
    await LocalStorageService.updateReminder(reminder);
  }

  static Future<void> deleteReminder(String id) async {
    await LocalStorageService.deleteReminder(id);
  }

  // Category operations
  static Future<List<models.Category>> getAllCategories() async {
    try {
      final categories = await LocalStorageService.getAllCategories();
      if (categories.isEmpty) {
        await LocalStorageService.initDefaultCategories();
        return await LocalStorageService.getAllCategories();
      }
      return categories;
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      return [];
    }
  }

  static Stream<List<models.Category>> watchAllCategories() async* {
    try {
      final initial = await getAllCategories();
      yield initial;
    } catch (_) {}
    
    yield* LocalStorageService.categoriesStream;
  }

  static Future<models.Category?> getCategoryById(String id) async {
    return await LocalStorageService.getCategoryById(id);
  }

  static Future<String> insertCategory(models.Category category) async {
    return await LocalStorageService.insertCategory(category);
  }

  static Future<void> updateCategory(models.Category category) async {
    await LocalStorageService.updateCategory(category);
  }

  static Future<void> deleteCategory(String id) async {
    await LocalStorageService.deleteCategory(id);
  }
}
