import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dukung Developer'),
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
            Text(
              'Suka dengan aplikasi Ingat.in?',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dukung developer untuk terus mengembangkan aplikasi ini dengan memberikan donasi.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Pilih jumlah donasi:',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0, // Horizontal space between chips
              runSpacing: 12.0, // Vertical space between lines
              children: [
                _buildDonationButton(context, 'Rp 1.000'),
                _buildDonationButton(context, 'Rp 5.000'),
                _buildDonationButton(context, 'Rp 10.000'),
                _buildDonationButton(context, 'Rp 20.000'),
                _buildDonationButton(context, 'Rp 50.000'),
                _buildDonationButton(context, 'Lainnya'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(BuildContext context, String amount) {
    final theme = Theme.of(context);
    return ActionChip(
      onPressed: () {
        if (amount == 'Lainnya') {
          _showCustomDonationDialog(context);
        } else {
          _showDonationConfirmationDialog(context, amount);
        }
      },
      label: Text(amount, style: theme.textTheme.titleMedium),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary, width: 1),
      ),
    );
  }

  Future<void> _showCustomDonationDialog(BuildContext context) async {
    final customAmountController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Masukkan Jumlah Donasi'),
          content: TextField(
            controller: customAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Contoh: 30000'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Donasi'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDonationConfirmationDialog(context, 'Rp ${customAmountController.text}');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDonationConfirmationDialog(BuildContext context, String amount) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Donasi'),
          content: Text('Apakah Anda yakin ingin berdonasi sebesar $amount?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Iya'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Terima kasih atas donasi Anda sebesar $amount!'),
                    duration: const Duration(seconds: 3),
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
