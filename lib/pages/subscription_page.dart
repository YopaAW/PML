import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_provider.dart';
import '../providers/remaining_time_provider.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingTimeAsync = ref.watch(remainingTimeProvider);
    final subscriptionEndDate = ref.watch(subscriptionEndDateProvider);
    final theme = Theme.of(context);

    final isLifetimeSubscriber = subscriptionEndDate?.year == 9999;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berlangganan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Langganan', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    remainingTimeAsync.when(
                      data: (time) => Text(time, style: theme.textTheme.bodyLarge),
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err', style: theme.textTheme.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
            if (isLifetimeSubscriber) ...[
              const SizedBox(height: 24),
              Text(
                'Keuntungan Premium Selamanya',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Sebagai pelanggan Premium Selamanya, Anda mendapatkan:',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              _buildBenefitItem(theme, 'Akses Penuh ke Fitur Kustomisasi Warna UI/UX'),
              _buildBenefitItem(theme, 'Manajemen Kategori Tanpa Batas'),
              _buildBenefitItem(theme, 'Prioritas Dukungan Pelanggan'),
              _buildBenefitItem(theme, 'Semua Fitur Mendatang Tanpa Biaya Tambahan'),
            ] else ...[
              const SizedBox(height: 24),
              Text(
                'Dapatkan Akses Premium',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Dengan berlangganan, Anda dapat membuat kategori custom untuk mengelola pengingat Anda dengan lebih baik.',
                style: theme.textTheme.bodyLarge,
              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(BuildContext context, WidgetRef ref, {required String title, required String price, required String description, Duration? duration, bool isLifetime = false}) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _showSubscriptionConfirmationDialog(context, ref, title, price, duration: duration, isLifetime: isLifetime);
                },
                child: Text(price),
              ),
            ),
          ],
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
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
