import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  Timer? _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final subscriptionEndDate = ref.read(subscriptionEndDateProvider);
    if (subscriptionEndDate != null && subscriptionEndDate.year != 9999) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        if (subscriptionEndDate.isAfter(now)) {
          final remaining = subscriptionEndDate.difference(now);
          if (mounted) {
            setState(() {
              _remainingTime = _formatDuration(remaining);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _remainingTime = 'Langganan telah berakhir';
            });
          }
          _timer?.cancel();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = duration.inDays;
    final hours = twoDigits(duration.inHours.remainder(24));
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$days hari, $hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = ref.watch(isSubscribedProvider);
    final subscriptionEndDate = ref.watch(subscriptionEndDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berlangganan'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Langganan:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            isSubscribed
                ? subscriptionEndDate!.year == 9999
                    ? const Text('Premium Selamanya')
                    : Text(_remainingTime)
                : const Text('Gratis'),
            const SizedBox(height: 24),
            const Text(
              'Dapatkan Akses Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Dengan berlangganan, Anda dapat membuat kategori custom untuk mengelola pengingat Anda dengan lebih baik.'),
            const SizedBox(height: 24),
            _buildSubscriptionOption(
              context,
              ref,
              title: 'Tahunan',
              price: 'Rp 15.000',
              description: 'Langganan untuk 1 tahun',
              duration: const Duration(days: 365),
            ),
            const SizedBox(height: 16),
            _buildSubscriptionOption(
              context,
              ref,
              title: '2 Tahun',
              price: 'Rp 25.000',
              description: 'Langganan untuk 2 tahun',
              duration: const Duration(days: 730),
            ),
            const SizedBox(height: 16),
            _buildSubscriptionOption(
              context,
              ref,
              title: 'Selamanya',
              price: 'Rp 50.000',
              description: 'Langganan seumur hidup',
              isLifetime: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionOption(BuildContext context, WidgetRef ref, {required String title, required String price, required String description, Duration? duration, bool isLifetime = false}) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: () {
            _showSubscriptionConfirmationDialog(context, ref, title, price, duration: duration, isLifetime: isLifetime);
          },
          child: Text(price),
        ),
      ),
    );
  }

  Future<void> _showSubscriptionConfirmationDialog(BuildContext context, WidgetRef ref, String title, String price, {Duration? duration, bool isLifetime = false}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Langganan'),
          content: Text('Apakah Anda yakin ingin berlangganan paket $title dengan harga $price?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Berlangganan'),
              onPressed: () {
                final currentEndDate = ref.read(subscriptionEndDateProvider);

                if (isLifetime) {
                  ref.read(subscriptionEndDateProvider.notifier).state = DateTime(9999);
                } else if (duration != null) {
                  if (currentEndDate != null && currentEndDate.isAfter(DateTime.now()) && currentEndDate.year != 9999) {
                    ref.read(subscriptionEndDateProvider.notifier).state = currentEndDate.add(duration);
                  } else {
                    ref.read(subscriptionEndDateProvider.notifier).state = DateTime.now().add(duration);
                  }
                }
                _startTimer(); // Restart timer to update the UI
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terima kasih! Langganan Anda telah diperbarui.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
