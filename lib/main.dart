import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/features/dashboard/presentation/dashboard_screen.dart';
import 'package:clash_command/services/notifications/notification_reconciler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Initialize notifications
  await container.read(notificationServiceProvider).initialize();

  // Reconcile notifications on launch
  final reconciler = NotificationReconciler(
    upgradesDao: container.read(upgradesDaoProvider),
    notificationService: container.read(notificationServiceProvider),
    planService: container.read(notificationPlanServiceProvider),
    preferencesDao: container.read(notificationPreferencesDaoProvider),
    villagesDao: container.read(villagesDaoProvider),
  );
  await reconciler.reconcile();

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
