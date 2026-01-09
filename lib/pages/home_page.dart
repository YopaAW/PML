import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart' as app_models;
import '../providers/filter_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart'; // Added for logout
import '../services/unified_database_service.dart'; // Added for cache invalidation
import '../services/local_storage_service.dart'; // Added for guest mode clearing

import '../widgets/reminder_card.dart';
import '../widgets/color_selection_bottom_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReminders = ref.watch(reminderListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final theme = Theme.of(context);
    

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
              // User Profile Header
            if (ref.watch(currentUserProvider) != null)
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  image: DecorationImage(
                    image: const AssetImage('assets/header_bg.png'), // Optional
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(theme.primaryColor.withValues(alpha: 0.8), BlendMode.srcOver),
                  ),
                ),
                accountName: Text(
                  ref.watch(userDisplayNameProvider) ?? 'Pengguna',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(ref.watch(userEmailProvider) ?? ''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: ref.watch(userPhotoURLProvider) != null
                      ? NetworkImage(ref.watch(userPhotoURLProvider)!)
                      : null,
                  child: ref.watch(userPhotoURLProvider) == null
                      ? Text(
                          (ref.watch(userDisplayNameProvider) ?? 'U')[0].toUpperCase(),
                          style: TextStyle(fontSize: 24, color: theme.primaryColor),
                        )
                      : null,
                ),
                onDetailsPressed: () {
                   context.push('/profile');
                },
              )
            else
              DrawerHeader(
                decoration: BoxDecoration(color: theme.primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline, size: 30),
                    ),
                    const SizedBox(height: 10),
                    const Text('Mode Tamu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Login untuk fitur awan', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Ingat.in'),
              onTap: () => context.go('/'),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah'),
              onTap: () => context.go('/add'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kelola Kategori'),
              onTap: () => context.go('/categories'),
            ),

            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Pilih Warna'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const ColorSelectionBottomSheet(),
                );
              },
            ),
            ListTile(
              leading: Icon(theme.brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode),
              title: Text(theme.brightness == Brightness.dark ? 'Mode Gelap' : 'Mode Terang'),
              trailing: Switch(
                value: theme.brightness == Brightness.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.amber),
              title: const Text('Slot Plus'),
              onTap: () => context.go('/slot'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () => context.go('/about'),
            ),
            const Divider(),
            if (ref.watch(currentUserProvider) == null)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.green),
                title: const Text('Login / Daftar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                onTap: () => context.push('/login'),
              ),
          ],
        ),
      ),
      body: CustomScrollView(

        slivers: [
          SliverAppBar(
            title: const Text('Ingat.in'),
            floating: true,
            pinned: true,
            snap: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterBottomSheet(context, ref),
              ),
            ],
          ),
          categoriesAsync.when(
            data: (categories) {
              if (filteredReminders.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 100, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'Tidak ada pengingat',
                          style: TextStyle(fontSize: 22, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tekan tombol + untuk menambahkan pengingat baru.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final reminder = filteredReminders[index];
                    final category = categories.firstWhere(
                      (cat) => cat.id == reminder.categoryId,
                      orElse: () => const app_models.Category(id: '-1', name: 'Tidak Berkategori'),
                    );
                    return ReminderCard(reminder: reminder, category: category);
                  },
                  childCount: filteredReminders.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => const SliverFillRemaining(child: Center(child: Text('Error memuat kategori'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoryListProvider).asData?.value ?? [];
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final allReminders = ref.read(reminderListProvider);
    final uniqueMonths = allReminders.map((r) => DateTime(r.eventDate.year, r.eventDate.month)).toSet().toList();
    uniqueMonths.sort((a, b) => b.compareTo(a));

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Pengingat', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(selectedMonthProvider.notifier).state = null;
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hapus Filter'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}

