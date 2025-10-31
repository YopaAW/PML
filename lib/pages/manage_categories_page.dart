import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/remaining_time_provider.dart';
import '../models/category_model.dart' as app_models;

class ManageCategoriesPage extends ConsumerWidget {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final remainingTimeAsync = ref.watch(remainingTimeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: isSubscribed
          ? Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status Langganan', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        remainingTimeAsync.when(
                          data: (time) => Text(time, style: theme.textTheme.bodyLarge),
                          loading: () => const CircularProgressIndicator(),
                          error: (err, stack) => Text('Error: $err', style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text('Belum ada kategori kustom.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(category.name, style: theme.textTheme.bodyLarge),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary),
                                    onPressed: () => _showAddEditCategoryDialog(context, ref, category: category),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                                    onPressed: () => _showDeleteConfirmationDialog(context, ref, category),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const Center(child: Text('Error memuat kategori')),
                  ),
                ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 100, color: theme.disabledColor),
                    const SizedBox(height: 20),
                    Text(
                      'Fitur ini hanya untuk pengguna premium.',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Dengan berlangganan, Anda dapat membuat, mengedit, dan menghapus kategori Anda sendiri.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/subscription'),
                      child: const Text('Berlangganan Sekarang'),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: isSubscribed
          ? FloatingActionButton(
              onPressed: () => _showAddEditCategoryDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _showAddEditCategoryDialog(BuildContext context, WidgetRef ref, {app_models.Category? category}) async {
    final newCategoryNameController = TextEditingController(text: category?.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: TextField(
            controller: newCategoryNameController,
            decoration: const InputDecoration(hintText: 'Nama Kategori'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () async {
                if (newCategoryNameController.text.isNotEmpty) {
                  if (category == null) {
                    await ref.read(categoryListProvider.notifier).addCustomCategory(newCategoryNameController.text);
                  } else {
                    final updatedCategory = category.copyWith(name: newCategoryNameController.text);
                    await ref.read(categoryListProvider.notifier).updateCategory(updatedCategory);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, app_models.Category category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Kategori'),
          content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Hapus'),
              onPressed: () async {
                await ref.read(categoryListProvider.notifier).deleteCategory(category.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}