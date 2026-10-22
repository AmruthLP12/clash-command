import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Initialize notifications
  await container.read(notificationServiceProvider).initialize();

  // Reconcile notifications on launch
  await container.read(notificationReconcilerProvider).reconcile();

  // Sync home-screen widgets on launch
  await container.read(homeWidgetSyncServiceProvider).syncWidgets();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ClashCommandApp(),
    ),
  );
}

class ClashCommandApp extends StatelessWidget {
  const ClashCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash Command',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const DashboardScreen(),
    );
  }
}
