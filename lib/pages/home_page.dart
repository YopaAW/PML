import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart'; // Import category provider
import '../models/category_model.dart' as app_models; // Import category model

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(reminderListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingat.in'),
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
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/about');
              },
            ),
            // Toggle Subscription Status for testing
            ListTile(
              leading: Icon(ref.watch(isSubscribedProvider) ? Icons.star : Icons.star_border),
              title: Text(ref.watch(isSubscribedProvider) ? 'Berlangganan' : 'Gratis'),
              onTap: () {
                ref.read(isSubscribedProvider.notifier).state = !ref.read(isSubscribedProvider);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return reminders.isEmpty
              ? const Center(child: Text('Ketuk + untuk menambah pengingat.'))
              : ListView.builder(
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(reminder.eventDate);
                    final categoryName = categories
                        .firstWhere(
                          (cat) => cat.id == reminder.categoryId,
                          orElse: () => const app_models.Category(id: -1, name: 'Tidak Berkategori'),
                        )
                        .name;

                    return ListTile(
                      title: Text(reminder.title),
                      subtitle: Text('Jadwal: $formattedDate - Kategori: $categoryName'),
                      trailing: Checkbox(
                        value: reminder.isCompleted,
                        onChanged: (value) {
                          ref
                              .read(reminderListProvider.notifier)
                              .toggleCompletion(reminder.id);
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
}