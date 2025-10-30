import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dukung Developer'),
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
            const Text(
              'Suka dengan aplikasi Ingat.in?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Dukung developer untuk terus mengembangkan aplikasi ini dengan memberikan donasi.'),
            const SizedBox(height: 24),
            const Text(
              'Pilih jumlah donasi:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildDonationButton(context, 'Rp 1.000'),
                _buildDonationButton(context, 'Rp 5.000'),
                _buildDonationButton(context, 'Rp 10.000'),
                _buildDonationButton(context, 'Rp 20.000'),
                _buildDonationButton(context, 'Rp 50.000'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(BuildContext context, String amount) {
    return ElevatedButton(
      onPressed: () {
        _showDonationConfirmationDialog(context, amount);
      },
      child: Text(amount),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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
