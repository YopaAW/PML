import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'models/reminder_model.dart';
import 'pages/home_page.dart';
import 'pages/add_edit_page.dart';
import 'pages/about_page.dart';
import 'pages/manage_categories_page.dart';
import 'pages/donation_page.dart';
import 'pages/subscription_page.dart';
import 'database_hive.dart'; // Import the Hive database
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  await DatabaseService.init(); // Initialize Hive database
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
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionPage(),
    ),
    // TODO: Tambahkan rute '/edit/:id' jika diperlukan
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ingat.in',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _router,
    );
  }
}