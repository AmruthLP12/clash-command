import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/core/constants/app_support_links.dart';
import 'package:clash_command/core/formatting/date_time_format.dart';
import 'package:clash_command/core/theme/theme_preferences.dart';
import 'package:clash_command/features/history/presentation/history_screen.dart';

/// Settings screen for managing notifications, permissions, and app preferences.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.onHome});

  final VoidCallback? onHome;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _hasPermission;
  bool? _exactAlarmsAllowed;
  int _scheduledCount = 0;
  int _activeUpgradesCount = 0;
  DateTime? _nextCompletion;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _loadDiagnostics();
  }

  Future<void> _checkPermission() async {
    final granted = await ref.read(notificationServiceProvider).hasPermission();
    if (mounted) setState(() => _hasPermission = granted);
  }

  Future<void> _loadDiagnostics() async {
    final notifService = ref.read(notificationServiceProvider);
    final upgradesDao = ref.read(upgradesDaoProvider);
    final exactAllowed = await notifService.canScheduleExactAlarms();
    final count = await notifService.getScheduledCount();
    final active = await upgradesDao.getAllActive();
    DateTime? nextComp;
    if (active.isNotEmpty) {
      active.sort(
        (a, b) =>
            a.expectedCompletionAtUtc.compareTo(b.expectedCompletionAtUtc),
      );
      nextComp = active.first.expectedCompletionAtUtc;
    }
    if (mounted) {
      setState(() {
        _exactAlarmsAllowed = exactAllowed;
        _scheduledCount = count;
        _activeUpgradesCount = active.length;
        _nextCompletion = nextComp;
      });
    }
  }

  Future<void> _requestPermission() async {
    // Show user-friendly rationale before system prompt
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
          'Clash Command uses local notifications to alert you when your builder upgrades finish or are nearing completion.\n\n'
          'No data leaves your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final granted = await ref
        .read(notificationServiceProvider)
        .requestPermission();
    if (mounted) {
      setState(() => _hasPermission = granted);
      _loadDiagnostics();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'Notification permission granted.' : 'Notification permission denied. You can change this in device settings.',
          ),
        ),
      );
    }
  }

  Future<void> _reconcile() async {
    await ref.read(notificationReconcilerProvider).reconcile();
    await _loadDiagnostics();
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesStreamProvider);
    final displayPrefs = ref.watch(displayPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.onHome == null,
        leading: widget.onHome != null
            ? IconButton(
                icon: const Icon(Icons.home_outlined),
                tooltip: 'Dashboard',
                onPressed: widget.onHome,
              )
            : null,
        title: const Text('Settings'),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading settings: $e')),
        data: (prefs) {
          List<int> offsets = [30, 5];
          try {
            final decoded =
                jsonDecode(prefs.reminderOffsetMinutesJson) as List<dynamic>;
            offsets = decoded.map((e) => e as int).toList();
          } catch (_) {}

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section 1: Support Clash Command
              Text(
                'SUPPORT CLASH COMMAND',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Clash Command is 100% free, offline-first, and ad-free. If you find it helpful and want to support ongoing development, consider a contribution!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 16),
                      // Dynamic UPI QR Code
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: AppSupportLinks.qrPayload,
                          version: QrVersions.auto,
                          size: 190.0,
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          errorStateBuilder: (c, err) => const SizedBox(
                            width: 190,
                            height: 190,
                            child: Center(
                              child: Text(
                                'Error generating QR code',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // UPI ID and Copy Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            SelectableText(
                              AppSupportLinks.qrPayload,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              tooltip: 'Copy UPI ID',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Clipboard.setData(
                                  const ClipboardData(
                                    text: AppSupportLinks.qrPayload,
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'UPI ID copied to clipboard: 9739337301@jupiteraxis',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan with any supported UPI app to support Clash Command.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      // Developer Portfolio
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.language_outlined,
                          color: AppColors.accent,
                        ),
                        title: const Text(
                          'Developer Portfolio',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          AppSupportLinks.portfolioUrl.isNotEmpty
                              ? AppSupportLinks.portfolioUrl
                              : 'Not configured yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _launchExternalUrl(
                          context,
                          AppSupportLinks.portfolioUrl,
                          'Developer Portfolio',
                        ),
                      ),
                      const Divider(height: 1),
                      // Support via Ko-fi
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.coffee, color: AppColors.accent),
                        title: const Text(
                          'Support via Ko-fi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          AppSupportLinks.kofiUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _launchExternalUrl(
                          context,
                          AppSupportLinks.kofiUrl,
                          'Ko-fi',
                        ),
                      ),
                      const Divider(height: 1),
                      // Support via PayPal
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.payment, color: AppColors.accent),
                        title: const Text(
                          'Support via PayPal',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          AppSupportLinks.paypalDonationUrl.isNotEmpty
                              ? AppSupportLinks.paypalDonationUrl
                              : 'Donation link not configured yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _launchExternalUrl(
                          context,
                          AppSupportLinks.paypalDonationUrl,
                          'PayPal Donation',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Appearance & Theme
              Text(
                'APPEARANCE & THEME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theme Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose between system default, dark mode, or light mode. Dark mode is default.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, _) {
                          final currentMode = ref.watch(
                            themePreferencesProvider,
                          );
                          return SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<AppThemeModePreference>(
                              segments: const [
                                ButtonSegment(
                                  value: AppThemeModePreference.system,
                                  label: Text('System'),
                                  icon: Icon(Icons.brightness_auto, size: 16),
                                ),
                                ButtonSegment(
                                  value: AppThemeModePreference.dark,
                                  label: Text('Dark'),
                                  icon: Icon(Icons.dark_mode, size: 16),
                                ),
                                ButtonSegment(
                                  value: AppThemeModePreference.light,
                                  label: Text('Light'),
                                  icon: Icon(Icons.light_mode, size: 16),
                                ),
                              ],
                              selected: {currentMode},
                              onSelectionChanged: (selected) {
                                if (selected.isNotEmpty) {
                                  ref
                                      .read(themePreferencesProvider.notifier)
                                      .setThemeMode(selected.first);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Display & Formatting
              Text(
                'DISPLAY & FORMATTING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time Format',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<TimeFormatPreference>(
                          segments: const [
                            ButtonSegment(
                              value: TimeFormatPreference.h12,
                              label: Text('12-hour (03:45 PM)'),
                            ),
                            ButtonSegment(
                              value: TimeFormatPreference.h24,
                              label: Text('24-hour (15:45)'),
                            ),
                          ],
                          selected: {displayPrefs.timeFormat},
                          onSelectionChanged: (val) {
                            ref
                                .read(displayPreferencesProvider.notifier)
                                .setTimeFormat(val.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      const Text(
                        'Date Format',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DateFormatPreference>(
                        initialValue: displayPrefs.dateFormat,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: AppColors.surfaceVariant,
                        items: DateFormatPreference.values.map((df) {
                          return DropdownMenuItem(
                            value: df,
                            child: Text('${df.label} (${df.example})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref
                                .read(displayPreferencesProvider.notifier)
                                .setDateFormat(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section: Activity History
              Text(
                'ACTIVITY & LOGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: ListTile(
                  leading: Icon(Icons.history, color: AppColors.accent),
                  title: const Text(
                    'Activity History',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'View completed upgrades, cancellations, and timeline events',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Section: Sound & Music
              Text(
                'SOUND & MUSIC',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: ref
                            .watch(audioServiceProvider)
                            .sfxEnabledNotifier,
                        builder: (context, sfxEnabled, _) {
                          return SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                              Icons.volume_up_outlined,
                              color: AppColors.accent,
                            ),
                            title: const Text(
                              'Sound Effects',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Tap, upgrade start, completion, and alert chimes',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            value: sfxEnabled,
                            activeThumbColor: AppColors.accent,
                            onChanged: (val) {
                              ref.read(audioServiceProvider).setSfxEnabled(val);
                              if (val) ref.read(audioServiceProvider).playTap();
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: ref
                            .watch(audioServiceProvider)
                            .sfxEnabledNotifier,
                        builder: (context, sfxEnabled, _) {
                          if (!sfxEnabled) return const SizedBox.shrink();
                          return ValueListenableBuilder<double>(
                            valueListenable: ref
                                .watch(audioServiceProvider)
                                .sfxVolumeNotifier,
                            builder: (context, volume, _) {
                              return Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Text(
                                    'SFX Volume',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: volume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      activeColor: AppColors.accent,
                                      onChanged: (v) => ref
                                          .read(audioServiceProvider)
                                          .setSfxVolume(v),
                                      onChangeEnd: (v) => ref
                                          .read(audioServiceProvider)
                                          .playTap(),
                                    ),
                                  ),
                                  Text(
                                    '${(volume * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const Divider(height: 20),
                      ValueListenableBuilder<bool>(
                        valueListenable: ref
                            .watch(audioServiceProvider)
                            .musicEnabledNotifier,
                        builder: (context, musicEnabled, _) {
                          return SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: Icon(
                              Icons.music_note_outlined,
                              color: AppColors.accent,
                            ),
                            title: const Text(
                              'Ambient Music',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Looping background ambient soundtrack',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            value: musicEnabled,
                            activeThumbColor: AppColors.accent,
                            onChanged: (val) {
                              ref
                                  .read(audioServiceProvider)
                                  .setMusicEnabled(val);
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: ref
                            .watch(audioServiceProvider)
                            .musicEnabledNotifier,
                        builder: (context, musicEnabled, _) {
                          if (!musicEnabled) return const SizedBox.shrink();
                          return ValueListenableBuilder<double>(
                            valueListenable: ref
                                .watch(audioServiceProvider)
                                .musicVolumeNotifier,
                            builder: (context, volume, _) {
                              return Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Text(
                                    'Music Volume',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: volume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 10,
                                      activeColor: AppColors.accent,
                                      onChanged: (v) => ref
                                          .read(audioServiceProvider)
                                          .setMusicVolume(v),
                                    ),
                                  ),
                                  Text(
                                    '${(volume * 100).round()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: Notification Permissions
              Text(
                'NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              // Permission status card
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _hasPermission == true
                                ? Icons.notifications_active
                                : Icons.notifications_off_outlined,
                            color: _hasPermission == true
                                ? AppColors.active
                                : AppColors.pastDue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'System Permission',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  _hasPermission == true
                                      ? 'Notifications are allowed'
                                      : 'Permission not granted',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _hasPermission == true
                                        ? AppColors.active
                                        : AppColors.pastDue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_hasPermission != true)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _requestPermission,
                              child: const Text('Request'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section: Notification Preferences
              Text(
                'NOTIFICATION PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Completion alerts'),
                      subtitle: Text(
                        'Alert when an upgrade reaches 100% completion',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      value: prefs.completionEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) async {
                        await ref
                            .read(notificationPreferencesDaoProvider)
                            .updatePreferences(completionEnabled: val);
                        await _reconcile();
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Upcoming reminders'),
                      subtitle: Text(
                        'Send reminder alerts before an upgrade finishes',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      value: prefs.preAlertsEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) async {
                        await ref
                            .read(notificationPreferencesDaoProvider)
                            .updatePreferences(preAlertsEnabled: val);
                        await _reconcile();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section: Configurable Intervals
              if (prefs.preAlertsEnabled) ...[
                Text(
                  'REMINDER INTERVALS BEFORE COMPLETION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppColors.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose which alerts to receive before an upgrade finishes:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _IntervalChip(
                              label: '1 hour',
                              minutes: 60,
                              selected: offsets.contains(60),
                              onToggle: (selected) =>
                                  _toggleOffset(offsets, 60, selected),
                            ),
                            _IntervalChip(
                              label: '30 min',
                              minutes: 30,
                              selected: offsets.contains(30),
                              onToggle: (selected) =>
                                  _toggleOffset(offsets, 30, selected),
                            ),
                            _IntervalChip(
                              label: '10 min',
                              minutes: 10,
                              selected: offsets.contains(10),
                              onToggle: (selected) =>
                                  _toggleOffset(offsets, 10, selected),
                            ),
                            _IntervalChip(
                              label: '5 min',
                              minutes: 5,
                              selected: offsets.contains(5),
                              onToggle: (selected) =>
                                  _toggleOffset(offsets, 5, selected),
                            ),
                            _IntervalChip(
                              label: '1 min',
                              minutes: 1,
                              selected: offsets.contains(1),
                              onToggle: (selected) =>
                                  _toggleOffset(offsets, 1, selected),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Section: Test notification action
              Card(
                color: AppColors.card,
                child: ListTile(
                  leading: Icon(Icons.send_outlined, color: AppColors.accent),
                  title: const Text('Send test notification'),
                  subtitle: Text(
                    'Verifies that alerts can appear on this device',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  onTap: () async {
                    await ref
                        .read(notificationServiceProvider)
                        .showTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test notification sent.'),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Section: Diagnostics
              Text(
                'NOTIFICATION DIAGNOSTICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DiagnosticRow(
                        label: 'System Notification Permission',
                        value: _hasPermission == true
                            ? 'Granted'
                            : 'Denied / Not Granted',
                        isOk: _hasPermission == true,
                      ),
                      const Divider(height: 20),
                      _DiagnosticRow(
                        label: 'Exact-Alarm Scheduling',
                        value: _exactAlarmsAllowed == true
                            ? 'Permitted (Exact to minute)'
                            : 'Restricted (Delivery delayed by Android Doze)',
                        isOk: _exactAlarmsAllowed == true,
                      ),
                      if (_exactAlarmsAllowed == false) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: BorderSide(color: AppColors.accent),
                            ),
                            icon: const Icon(Icons.alarm_on, size: 18),
                            label: const Text(
                              'Allow Exact Alarms in System Settings',
                            ),
                            onPressed: () async {
                              await ref
                                  .read(notificationServiceProvider)
                                  .requestExactAlarmsPermission();
                              await _loadDiagnostics();
                            },
                          ),
                        ),
                      ],
                      const Divider(height: 20),
                      _DiagnosticRow(
                        label: 'Active Village Upgrades',
                        value: '$_activeUpgradesCount active',
                        isOk: true,
                      ),
                      const Divider(height: 20),
                      _DiagnosticRow(
                        label: 'Alarms Queued in Android',
                        value: '$_scheduledCount scheduled',
                        isOk: _scheduledCount > 0 || _activeUpgradesCount == 0,
                      ),
                      if (_nextCompletion != null) ...[
                        const Divider(height: 20),
                        _DiagnosticRow(
                          label: 'Next Expected Completion',
                          value: DateTimeFormat.fullDateTime(
                            _nextCompletion!,
                            dateFormat: displayPrefs.dateFormat,
                            timeFormat: displayPrefs.timeFormat,
                          ),
                          isOk: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: About
              Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/branding/logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clash Command',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Version 1.0.5 (Build 6) • Offline-first Clash of Clans tracker',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'All villages, upgrades, and history records are stored exclusively in your local device SQLite database. No external accounts or cloud dependencies.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleOffset(
    List<int> currentOffsets,
    int minutes,
    bool select,
  ) async {
    final updated = List<int>.from(currentOffsets);
    if (select) {
      if (!updated.contains(minutes)) updated.add(minutes);
    } else {
      updated.remove(minutes);
    }
    updated.sort((a, b) => b.compareTo(a)); // largest first

    await ref
        .read(notificationPreferencesDaoProvider)
        .updatePreferences(reminderOffsetMinutes: updated);
    await _reconcile();
  }

  Future<void> _launchExternalUrl(
    BuildContext context,
    String url,
    String linkName,
  ) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$linkName is not configured yet. Configure it in AppSupportLinks.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid link URL: $url')));
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $linkName in browser.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching $linkName: $e')),
        );
      }
    }
  }
}

class _IntervalChip extends StatelessWidget {
  const _IntervalChip({
    required this.label,
    required this.minutes,
    required this.selected,
    required this.onToggle,
  });

  final String label;
  final int minutes;
  final bool selected;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(
        color: selected ? Colors.black : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide.none,
      onSelected: onToggle,
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.isOk,
  });

  final String label;
  final String value;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isOk ? AppColors.textPrimary : AppColors.pastDue,
          ),
        ),
      ],
    );
  }
}
