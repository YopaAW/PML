import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../models/category_model.dart' as app_models;

class ReminderCard extends ConsumerWidget {
  final Reminder reminder;
  final app_models.Category category;

  const ReminderCard({super.key, required this.reminder, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(reminder.eventDate);
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => context.go('/add', extra: reminder),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      reminder.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) {
                      ref.read(reminderListProvider.notifier).toggleCompletion(reminder.id);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Jadwal: $formattedDate',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: ${category.name}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              if (reminder.description != null && reminder.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    reminder.description!,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton(
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
                      ref.read(reminderListProvider.notifier).removeReminder(reminder.id);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
