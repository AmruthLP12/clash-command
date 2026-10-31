import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/app/theme/app_theme.dart';
import 'package:clash_command/core/theme/theme_preferences.dart';
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

  // Initialize background services deferred after the app shell renders
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initBackgroundServices(container);
  });
}

Future<void> _initBackgroundServices(ProviderContainer container) async {
  try {
    // Defer heavy reconciliation and sync to keep initial launch immediate
    await Future<void>.delayed(const Duration(seconds: 2));

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

class ClashCommandApp extends ConsumerWidget {
  const ClashCommandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePref = ref.watch(themePreferencesProvider);

    return MaterialApp(
      title: 'Clash Command',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themePref.themeMode,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        AppColors.setLight(!isDark);
        return child ?? const SizedBox.shrink();
      },
      home: const VillageProfilesScreen(),
    );
  }
}
