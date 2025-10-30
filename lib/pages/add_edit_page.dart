import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import '../models/category_model.dart' as app_models;

class AddEditPage extends ConsumerStatefulWidget {
  final Reminder? reminder;
  const AddEditPage({super.key, this.reminder});

  @override
  ConsumerState<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends ConsumerState<AddEditPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  app_models.Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description ?? '';
      _selectedDate = widget.reminder!.eventDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.eventDate);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final categories = ref.read(categoryListProvider).asData?.value;
          if (categories != null && widget.reminder!.categoryId != null) {
            final matchingCategory = categories.where((cat) => cat.id == widget.reminder!.categoryId);
            if (matchingCategory.isNotEmpty) {
              setState(() {
                _selectedCategory = matchingCategory.first;
              });
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

    if (widget.reminder != null) {
      final updatedReminder = widget.reminder!.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        eventDate: eventDate,
        categoryId: _selectedCategory?.id,
      );
      await ref.read(reminderListProvider.notifier).updateReminder(updatedReminder);
      if (eventDate.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          updatedReminder.id,
          updatedReminder.title,
          updatedReminder.description ?? '',
          eventDate,
        );
      }
    } else {
      final newReminder = await ref
          .read(reminderListProvider.notifier)
          .addReminder(_titleController.text, eventDate, categoryId: _selectedCategory?.id, description: _descriptionController.text);
      if (eventDate.isAfter(DateTime.now())) {
        await NotificationService().scheduleNotification(
          newReminder.id,
          newReminder.title,
          newReminder.description ?? '',
          eventDate,
        );
      }
    }

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
        title: Text(widget.reminder == null ? 'Pengingat Baru' : 'Edit Pengingat'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  if (isSubscribed)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddCategoryDialog,
                    ),
                ],
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
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
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
                        initialTime: _selectedTime ?? TimeOfDay.now(),
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
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}