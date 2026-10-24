import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/providers.dart';
import 'package:clash_command/app/theme/app_colors.dart';

/// Settings screen for managing notifications, permissions, and app preferences.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

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

    final granted =
        await ref.read(notificationServiceProvider).requestPermission();
    if (mounted) {
      setState(() => _hasPermission = granted);
      _loadDiagnostics();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? 'Notification permission granted.'
                : 'Notification permission denied. You can change this in device settings.',
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

    return Scaffold(
      appBar: AppBar(
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
                                const Text(
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
              const Text(
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
                      subtitle: const Text(
                        'Alert when an upgrade reaches 100% completion',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                      subtitle: const Text(
                        'Send reminder alerts before an upgrade finishes',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                const Text(
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
                        const Text(
                          'Choose which alerts to receive before an upgrade finishes:',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                  leading: const Icon(Icons.send_outlined, color: AppColors.accent),
                  title: const Text('Send test notification'),
                  subtitle: const Text(
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
              const Text(
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
                              side: const BorderSide(color: AppColors.accent),
                            ),
                            icon: const Icon(Icons.alarm_on, size: 18),
                            label: const Text('Allow Exact Alarms in System Settings'),
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
                          value:
                              '${_nextCompletion!.toLocal().hour.toString().padLeft(2, '0')}:${_nextCompletion!.toLocal().minute.toString().padLeft(2, '0')} (${_nextCompletion!.toLocal().year}-${_nextCompletion!.toLocal().month.toString().padLeft(2, '0')}-${_nextCompletion!.toLocal().day.toString().padLeft(2, '0')})',
                          isOk: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section: About
              const Text(
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
                          const Expanded(
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
                                  'Version 1.0.4 (Build 5) • Offline-first Clash of Clans tracker',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'All villages, upgrades, and history records are stored exclusively in your local device SQLite database. No external accounts or cloud dependencies.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
