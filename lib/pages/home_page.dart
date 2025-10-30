import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart' as app_models;
import '../providers/filter_provider.dart';
import '../providers/subscription_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(reminderListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final filteredReminders = allReminders.where((reminder) {
      final reminderDate = reminder.eventDate;
      final categoryId = reminder.categoryId;

      if (selectedMonth != null &&
          (reminderDate.month != selectedMonth.month || reminderDate.year != selectedMonth.year)) {
        return false;
      }

      if (selectedCategory != null && categoryId != selectedCategory.id) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingat.in'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Menu', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ingat.in'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/add');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kelola Kategori'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Berlangganan'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/subscription');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Donasi'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/donation');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/about');
              },
            ),
          ],
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return filteredReminders.isEmpty
              ? const Center(child: Text('Tidak ada pengingat atau filter tidak cocok.'))
              : ListView.builder(
                  itemCount: filteredReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = filteredReminders[index];
                    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(reminder.eventDate);
                    final categoryName = categories
                        .firstWhere(
                          (cat) => cat.id == reminder.categoryId,
                          orElse: () => const app_models.Category(id: -1, name: 'Tidak Berkategori'),
                        )
                        .name;

                    final subtitle = StringBuffer();
                    subtitle.write('Jadwal: $formattedDate - Kategori: $categoryName');
                    if (reminder.description != null && reminder.description!.isNotEmpty) {
                      subtitle.write('\n${reminder.description}');
                    }

                    return ListTile(
                      isThreeLine: reminder.description != null && reminder.description!.isNotEmpty,
                      leading: Checkbox(
                        value: reminder.isCompleted,
                        onChanged: (value) {
                          ref
                              .read(reminderListProvider.notifier)
                              .toggleCompletion(reminder.id);
                        },
                      ),
                      title: Text(reminder.title),
                      subtitle: Text(subtitle.toString()),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.go('/add', extra: reminder);
                          } else if (value == 'delete') {
                            ref
                                .read(reminderListProvider.notifier)
                                .removeReminder(reminder.id);
                          }
                        },
                      ),
                    );
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error memuat kategori')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoryListProvider).asData?.value ?? [];
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Get unique months from reminders
    final allReminders = ref.read(reminderListProvider);
    final uniqueMonths = allReminders.map((r) => DateTime(r.eventDate.year, r.eventDate.month)).toSet().toList();
    uniqueMonths.sort((a, b) => b.compareTo(a)); // Sort descending

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Pengingat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<DateTime>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: 'Bulan'),
                hint: const Text('Pilih Bulan'),
                items: uniqueMonths.map((month) {
                  return DropdownMenuItem<DateTime>(
                    value: month,
                    child: Text(DateFormat('MMMM yyyy').format(month)),
                  );
                }).toList(),
                onChanged: (DateTime? newValue) {
                  ref.read(selectedMonthProvider.notifier).state = newValue;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<app_models.Category>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                hint: const Text('Pilih Kategori'),
                items: categories.map((category) {
                  return DropdownMenuItem<app_models.Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (app_models.Category? newValue) {
                  ref.read(selectedCategoryProvider.notifier).state = newValue;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(selectedMonthProvider.notifier).state = null;
                ref.read(selectedCategoryProvider.notifier).state = null;
                Navigator.of(context).pop();
              },
              child: const Text('Hapus Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
