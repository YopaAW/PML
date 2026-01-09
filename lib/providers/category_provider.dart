import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingatin/models/category_model.dart' as app_models;
import 'package:ingatin/services/unified_database_service.dart';
import 'package:ingatin/providers/subscription_provider.dart';
import 'package:ingatin/providers/auth_provider.dart';

// Simulate subscription status

class CategoryNotifier extends AsyncNotifier<List<app_models.Category>> {
  @override
  Future<List<app_models.Category>> build() async {
    // Watch auth state to trigger rebuild on login/logout
    ref.watch(authStateProvider);
    
    try {
      // Ensure database is initialized (seeds defaults if needed)
      await UnifiedDatabaseService.init().timeout(const Duration(seconds: 3));
      
      // First, get the initial list of categories
      final initialCategories = await UnifiedDatabaseService.getAllCategories();
      
      // Then, listen for changes and update the state
      final subscription = UnifiedDatabaseService.watchAllCategories().listen((categories) {
        state = AsyncData(categories);
      });
      
      // Dispose subscription when provider is disposed
      ref.onDispose(() {
        subscription.cancel();
      });
      
      return initialCategories;
    } catch (e, stack) {
      debugPrint("CategoryNotifier build failed: $e");
      // Fallback: try direct local storage if Unified fails
      try {
        return await UnifiedDatabaseService.getAllCategories();
      } catch (_) {
        return []; // Last resort
      }
    }
  }

  Future<bool> addCustomCategory(String name) async {
    try {
      final isSubscribed = ref.read(isSubscribedProvider);
      if (!isSubscribed) {
        return false;
      }

      final newCategory = app_models.Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate String ID from timestamp
        name: name,
        isCustom: true,
        isPremium: false, // Custom categories are not premium content
      );
      await UnifiedDatabaseService.insertCategory(newCategory);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCategory(app_models.Category category) async {
    await UnifiedDatabaseService.updateCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    await UnifiedDatabaseService.deleteCategory(id);
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
