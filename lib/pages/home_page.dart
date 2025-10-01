import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tonton provider 'reminderListProvider' yang mengembalikan List<Reminder>.
    final reminders = ref.watch(reminderListProvider);

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
          ],
        ),
      ),
      body: reminders.isEmpty
          ? const Center(child: Text('Ketuk + untuk menambah pengingat.'))
          : ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                final formatted = DateFormat('dd MMM yyyy, HH:mm').format(reminder.eventDate);
                return ListTile(
                  title: Text(reminder.title),
                  subtitle: Text('Jadwal: $formatted'),
                  trailing: Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) {
                      ref
                          .read(reminderListProvider.notifier)
                          .toggle(reminder.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}