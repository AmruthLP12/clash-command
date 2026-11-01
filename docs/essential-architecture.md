# Clash Command --- Essential Architecture

This document is the short, binding architecture reference for
implementation agents. If a detailed design document and this file
appear to conflict, stop and resolve the discrepancy before coding.

## Product constraints

-   Android-first Flutter app.
-   Offline-first and local-only.
-   No website, PWA, backend, user accounts, cloud sync, Docker, Redis,
    Celery, or server jobs.
-   No Supercell login, game-file extraction, APK modification, or
    gameplay automation.
-   Build from scratch; do not clone Clocktower or inherit its code.

## Required stack

-   Flutter and Dart, current stable versions at implementation time.
-   Riverpod for app state/dependency access.
-   Drift over SQLite for persistent user data.
-   `flutter_local_notifications` for scheduled local notifications,
    after validating current Android setup requirements.
-   `audioplayers` for offline sound effects and optional ambient music.
-   `shared_preferences` for lightweight UI settings and active profile persistence.
-   `flutter_test` and `integration_test` where appropriate.

## Non-negotiable design rules

1.  SQLite is the source of truth for villages and upgrades.
2.  Store absolute completion timestamps; derive countdowns from the
    current clock.
3.  UI widgets do not issue SQL directly.
4.  Domain timer/lifecycle logic must be testable without Flutter or a
    device.
5.  UI and domain layers must not call the notification plugin directly;
    use an app-owned service interface.
6.  Every active upgrade edit, completion, cancellation, or deletion
    must reconcile its scheduled notifications.
7.  Notification reconciliation runs on app launch and after Android
    reboot where supported.
8.  Handle notification permission denial without blocking timer
    tracking.
9.  Catalog entries are local, versioned, and only assert durations when
    verified. Always allow custom timers.
10. Keep dependencies minimal. Add a package only when it solves a clear
    requirement.

## Suggested boundaries

-   `features/`: user-facing workflows and their presentation/state.
-   `domain/`: plain Dart models, validation, timer calculations, and
    lifecycle rules.
-   `database/`: Drift schema, DAOs, migrations, repositories.
-   `services/notifications/`: notification interface, plugin adapter,
    schedule reconciliation.
-   `app/theme/`: design tokens and theme.
-   `core/`: shared date/time, formatting, error and ID helpers.

Do not add abstractions, directories, or files only to satisfy a
diagram. Prefer the simplest structure that keeps responsibilities
clear.

## Minimum data entities

-   Village: id, name, optional Town Hall level, builder capacity,
    timestamps, archive status.
-   Upgrade: id, village id, name, category, optional catalog
    reference/slot, start time, expected completion time, status,
    optional completion time/notes, timestamps.
-   Catalog item: stable key, name, category, optional Town Hall/level
    hints, optional verified duration, source/version metadata.
-   Local preferences: notification enabled state and reminder offsets.

## Timer rules

-   Remaining time = `expectedCompletionAt - currentTime`.
-   Never decrement and persist a remaining-seconds counter.
-   If an active timer is past its expected completion, show it as
    ready/past due; do not silently mark it completed.
-   Editing a timer changes its absolute completion timestamp and
    invalidates the previous notification plan.
-   Avoid scheduling notifications in the past.

## Navigation and Theme Rules

-   Initial screen is `VillageProfilesScreen`. Each profile card supports in-place editing.
-   Add village action uses a bottom-right FAB (`FloatingActionButton.extended`).
-   Internal tabs (Dashboard, Planner, Levels, Settings) are strictly scoped to the selected village profile; internal village dropdown switchers are disallowed.
-   Back pops routes; Home (`Icons.home_outlined`) returns to Tab 0 (Dashboard). `PopScope` on Dashboard maps system back on internal tabs back to Tab 0.
-   Theme defaults to Dark mode if no preference is saved. Full support for System Default, Dark Mode, and Light Mode via `themePreferencesProvider`.
-   Upgrade completions display relative dates (`Today`, `Tomorrow`, or localized date for later days).
-   Audio is restricted to meaningful user actions; no audio on tab switches or passive navigation.

## Data Import and Backup Rules

-   **Village JSON Import**: 100% offline parsing of Clash of Clans village export files.
-   `CocDataIdCatalog` maps numeric `data` IDs to canonical item names, facilities, and subcategories. Unknown IDs are quarantined into an unmapped preview list.
-   Levels table supports multi-level quantity aggregation via `quantity` and `dataId` columns with compound uniqueness on `(villageId, category, itemName, currentLevel)`.
-   Timers calculate `completion_time = snapshot_time + remaining_seconds`. Future timers become active upgrades; expired timers are recorded in Levels for review. Helper timers are ignored.
-   Interactive preview screen before commit. Merge mode updates records and skips active duplicates; Replace mode wipes village's tracked levels/active upgrades first.
-   **Full Backup & Restore**: `.clashcommandbackup` archive containing `manifest.json`, `database.json`, and `preferences.json`.
-   Safety backup (`safety_pre_restore.clashcommandbackup`) is created before destructive restore.
-   Restoration executes in a single atomic database transaction; notifications and widgets are rescheduled post-restore.

## Quality gates

Before considering a feature complete: - `dart format` has been run. -
`flutter analyze` has no new errors. - Relevant unit/widget/database
tests pass. - Empty, invalid, permission-denied, and failure states are
handled. - No secrets, network tracking, or unnecessary permissions have
been introduced. - No unsupported claim of guaranteed exact notification
delivery.
