import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart';

import '../models/category_model.dart' as app_models;

class AddEditPage extends ConsumerStatefulWidget {
  final String? reminderId; // Changed from Reminder? reminder
  const AddEditPage({super.key, this.reminderId});

  @override
  ConsumerState<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends ConsumerState<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  app_models.Category? _selectedCategory;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;
  final _recurrenceValueController = TextEditingController();
  RecurrenceUnit _selectedRecurrenceUnit = RecurrenceUnit.day;

  Reminder?
      _existingReminder; // To hold the fetched reminder for the update logic

  @override
  void initState() {
    super.initState();
    // If a reminderId is passed, we are in "edit" mode.
    if (widget.reminderId != null) {
      // Use addPostFrameCallback to safely access providers in initState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final reminders = ref.read(reminderListProvider);
        try {
          final reminderToEdit = reminders
              .firstWhere((r) => r.id == int.parse(widget.reminderId!));
          _existingReminder = reminderToEdit;

          // Populate the form fields with the existing reminder data
          _titleController.text = reminderToEdit.title;
          _descriptionController.text = reminderToEdit.description ?? '';
          _selectedDate = reminderToEdit.eventDate;
          _selectedTime = TimeOfDay.fromDateTime(reminderToEdit.eventDate);
          _selectedRecurrence = reminderToEdit.recurrence;
          if (reminderToEdit.recurrence == RecurrenceType.custom) {
            _recurrenceValueController.text = reminderToEdit.recurrenceValue.toString();
            _selectedRecurrenceUnit = reminderToEdit.recurrenceUnit!;
          }

          // Populate the category dropdown
          final categories = ref.read(categoryListProvider).asData?.value;
          if (categories != null && reminderToEdit.categoryId != null) {
            final matchingCategory = categories
                .where((cat) => cat.id == reminderToEdit.categoryId);
            if (matchingCategory.isNotEmpty) {
              setState(() {
                _selectedCategory = matchingCategory.first;
              });
            }
          } else {
            // Rerender to show populated fields even if category isn't found
            setState(() {});
          }
        } catch (e) {
          // Handle case where reminder with the given ID is not found
          print('Error finding reminder with ID ${widget.reminderId}: $e');
          // Optionally, navigate back or show an error message
          if (mounted) context.go('/');
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _recurrenceValueController.dispose();
    super.dispose();
  }

  void _saveReminder() async {
    print("Saving reminder...");
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      print("Form is valid and date is selected.");
      final time = _selectedTime ?? TimeOfDay.now();
      final eventDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        time.hour,
        time.minute,
      );
      print("Event date: $eventDate");

      // Check if we are updating an existing reminder
      if (_existingReminder != null) {
        print("Updating existing reminder.");
        final updatedReminder = _existingReminder!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          eventDate: eventDate,
          categoryId: _selectedCategory?.id,
          recurrence: _selectedRecurrence,
          recurrenceValue: _selectedRecurrence == RecurrenceType.custom ? int.tryParse(_recurrenceValueController.text) : null,
          recurrenceUnit: _selectedRecurrence == RecurrenceType.custom ? _selectedRecurrenceUnit : null,
        );
        await ref
            .read(reminderListProvider.notifier)
            .updateReminder(updatedReminder);
        print("Reminder updated.");
        // await NotificationService().scheduleNotification(updatedReminder);
      } else {
        // Otherwise, we are adding a new reminder
        print("Adding new reminder.");
            ref.read(reminderListProvider.notifier).addReminder(
                  _titleController.text,
                  eventDate,
                  categoryId: _selectedCategory?.id,
                  description: _descriptionController.text,
                  recurrence: _selectedRecurrence,
                  recurrenceValue: _selectedRecurrence == RecurrenceType.custom ? int.tryParse(_recurrenceValueController.text) : null,
                  recurrenceUnit: _selectedRecurrence == RecurrenceType.custom ? _selectedRecurrenceUnit : null,
                );
        print("Reminder added.");
        // await NotificationService().scheduleNotification(newReminder);
      }

      if (!mounted) return;
      print("Navigating to home.");
      context.goNamed('home');
    } else if (_selectedDate == null) {
      print("Date is not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal harus diisi!')),
      );
    } else {
      print("Form is not valid.");
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Tambah'),
              onPressed: () async {
                if (newCategoryNameController.text.isNotEmpty) {
                  await ref
                      .read(categoryListProvider.notifier)
                      .addCustomCategory(newCategoryNameController.text);
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminderId == null ? 'Pengingat Baru' : 'Edit Pengingat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, size: 28),
            onPressed: _saveReminder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) =>
                    value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<app_models.Category>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      hint: Text(
                          'Pilih Kategori (${availableCategories.length} tersedia)'),
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
                    IconButton(
                      icon: Icon(Icons.add_circle,
                          color: theme.colorScheme.primary),
                      onPressed: _showAddCategoryDialog,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDateTimePicker(
                context: context,
                label: 'Tanggal',
                value: _selectedDate != null
                    ? DateFormat('d MMMM yyyy').format(_selectedDate!)
                    : 'Pilih Tanggal',
                icon: Icons.calendar_today_rounded,
                onTap: () async {
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
              const SizedBox(height: 20),
              _buildDateTimePicker(
                context: context,
                label: 'Waktu',
                value: _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Pilih Waktu',
                icon: Icons.access_time_filled_rounded,
                onTap: () async {
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
              const SizedBox(height: 20),
                DropdownButtonFormField<RecurrenceType>(
                  value: _selectedRecurrence,
                  decoration: const InputDecoration(labelText: 'Pengulangan'),
                  items: RecurrenceType.values
                      .where((type) => type != RecurrenceType.yearly) // Exclude yearly if it's not a standard option anymore or keep if it is
                      .map((type) {
                    String text;
                    switch (type) {
                      case RecurrenceType.daily:
                        text = 'Harian';
                        break;
                      case RecurrenceType.weekly:
                        text = 'Mingguan';
                        break;
                      case RecurrenceType.monthly:
                        text = 'Bulanan';
                        break;
                      case RecurrenceType.custom:
                        text = 'Kustom';
                        break;
                      default:
                        text = 'Tidak Berulang';
                        break;
                    }
                    return DropdownMenuItem<RecurrenceType>(
                      value: type,
                      child: Text(text),
                    );
                  }).toList(),
                  onChanged: (RecurrenceType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRecurrence = newValue;
                      });
                    }
                  },
                ),
                if (_selectedRecurrence == RecurrenceType.custom) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _recurrenceValueController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Setiap'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nilai tidak boleh kosong';
                            }
                            if (int.tryParse(value) == null || int.parse(value) <= 0) {
                              return 'Masukkan angka yang valid (>0)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<RecurrenceUnit>(
                          value: _selectedRecurrenceUnit,
                          decoration: const InputDecoration(labelText: 'Satuan'),
                          items: RecurrenceUnit.values.map((unit) {
                            String text;
                            switch (unit) {
                              case RecurrenceUnit.day:
                                text = 'Hari';
                                break;
                              case RecurrenceUnit.week:
                                text = 'Minggu';
                                break;
                              case RecurrenceUnit.month:
                                text = 'Bulan';
                                break;
                              case RecurrenceUnit.year:
                                text = 'Tahun';
                                break;
                            }
                            return DropdownMenuItem<RecurrenceUnit>(
                              value: unit,
                              child: Text(text),
                            );
                          }).toList(),
                          onChanged: (RecurrenceUnit? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRecurrenceUnit = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Keterangan'),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.inputDecorationTheme.fillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}