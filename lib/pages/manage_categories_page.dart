import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/category_provider.dart';
import '../providers/subscription_provider.dart';
import '../models/category_model.dart' as app_models;

class ManageCategoriesPage extends ConsumerStatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  ConsumerState<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends ConsumerState<ManageCategoriesPage> {
  Timer? _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final subscriptionEndDate = ref.read(subscriptionEndDateProvider);
    if (subscriptionEndDate != null && subscriptionEndDate.year != 9999) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (subscriptionEndDate.isAfter(now)) {
          final remaining = subscriptionEndDate.difference(now);
          if (mounted) {
            setState(() {
              _remainingTime = _formatDuration(remaining);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _remainingTime = 'Langganan telah berakhir';
            });
          }
          _timer?.cancel();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$days hari, $hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final subscriptionEndDate = ref.watch(subscriptionEndDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: isSubscribed
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Langganan:', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      subscriptionEndDate!.year == 9999
                          ? const Text('Premium Selamanya')
                          : Text(_remainingTime),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: categoriesAsync.when(
                    data: (categories) {
                      return ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            title: Text(category.name),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showAddEditCategoryDialog(context, ref, category: category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteConfirmationDialog(context, ref, category),
                                ),
                              ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Fitur ini hanya tersedia untuk pengguna premium.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/subscription'),
                    child: const Text('Berlangganan Sekarang'),
                  ),
                ],
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
          title: Text(category == null ? 'Tambah Kategori Baru' : 'Edit Kategori'),
          content: TextField(
            controller: newCategoryNameController,
            decoration: const InputDecoration(hintText: 'Nama Kategori'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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