import 'package:flutter_riverpod/flutter_riverpod.dart';
// Total looping slots provider - async dari database
import '../services/slot_service.dart';
import 'auth_provider.dart';
import 'reminder_provider.dart';

// Provider untuk total slots yang dimiliki user
final totalLoopingSlotsProvider = FutureProvider<int>((ref) async {
  // Watch auth state untuk refresh saat login/logout
  ref.watch(authStateProvider);
  return await SlotService.getTotalLoopingSlots();
});

// Provider untuk sisa slot looping (total - used)
final remainingLoopingSlotsProvider = FutureProvider<int>((ref) async {
  // Watch auth & reminders to trigger refresh
  ref.watch(authStateProvider);
  ref.watch(reminderListProvider); 
  return await SlotService.getRemainingLoopingSlots();
});

// Provider untuk cek apakah user bisa tambah looping reminder
final canAddLoopingReminderProvider = FutureProvider<bool>((ref) async {
  ref.watch(authStateProvider);
  ref.watch(reminderListProvider);
  return await SlotService.canAddLoopingReminder();
});

// Provider info lengkap slot (total, used, remaining)
final slotInfoProvider = FutureProvider<Map<String, int>>((ref) async {
  ref.watch(authStateProvider);
  ref.watch(reminderListProvider);
  
  final total = await SlotService.getTotalLoopingSlots();
  final used = await SlotService.getUsedLoopingSlots();
  return {
    'total': total,
    'used': used,
    'remaining': total - used,
  };
});
