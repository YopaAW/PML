import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart'; // Import category provider
import '../models/category_model.dart' as app_models; // Import category model

class AddEditPage extends ConsumerStatefulWidget {
  const AddEditPage({super.key});

  @override
  ConsumerState<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends ConsumerState<AddEditPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  app_models.Category? _selectedCategory; // New state variable for selected category

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveReminder() async {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan tanggal harus diisi!')),
      );
      return;
    }

    final time = _selectedTime ?? TimeOfDay.now();
    final eventDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      time.hour,
      time.minute,
    );

    await ref
        .read(reminderListProvider.notifier)
        .addReminder(_titleController.text, eventDate, categoryId: _selectedCategory?.id);

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final newCategoryNameController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
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
              child: const Text('Tambah'),
              onPressed: () async {
                if (newCategoryNameController.text.isNotEmpty) {
                  await ref.read(categoryListProvider.notifier).addCustomCategory(newCategoryNameController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = ref.watch(availableCategoriesProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Baru'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveReminder,
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
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/about');
              },
            ),
            // Toggle Subscription Status for testing
            ListTile(
              leading: Icon(isSubscribed ? Icons.star : Icons.star_border),
              title: Text(isSubscribed ? 'Berlangganan' : 'Gratis'),
              onTap: () {
                ref.read(isSubscribedProvider.notifier).state = !isSubscribed;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih Tanggal'
                        : 'Tanggal: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'Pilih Waktu'
                        : 'Waktu: ${_selectedTime!.format(context)}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<app_models.Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    hint: Text('Pilih Kategori (${availableCategories.length} tersedia)'),
                    items: availableCategories.map((category) {
                      return DropdownMenuItem<app_models.Category>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (app_models.Category? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                ),
                if (isSubscribed) // Only show add button for subscribed users
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddCategoryDialog,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}