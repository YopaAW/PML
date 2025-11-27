import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ingatin/theme.dart';
import 'package:ingatin/providers/theme_provider.dart';
import 'package:ingatin/providers/color_palette_provider.dart';
import 'models/reminder_model.dart';
import 'pages/home_page.dart';
import 'pages/add_edit_page.dart';
import 'pages/about_page.dart';
import 'pages/manage_categories_page.dart';
import 'pages/donation_page.dart';

import 'database_hive.dart'; // Import the Hive database
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  await DatabaseService.init(); // Initialize Hive database
  await Hive.openBox('settings'); // Open settings box
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) {
        final reminder = state.extra as Reminder?;
        return AddEditPage(reminder: reminder);
      },
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const ManageCategoriesPage(),
    ),
    GoRoute(
      path: '/donation',
      builder: (context, state) => const DonationPage(),
    ),

    // TODO: Tambahkan rute '/edit/:id' jika diperlukan
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorPalette = ref.watch(colorPaletteProvider);
    return MaterialApp.router(
      title: 'Ingat.in',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(colorPalette),
      darkTheme: AppTheme.darkTheme(colorPalette),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}