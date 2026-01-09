import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../models/category_model.dart';
import '../constants.dart';

/// Local storage service untuk guest mode
/// OPTIMIZED: Menambahkan dispose method untuk prevent memory leak
class LocalStorageService {
  // StreamControllers for broadcasting changes
  static final _remindersController = StreamController<List<Reminder>>.broadcast();
  static final _categoriesController = StreamController<List<Category>>.broadcast();

  // Streams
  static Stream<List<Reminder>> get remindersStream => _remindersController.stream;
  static Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  // Dispose method untuk cleanup
  static void dispose() {
    if (!_remindersController.isClosed) {
      _remindersController.close();
    }
    if (!_categoriesController.isClosed) {
      _categoriesController.close();
    }
  }

  // Check if user is in guest mode
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.guestModeKey) ?? false;
  }

  // Set guest mode
  static Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.guestModeKey, value);
  }

  // Initialize default categories for guest
  static Future<void> initDefaultCategories() async {
    final categories = await getAllCategories();
    if (categories.isEmpty) {
      final defaultCategories = DefaultCategories.categories.map((data) {
        return Category(
          id: data['id'] as String,
          name: data['name'] as String,
          isCustom: data['isCustom'] as bool,
          isPremium: data['isPremium'] as bool,
        );
      }).toList();
      
      for (final category in defaultCategories) {
        await insertCategory(category);
      }
    }
  }

  // Reminder operations
  static Future<List<Reminder>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString(AppConstants.localRemindersKey);
    
    if (remindersJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(remindersJson);
    return decoded.map((json) => Reminder.fromJson(json)).toList();
  }

  static Future<Reminder?> getReminderById(String id) async {
    final reminders = await getAllReminders();
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<Reminder> insertReminder(Reminder reminder) async {
    final reminders = await getAllReminders();
    final newReminder = reminder.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    reminders.add(newReminder);
    await _saveReminders(reminders);
    return newReminder;
  }

  static Future<void> updateReminder(Reminder reminder) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await _saveReminders(reminders);
    }
  }

  static Future<void> deleteReminder(String id) async {
    final reminders = await getAllReminders();
    reminders.removeWhere((r) => r.id == id);
    await _saveReminders(reminders);
  }

  static Future<void> _saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await prefs.setString(AppConstants.localRemindersKey, encoded);
    
    // Emit to stream only if not closed
    if (!_remindersController.isClosed) {
      _remindersController.add(reminders);
    }
  }

  // Category operations
  static Future<List<Category>> getAllCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesJson = prefs.getString(AppConstants.localCategoriesKey);
    
    if (categoriesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(categoriesJson);
    return decoded.map((json) => Category.fromJson(json)).toList();
  }

  static Future<Category?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<String> insertCategory(Category category) async {
    final categories = await getAllCategories();
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: category.name,
      isCustom: category.isCustom,
      isPremium: category.isPremium,
    );
    categories.add(newCategory);
    await _saveCategories(categories);
    return newCategory.id;
  }

  static Future<void> updateCategory(Category category) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await _saveCategories(categories);
    }
  }

  static Future<void> deleteCategory(String id) async {
    final categories = await getAllCategories();
    categories.removeWhere((c) => c.id == id);
    await _saveCategories(categories);
  }

  static Future<void> _saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(AppConstants.localCategoriesKey, encoded);
    
    // Emit to stream only if not closed
    if (!_categoriesController.isClosed) {
      _categoriesController.add(categories);
    }
  }

  // Clear all local data
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.localRemindersKey);
    await prefs.remove(AppConstants.localCategoriesKey);
    await prefs.remove(AppConstants.guestModeKey);
  }
}
