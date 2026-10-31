import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/features/villages/presentation/village_profiles_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ClashCommandApp(),
    ),
  );

  // Initialize non-blocking background services after the first frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initBackgroundServices(container);
  });
}

Future<void> _initBackgroundServices(ProviderContainer container) async {
  try {
    // Eagerly instantiate audio service so settings and listeners are loaded
    container.read(audioServiceProvider);

    // Initialize notifications
    await container.read(notificationServiceProvider).initialize();

    // Reconcile notifications on launch
    await container.read(notificationReconcilerProvider).reconcile();

    // Sync home-screen widgets on launch
    await container.read(homeWidgetSyncServiceProvider).syncWidgets();
  } catch (e) {
    debugPrint('Background services initialization error: $e');
  }
}

class ClashCommandApp extends StatelessWidget {
  const ClashCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash Command',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const VillageProfilesScreen(),
    );
  }
}
