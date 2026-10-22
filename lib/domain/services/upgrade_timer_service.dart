import '../../core/formatting/duration_format.dart' as formatting;
import '../models/upgrade.dart';
import '../models/upgrade_status.dart';

/// Pure domain service for upgrade timer calculations.
///
/// All methods take an explicit [now] parameter so they are fully
/// deterministic and testable without mocking DateTime.now().
class UpgradeTimerService {
  const UpgradeTimerService();

  /// Returns the time remaining until [upgrade] completes.
  ///
  /// Returns [Duration.zero] for completed or cancelled upgrades,
  /// and for active upgrades that are already past due.
  Duration remainingTime(DateTime now, Upgrade upgrade) {
    if (upgrade.status == UpgradeStatus.completed ||
        upgrade.status == UpgradeStatus.cancelled) {
      return Duration.zero;
    }
    final remaining = upgrade.expectedCompletionAtUtc.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Returns true when an active upgrade has passed its expected completion.
  bool isPastDue(DateTime now, Upgrade upgrade) {
    return upgrade.status == UpgradeStatus.active &&
        now.isAfter(upgrade.expectedCompletionAtUtc);
  }

  /// Returns true when an upgrade has been explicitly marked completed.
  bool isCompleted(Upgrade upgrade) {
    return upgrade.status == UpgradeStatus.completed;
  }

  /// Returns true when an upgrade has been cancelled.
  bool isCancelled(Upgrade upgrade) {
    return upgrade.status == UpgradeStatus.cancelled;
  }

  /// Calculates expected completion for a new upgrade from its start time
  /// and intended duration.
  DateTime computeExpectedCompletion({
    required DateTime startedAtUtc,
    required Duration duration,
  }) {
    return startedAtUtc.add(duration);
  }

  /// Calculates expected completion from "now + remaining duration".
  /// Useful when the user enters remaining time rather than total duration.
  DateTime computeCompletionFromRemaining({
    required DateTime now,
    required Duration remaining,
  }) {
    return now.add(remaining);
  }

  /// Returns how long an upgrade has been running (from start to now),
  /// capped at the total intended duration if provided.
  Duration elapsedTime(DateTime now, Upgrade upgrade) {
    final elapsed = now.difference(upgrade.startedAtUtc);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  /// Formats the remaining time for display.
  /// When < 300s, shows 'MM:SS'. When <= 0, returns [completedLabel].
  String formatRemaining(
    Duration remaining, {
    String completedLabel = 'Completed',
  }) {
    return formatting.formatRemaining(
      remaining,
      completedLabel: completedLabel,
    );
  }
}
