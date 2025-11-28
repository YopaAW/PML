import 'package:hive_flutter/hive_flutter.dart';

import 'models/reminder_model.dart';
import 'models/category_model.dart' as app_models;


class DatabaseService {
  static late Box<Reminder> _remindersBox;
  static late Box<app_models.Category> _categoriesBox;
  static late Box _userDataBox; // Box for general user data
  
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(ReminderAdapter());
    Hive.registerAdapter(app_models.CategoryAdapter());
    
    // Open boxes
    _remindersBox = await Hive.openBox<Reminder>('reminders');
    _categoriesBox = await Hive.openBox<app_models.Category>('categories');
    _userDataBox = await Hive.openBox('userData');
    
    // Initialize default categories if empty
    if (_categoriesBox.isEmpty) {
      await _initializeDefaultCategories();
    }
  }
  
  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      app_models.Category(
        id: 1,
        name: 'Pribadi',
        isCustom: false,
        isPremium: false,
      ),
      app_models.Category(
        id: 2,
        name: 'Kerja',
        isCustom: false,
        isPremium: false,
      ),
      app_models.Category(
        id: 3,
        name: 'Kesehatan',
        isCustom: false,
        isPremium: false,
      ),
      app_models.Category(
        id: 4,
        name: 'Belanja',
        isCustom: false,
        isPremium: false,
      ),
    ];
    
    for (final category in defaultCategories) {
      await _categoriesBox.put(category.id, category);
    }
  }
  
  // Reminder operations
  static Future<List<Reminder>> getAllReminders() async {
    return _remindersBox.values.toList();
  }
  
  static Stream<List<Reminder>> watchAllReminders() {
    return _remindersBox.watch().map((event) => _remindersBox.values.toList());
  }
  
  static Future<Reminder?> getReminderById(int id) async {
    return _remindersBox.get(id);
  }
  
  static Future<Reminder> insertReminder(Reminder reminder) async {
    final id = await _remindersBox.add(reminder);
    final updatedReminder = reminder.copyWith(id: id);
    await _remindersBox.put(id, updatedReminder);
    return updatedReminder;
  }
  
  static Future<bool> updateReminder(Reminder reminder) async {
    await _remindersBox.put(reminder.id, reminder);
    return true;
  }
  
  static Future<bool> deleteReminder(int id) async {
    await _remindersBox.delete(id);
    return true;
  }
  
  // Category operations
  static Future<List<app_models.Category>> getAllCategories() async {
    return _categoriesBox.values.toList();
  }
  
  static Stream<List<app_models.Category>> watchAllCategories() {
    return _categoriesBox.watch().map((event) => _categoriesBox.values.toList());
  }
  
  static Future<app_models.Category?> getCategoryById(int id) async {
    return _categoriesBox.get(id);
  }
  
  static Future<int> insertCategory(app_models.Category category) async {
    final id = await _categoriesBox.add(category);
    final updatedCategory = category.copyWith(id: id);
    await _categoriesBox.put(id, updatedCategory);
    return id;
  }
  
  static Future<bool> updateCategory(app_models.Category category) async {
    await _categoriesBox.put(category.id, category);
    return true;
  }
  
  static Future<bool> deleteCategory(int id) async {
    await _categoriesBox.delete(id);
    return true;
  }


  
  static Future<void> close() async {
    await _remindersBox.close();
    await _categoriesBox.close();
    await _userDataBox.close();
  }
}
