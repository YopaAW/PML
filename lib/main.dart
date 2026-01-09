import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ingatin/theme.dart';
import 'package:ingatin/providers/theme_provider.dart';
import 'package:ingatin/providers/color_palette_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/unified_database_service.dart';
import 'services/notification_service.dart';
import 'services/slot_service.dart';

import 'pages/home_page.dart';
import 'pages/add_edit_page.dart';
import 'pages/about_page.dart';
import 'pages/manage_categories_page.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/slot_page.dart';
import 'pages/profile_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('settings'); // Open settings box
  
  // Initialize Database Service (Firebase Firestore)
  await DatabaseService.init();
  
  // Initialize Unified Database Service (Local + Cloud)
  await UnifiedDatabaseService.init();
  
  // Initialize Notification Service
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Initialize In-App Purchase
  // ignore: unused_local_variable
  final iapAvailable = await SlotService.initializeIAP();
  
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddEditPage(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return AddEditPage(reminderId: id);
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
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/slot',
      builder: (context, state) => const SlotPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
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