import 'package:flutter_riverpod/flutter_riverpod.dart';


// A user is considered "subscribed" if they have purchased any number of slots.
final isSubscribedProvider = Provider<bool>((ref) {
  return true;
});

// This provider can be used later to track subscription end dates.
// For now, it remains a dummy provider returning null.
final subscriptionEndDateProvider = Provider<DateTime?>((ref) {
  return null;
});
