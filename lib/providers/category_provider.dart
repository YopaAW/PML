import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart' as app_models;
import '../database_hive.dart'; // Import the Hive database
import 'subscription_provider.dart';

// Simulate subscription status

class CategoryNotifier extends AsyncNotifier<List<app_models.Category>> {
  @override
  Future<List<app_models.Category>> build() async {
    // First, get the initial list of categories
    final initialCategories = await DatabaseService.getAllCategories();
    
    // Then, listen for changes and update the state
    DatabaseService.watchAllCategories().listen((categories) {
      state = AsyncData(categories);
    });
    
    return initialCategories;
  }

  Future<void> addCustomCategory(String name) async {
    final isSubscribed = ref.read(isSubscribedProvider);
    if (!isSubscribed) {
      // Optionally, show a message to the user that this is a premium feature
      return;
    }

    final newCategory = app_models.Category(
      id: 0, // Will be updated by insertCategory
      name: name,
      isCustom: true,
      isPremium: false, // Custom categories are not premium content
    );
    await DatabaseService.insertCategory(newCategory);
  }

  Future<void> updateCategory(app_models.Category category) async {
    await DatabaseService.updateCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await DatabaseService.deleteCategory(id);
  }
}

final categoryListProvider = AsyncNotifierProvider<CategoryNotifier, List<app_models.Category>>(
  CategoryNotifier.new,
);

// Provider for available categories based on subscription status
final availableCategoriesProvider = Provider<List<app_models.Category>>((ref) {
  final categories = ref.watch(categoryListProvider);
  final isSubscribed = ref.watch(isSubscribedProvider);
  
  return categories.when(
    data: (categoryList) {
      if (isSubscribed) {
        return categoryList;
      } else {
        return categoryList.where((category) => !category.isPremium && !category.isCustom).toList();
      }
    },
    loading: () => [],
    error: (err, stack) => [],
  );
});
