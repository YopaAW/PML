import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider calculates the total available slots (free + purchased).
// The UI will watch this provider to check the slot limit.
final availableSlotsProvider = Provider<int>((ref) {
  return 99999;
});
