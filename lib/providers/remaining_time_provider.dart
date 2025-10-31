import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_provider.dart';

final remainingTimeProvider = StreamProvider<String>((ref) {
  final subscriptionEndDate = ref.watch(subscriptionEndDateProvider);
  final controller = StreamController<String>();

  if (subscriptionEndDate != null && subscriptionEndDate.year != 9999) {
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (subscriptionEndDate.isAfter(now)) {
        final remaining = subscriptionEndDate.difference(now);
        controller.add(_formatDuration(remaining));
      } else {
        controller.add('Langganan telah berakhir');
        timer.cancel();
        controller.close();
      }
    });

    ref.onDispose(() {
      timer.cancel();
      controller.close();
    });
  } else if (subscriptionEndDate != null && subscriptionEndDate.year == 9999) {
    controller.add('Premium Selamanya');
  } else {
    controller.add('Gratis');
  }

  return controller.stream;
});

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final days = duration.inDays;
  final hours = twoDigits(duration.inHours.remainder(24));
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$days hari, $hours:$minutes:$seconds';
}
