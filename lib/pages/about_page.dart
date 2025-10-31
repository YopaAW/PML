import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingat.in',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aplikasi sederhana untuk mencatat pengingat kegiatan Anda.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Versi', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('1.0.0', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                    const Divider(height: 30),
                    Text('Dibuat oleh:', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text('Yopa Arian Widodo', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('Sidra Febrian Hardiyanto', style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
