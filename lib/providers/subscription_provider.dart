import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionEndDateProvider = StateProvider<DateTime?>((ref) => null);

final isSubscribedProvider = Provider<bool>((ref) {
  final endDate = ref.watch(subscriptionEndDateProvider);
  if (endDate == null) {
    return false;
  }
  // Lifetime subscription
  if (endDate.year == 9999) {
    return true;
  }
  return endDate.isAfter(DateTime.now());
});
