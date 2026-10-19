import '../models/upgrade.dart';
import '../models/upgrade_status.dart';

/// Typed application failures for expected error states.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

class CapacityFailure extends AppFailure {
  const CapacityFailure(super.message);
}

class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}

/// Validates and manages the lifecycle state transitions for upgrades.
///
/// Rules:
/// - active → completed
/// - active → cancelled
/// - completed/cancelled → active only via explicit reopen (if supported)
class UpgradeLifecycleService {
  const UpgradeLifecycleService();

  /// Returns a validated result for completing an active upgrade.
  Result<Upgrade> complete(Upgrade upgrade, DateTime completedAtUtc) {
    if (upgrade.status != UpgradeStatus.active) {
      return Result.failure(
        ValidationFailure(
          'Cannot complete an upgrade that is not active. '
          'Current status: ${upgrade.status.name}',
        ),
      );
    }
    return Result.success(
      upgrade.copyWith(
        status: UpgradeStatus.completed,
        completedAtUtc: completedAtUtc,
        updatedAtUtc: completedAtUtc,
        notificationRevision: upgrade.notificationRevision + 1,
      ),
    );
  }

  /// Returns a validated result for cancelling an active upgrade.
  Result<Upgrade> cancel(Upgrade upgrade, DateTime now) {
    if (upgrade.status != UpgradeStatus.active) {
      return Result.failure(
        ValidationFailure(
          'Cannot cancel an upgrade that is not active. '
          'Current status: ${upgrade.status.name}',
        ),
      );
    }
    return Result.success(
      upgrade.copyWith(
        status: UpgradeStatus.cancelled,
        updatedAtUtc: now,
        notificationRevision: upgrade.notificationRevision + 1,
      ),
    );
  }

  /// Reopens a completed or cancelled upgrade back to active, with a new
  /// expected completion timestamp.
  Result<Upgrade> reopen(
    Upgrade upgrade,
    DateTime newExpectedCompletionAtUtc,
    DateTime now,
  ) {
    if (upgrade.status == UpgradeStatus.active) {
      return Result.failure(
        const ValidationFailure('Upgrade is already active.'),
      );
    }
    return Result.success(
      upgrade.copyWith(
        status: UpgradeStatus.active,
        expectedCompletionAtUtc: newExpectedCompletionAtUtc,
        clearCompletedAt: true,
        updatedAtUtc: now,
        notificationRevision: upgrade.notificationRevision + 1,
      ),
    );
  }

  /// Updates an active timer's expected completion timestamp and bumps the
  /// notification revision so stale notifications are invalidated.
  Result<Upgrade> editTimer(
    Upgrade upgrade,
    DateTime newExpectedCompletionAtUtc,
    DateTime now,
  ) {
    if (upgrade.status != UpgradeStatus.active) {
      return Result.failure(
        ValidationFailure(
          'Can only edit the timer on an active upgrade.',
        ),
      );
    }
    if (newExpectedCompletionAtUtc.isBefore(now)) {
      return Result.failure(
        const ValidationFailure(
          'Expected completion cannot be in the past when editing a timer.',
        ),
      );
    }
    return Result.success(
      upgrade.copyWith(
        expectedCompletionAtUtc: newExpectedCompletionAtUtc,
        updatedAtUtc: now,
        notificationRevision: upgrade.notificationRevision + 1,
      ),
    );
  }
}

/// Minimal Result type to avoid try/catch in domain logic callers.
sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success<T>;
  factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T get value => (this as Success<T>).value;
  AppFailure get failure => (this as Failure<T>).failure;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  @override
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  @override
  final AppFailure failure;
}
