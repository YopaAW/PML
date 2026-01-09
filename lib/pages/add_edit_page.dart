import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/category_provider.dart';
import '../providers/premium_provider.dart';

import '../models/category_model.dart' as app_models;
import '../services/notification_service.dart';

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
  bool _isLoopingEnabled = false;

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
              .firstWhere((r) => r.id == widget.reminderId!);
          _existingReminder = reminderToEdit;

          // Populate the form fields with the existing reminder data
          _titleController.text = reminderToEdit.title;
          _descriptionController.text = reminderToEdit.description ?? '';
          _selectedDate = reminderToEdit.eventDate;
          _selectedTime = TimeOfDay.fromDateTime(reminderToEdit.eventDate);
          _selectedRecurrence = reminderToEdit.recurrence;
          _isLoopingEnabled = reminderToEdit.recurrence != RecurrenceType.none;
          
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

  bool _isSaving = false;

  void _saveReminder() async {
    if (_isSaving) return;
    
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isSaving = true);
      
      try {
        final time = _selectedTime ?? TimeOfDay.now();
        final eventDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          time.hour,
          time.minute,
        );

        // Check if we are updating an existing reminder
        if (_existingReminder != null) {
          final updatedReminder = _existingReminder!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            eventDate: eventDate,
            categoryId: _selectedCategory?.id,
            recurrence: _isLoopingEnabled ? _selectedRecurrence : RecurrenceType.none,
            recurrenceValue: _isLoopingEnabled 
                ? (_selectedRecurrence == RecurrenceType.custom 
                    ? int.tryParse(_recurrenceValueController.text) 
                    : (_selectedRecurrence == RecurrenceType.monthly ? _selectedDate!.day : null))
                : null,
            recurrenceUnit: _isLoopingEnabled && _selectedRecurrence == RecurrenceType.custom ? _selectedRecurrenceUnit : null,
          );
          await ref
              .read(reminderListProvider.notifier)
              .updateReminder(updatedReminder);
          
          // Schedule notification for updated reminder
          await NotificationService().scheduleNotification(updatedReminder);
        } else {
          // Otherwise, we are adding a new reminder
          final savedReminder = await ref.read(reminderListProvider.notifier).addReminder(
                _titleController.text,
                eventDate,
                categoryId: _selectedCategory?.id,
                description: _descriptionController.text,
                recurrence: _isLoopingEnabled ? _selectedRecurrence : RecurrenceType.none,
                recurrenceValue: _isLoopingEnabled 
                    ? (_selectedRecurrence == RecurrenceType.custom 
                        ? int.tryParse(_recurrenceValueController.text) 
                        : (_selectedRecurrence == RecurrenceType.monthly ? _selectedDate!.day : null))
                    : null,
                recurrenceUnit: _isLoopingEnabled && _selectedRecurrence == RecurrenceType.custom ? _selectedRecurrenceUnit : null,
              );
          
          // Schedule notification for new reminder
          await NotificationService().scheduleNotification(savedReminder);
        }

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        debugPrint('Error saving reminder: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
          setState(() => _isSaving = false);
        }
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal harus diisi!')),
      );
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
                  final success = await ref
                      .read(categoryListProvider.notifier)
                      .addCustomCategory(newCategoryNameController.text);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kategori berhasil ditambahkan')),
                      );
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal: Fitur Premium atau Error')),
                      );
                    }
                  }
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
            _isSaving 
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              )
            : IconButton(
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
              // Recurrence Section
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Ulangi Pengingat (Looping)'),
                      subtitle: Text(_isLoopingEnabled ? 'Pengingat akan muncul berulang' : 'Hanya sekali'),
                      secondary: Icon(Icons.loop, color: _isLoopingEnabled ? theme.colorScheme.primary : Colors.grey),
                      value: _isLoopingEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isLoopingEnabled = value;
                          if (value && _selectedRecurrence == RecurrenceType.none) {
                            _selectedRecurrence = RecurrenceType.daily; // Default to daily
                          }
                        });
                      },
                    ),
                    
                    if (_isLoopingEnabled) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slot Info Validation
                            Consumer(
                              builder: (context, ref, child) {
                                final remainingAsync = ref.watch(remainingLoopingSlotsProvider);
                                final remaining = remainingAsync.valueOrNull ?? 0;
                                final isEditingLooping = _existingReminder != null && 
                                                         _existingReminder!.recurrence != RecurrenceType.none;
                                
                                // User butuh slot jika: Baru bikin looping ATAU Edit dari non-looping ke looping
                                final needsSlot = !isEditingLooping;
                                final hasSlot = remaining > 0;
                                
                                if (needsSlot && !hasSlot) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Slot Looping Habis!',
                                                style: TextStyle(
                                                  color: theme.colorScheme.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Upgrade ke Premium untuk menambah slot.',
                                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton.tonal(
                                            onPressed: () => context.push('/slot'), // Go to SlotPage
                                            child: const Text('Beli Slot Tambahan'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sisa slot looping: $remaining',
                                        style: TextStyle(color: theme.colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            DropdownButtonFormField<RecurrenceType>(
                              value: _selectedRecurrence == RecurrenceType.none ? RecurrenceType.daily : _selectedRecurrence,
                              decoration: const InputDecoration(
                                labelText: 'Frekuensi Pengulangan',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              ),
                              items: RecurrenceType.values
                                  .where((type) => type != RecurrenceType.none && type != RecurrenceType.yearly)
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
                                    text = 'Kustom...';
                                    break;
                                  default:
                                    text = '';
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
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _recurrenceValueController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Setiap',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (!_isLoopingEnabled || _selectedRecurrence != RecurrenceType.custom) return null;
                                        if (value == null || value.isEmpty) {
                                          return 'Wajib diisi';
                                        }
                                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                          return '> 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonFormField<RecurrenceUnit>(
                                      value: _selectedRecurrenceUnit,
                                      decoration: const InputDecoration(
                                        labelText: 'Satuan',
                                        border: OutlineInputBorder(),
                                      ),
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
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
