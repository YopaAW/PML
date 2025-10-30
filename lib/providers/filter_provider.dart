import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart' as app_models;

// Provider for the selected month filter
final selectedMonthProvider = StateProvider<DateTime?>((ref) => null);

// Provider for the selected category filter
final selectedCategoryProvider = StateProvider<app_models.Category?>((ref) => null);
