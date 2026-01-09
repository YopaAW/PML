import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder_model.dart';
import '../models/category_model.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Get current user ID from Firebase Auth
  static String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }
    return user.uid;
  }

  static CollectionReference<Map<String, dynamic>> get _remindersRef =>
      _db.collection('users').doc(_userId).collection('reminders');

  static CollectionReference<Map<String, dynamic>> get _categoriesRef =>
      _db.collection('users').doc(_userId).collection('categories');

  static Future<void> init() async {
    // Cannot initialize user data if not logged in
    if (FirebaseAuth.instance.currentUser == null) return;

    try {
      // Check if categories exist, if not initialize defaults
      final snapshot = await _categoriesRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        await _initializeDefaultCategories();
      }
    } catch (e) {
      // Prevent crash on initialization
      print('DatabaseService init error: $e');
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      const Category(
        id: '1',
        name: 'Pribadi',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '2',
        name: 'Kerja',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '3',
        name: 'Kesehatan',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '4',
        name: 'Belanja',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '5',
        name: 'Pendidikan',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '6',
        name: 'Keluarga',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '7',
        name: 'Olahraga',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '8',
        name: 'Keuangan',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '9',
        name: 'Hiburan',
        isCustom: false,
        isPremium: false,
      ),
      const Category(
        id: '10',
        name: 'Lainnya',
        isCustom: false,
        isPremium: false,
      ),
    ];

    final batch = _db.batch();
    for (final category in defaultCategories) {
      // Use the category.id as the document ID
      final docRef = _categoriesRef.doc(category.id);
      batch.set(docRef, category.toFirestore());
    }
    await batch.commit();
  }

  // Reminder operations
  static Future<List<Reminder>> getAllReminders() async {
    final snapshot = await _remindersRef.get();
    return snapshot.docs
        .map((doc) => Reminder.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Stream<List<Reminder>> watchAllReminders() {
    return _remindersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Reminder.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<Reminder?> getReminderById(String id) async {
    final doc = await _remindersRef.doc(id).get();
    if (doc.exists) {
      return Reminder.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Future<Reminder> insertReminder(Reminder reminder) async {
    // Create a new document reference
    final docRef = _remindersRef.doc();
    // Update the reminder with the new String ID (though we pass doc.id to fromFirestore)
    // We actually just need to write the data. 
    // The reminder object passed in might have an empty ID or temp ID.
    // We will return a new Reminder object with the valid ID.
    
    await docRef.set(reminder.toFirestore());
    
    return reminder.copyWith(id: docRef.id);
  }

  static Future<void> updateReminder(Reminder reminder) async {
    await _remindersRef.doc(reminder.id).update(reminder.toFirestore());
  }

  static Future<void> deleteReminder(String id) async {
    await _remindersRef.doc(id).delete();
  }

  // Category operations
  static Future<List<Category>> getAllCategories() async {
    final snapshot = await _categoriesRef.get();
    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Stream<List<Category>> watchAllCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  static Future<Category?> getCategoryById(String id) async {
    final doc = await _categoriesRef.doc(id).get();
    if (doc.exists) {
      return Category.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Future<String> insertCategory(Category category) async {
    final docRef = _categoriesRef.doc();
    await docRef.set(category.toFirestore());
    return docRef.id;
  }

  static Future<void> updateCategory(Category category) async {
    await _categoriesRef.doc(category.id).update(category.toFirestore());
  }

  static Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }
}
