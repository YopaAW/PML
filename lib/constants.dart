/// Constants untuk aplikasi Ingat.in
/// Centralized location untuk semua magic numbers dan strings
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Premium & Slots
  static const int defaultLoopingSlots = 10;
  static const int freeLoopingSlots = 10;

  // SharedPreferences Keys
  static const String guestModeKey = 'guest_mode';
  static const String localRemindersKey = 'local_reminders';
  static const String localCategoriesKey = 'local_categories';
  static const String premiumSlotsKey = 'premium_looping_slots';
  static const String themeModeKey = 'theme_mode';
  static const String colorPaletteKey = 'color_palette';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String remindersCollection = 'reminders';
  static const String categoriesCollection = 'categories';
  static const String premiumCollection = 'premium';
  static const String premiumDataDoc = 'data';

  // Notification
  static const String notificationChannelId = 'ingatin_channel_id';
  static const String notificationChannelName = 'Ingat.in Channel';
  static const String notificationChannelDescription = 'Channel for Ingat.in reminders';

  // Error Messages
  static const String errorUserNotAuthenticated = 'User not authenticated. Please sign in first.';
  static const String errorReminderNotFound = 'Reminder not found';
  static const String errorCategoryNotFound = 'Category not found';
  static const String errorNetworkFailure = 'Network error. Please check your connection.';
  static const String errorUnknown = 'An unexpected error occurred';
  
  // Success Messages
  static const String successReminderAdded = 'Pengingat berhasil ditambahkan';
  static const String successReminderUpdated = 'Pengingat berhasil diperbarui';
  static const String successReminderDeleted = 'Pengingat berhasil dihapus';
  static const String successCategoryAdded = 'Kategori berhasil ditambahkan';
  
  // UI Strings
  static const String appName = 'Ingat.in';
  static const String guestModeLabel = 'Guest Mode';
  static const String loginPrompt = 'Klik untuk login';
  
  // Timing
  static const int splashDuration = 2; // seconds
  static const int debounceMilliseconds = 300;
  static const int cacheExpirationMinutes = 5;
}

/// Default categories untuk aplikasi
class DefaultCategories {
  DefaultCategories._();

  static const List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'Pribadi', 'isCustom': false, 'isPremium': false},
    {'id': '2', 'name': 'Kerja', 'isCustom': false, 'isPremium': false},
    {'id': '3', 'name': 'Kesehatan', 'isCustom': false, 'isPremium': false},
    {'id': '4', 'name': 'Belanja', 'isCustom': false, 'isPremium': false},
    {'id': '5', 'name': 'Pendidikan', 'isCustom': false, 'isPremium': false},
    {'id': '6', 'name': 'Keluarga', 'isCustom': false, 'isPremium': false},
    {'id': '7', 'name': 'Olahraga', 'isCustom': false, 'isPremium': false},
    {'id': '8', 'name': 'Keuangan', 'isCustom': false, 'isPremium': false},
    {'id': '9', 'name': 'Hiburan', 'isCustom': false, 'isPremium': false},
    {'id': '10', 'name': 'Lainnya', 'isCustom': false, 'isPremium': false},
  ];
}
