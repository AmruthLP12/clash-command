# Clash Command --- Architecture

**Status:** Proposed architecture for review before implementation\
**Architecture style:** Local-first Flutter application with a
feature-oriented structure.

## 1. Goals

-   Keep all core capabilities on-device.
-   Separate UI, domain rules, persistence, and platform notification
    integration.
-   Make upgrade calculations testable without Flutter widgets.
-   Avoid unnecessary abstraction and dependency injection frameworks
    beyond Riverpod.
-   Ensure timers remain correct when the app is suspended or
    terminated.
-   Make future features possible without requiring a rewrite.

## 2. Technology decisions

  -------------------------------------------------------------------------------
  Concern                 Choice                          Rationale
  ----------------------- ------------------------------- -----------------------
  App framework           Flutter / Dart                  Android-first, custom
                                                          UI, future platform
                                                          flexibility

  State management        Riverpod                        Explicit, testable
                                                          state and dependency
                                                          management

  Persistence             SQLite via Drift                Typed queries,
                                                          migrations,
                                                          relationships, robust
                                                          local storage

  Notifications           `flutter_local_notifications`   Local scheduled
                                                          notifications

  Audio                   `audioplayers`                  Offline sound effects
                                                          and optional soundtrack

  Preferences             `shared_preferences`            Fast local key-value
                                                          UI state & active profile

  IDs                     UUID or stable integer primary  Stable record and
                          keys                            notification identity

  Date/time               Dart `DateTime` in UTC for      Consistent calculations
                          stored instants                 across time zones

  UI icons                Lucide-style or Material icons, Cohesive interface
                          consistent set                  

  Tests                   `flutter_test`,                 Domain and platform
                          `integration_test`,             workflow coverage
                          package-level unit tests        

  Formatting/lint         `dart format`,                  Consistent and
                          `flutter analyze`               maintainable code
  -------------------------------------------------------------------------------

Dependency versions should be checked against current stable releases at
implementation time and pinned through the committed lockfile. Do not
assume a version in this planning document is current.

## 3. Architectural layers

### Presentation

Flutter screens and reusable widgets. They render state and dispatch
user intents. Widgets should not issue SQL directly or calculate
business-critical timer values.

### Application/state

Riverpod providers and notifiers orchestrate screen state and call
domain services/repositories. Keep state close to the feature that owns
it.

### Domain

Plain Dart models and services: - Upgrade duration and completion
calculations. - Village builder/slot capacity rules. - Upgrade lifecycle
transitions. - Notification reminder policy. - Validation rules.

Domain logic must not depend on Flutter widgets, SQLite, or notification
plugins.

### Data

Drift database, DAOs/repositories, catalog source, and JSON backup codec
when implemented. This layer maps database rows to domain models and
owns migrations.

### Platform services

A notification adapter wraps `flutter_local_notifications` and
Android-specific behavior. UI and domain code call an app-owned
interface rather than the plugin directly.

## 4. Suggested directory layout

``` text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme/
      app_theme.dart
      app_colors.dart
      app_typography.dart
  core/
    clock/
      clock.dart
    errors/
      app_failure.dart
    formatting/
      duration_format.dart
      date_time_format.dart
    ids/
      id_generator.dart
  database/
    app_database.dart
    tables/
      villages_table.dart
      upgrades_table.dart
      upgrade_catalog_table.dart
      notification_preferences_table.dart
    daos/
      villages_dao.dart
      upgrades_dao.dart
    migrations/
  domain/
    models/
      village.dart
      upgrade.dart
      upgrade_category.dart
      upgrade_status.dart
    services/
      upgrade_timer_service.dart
      upgrade_lifecycle_service.dart
      builder_capacity_service.dart
      notification_plan_service.dart
  features/
    dashboard/
      presentation/
      application/
    villages/
      presentation/
      application/
    upgrades/
      presentation/
      application/
    catalog/
      presentation/
      application/
    history/
      presentation/
      application/
    settings/
      presentation/
      application/
  services/
    notifications/
      notification_service.dart
      local_notification_service.dart
      notification_reconciler.dart
  shared/
    widgets/
    forms/
test/
  domain/
  database/
  features/
integration_test/
```

Do not create empty layers or files simply to match this diagram.
Introduce a file when there is real code to own.

## 5. Data model

### Village

-   `id`: primary key.
-   `name`: required display name.
-   `townHallLevel`: optional integer.
-   `builderCapacity`: positive integer, default selected by the user.
-   `createdAt`, `updatedAt`: UTC timestamps.
-   `isArchived`: boolean or integer.
-   Optional `sortOrder`.

### Upgrade

-   `id`: primary key.
-   `villageId`: foreign key to Village.
-   `name`: required display name.
-   `category`: building, hero, laboratory, troop, spell, pet,
    equipment, other; category set may evolve.
-   `slotKey`: optional identifier for a builder or upgrade slot. A
    free-text slot is not required in v1; model slot assignment only
    where the UI uses it.
-   `catalogItemId`: optional reference to catalog entry.
-   `durationSeconds`: original intended duration, nullable only if the
    app supports a completion-time-only workflow.
-   `startedAtUtc`: timestamp.
-   `expectedCompletionAtUtc`: timestamp and source of truth for
    remaining time.
-   `status`: active, completed, cancelled.
-   `completedAtUtc`: nullable.
-   `notes`: optional.
-   `createdAtUtc`, `updatedAtUtc`.
-   `notificationRevision`: integer used to invalidate stale scheduled
    notification plans if useful.

Recommended indexes: - `(villageId, status, expectedCompletionAtUtc)` -
`(status, expectedCompletionAtUtc)` - `catalogItemId` if catalog joins
are common.

### Catalog item

-   `id`: stable string key.
-   `name`, `category`.
-   `townHallLevel`: optional applicability hint.
-   `upgradeLevel`: optional.
-   `durationSeconds`: optional and only populated when verified.
-   `sourceLabel`, `sourceUpdatedAt`, and `confidence/status` if
    maintaining a sourced catalog.
-   Catalog records must be bundled locally and versioned; no network
    sync in v1.

### Notification preferences

A small settings table or serialized settings record: - completion alert
enabled. - pre-alert offsets. - quiet hours, if implemented. -
user-facing permission state should be queried from the platform rather
than treated as permanently authoritative database data.

## 6. Timer behavior

-   Store `expectedCompletionAtUtc` as an absolute instant.
-   Remaining time is computed as `expectedCompletionAtUtc - now`.
-   A UI ticker may refresh visible countdowns every second or minute,
    but it must not mutate the stored completion timestamp.
-   On opening the app, recalculate all visible countdowns from the
    current clock.
-   If completion time is in the past and status remains active, show
    "Ready to collect/finish" or "Past due" and offer an explicit
    completion action; do not silently rewrite history.
-   For custom "remaining duration" input, set
    `expectedCompletionAtUtc = now + duration`.
-   For custom start-time and duration input, calculate
    `expectedCompletionAtUtc = startedAtUtc + duration`.
-   Use a clock abstraction in domain tests so time calculations are
    deterministic.
-   Handle device time changes by recalculating from wall-clock time
    when the app resumes.

## 7. Upgrade lifecycle

Allowed transitions: - `active -> completed` - `active -> cancelled` -
`completed -> active` only through an explicit "reopen/re-track" action,
if supported. - `cancelled -> active` only through an explicit "restart
tracking" action, if supported.

Editing an active timer updates its completion timestamp and
notification schedule. Completion and cancellation must be transactional
where database updates and notification reconciliation need coordinated
handling. Since SQLite and Android notifications cannot share a
transaction, persist the domain change first, then reconcile
notifications. On next launch, reconciliation repairs any partial
failure.

## 8. Notification architecture

Use a `NotificationService` interface with operations such as: -
initialize platform notification support. - request permission when
appropriate. - schedule reminders for an upgrade. - cancel all reminders
for an upgrade. - reconcile scheduled notifications with active database
upgrades. - open/query platform settings only when supported and
necessary.

Generate stable integer notification IDs from a deterministic mapping or
maintain an explicit mapping table. Avoid using a runtime hash whose
value may not be stable across launches.

Each active upgrade may have multiple notifications: completion and one
or more pre-alerts. Notification IDs must be unique per upgrade and
reminder offset. If the platform/plugin has a limit or exact-alarm
behavior requiring configuration, document it and test it.

### Reconciliation

At app launch and after reboot: 1. Query all active upgrades. 2. Derive
the intended notification schedule from current preferences and expected
completion times. 3. Query pending notifications where supported. 4.
Cancel stale notifications and schedule missing or changed
notifications. 5. Record/log a diagnostic outcome without collecting
personal data.

Do not schedule reminders in the past. If a pre-alert time has passed
but completion is still in the future, skip the missed pre-alert and
keep the completion notification.

Android exact alarms and notification permission behavior vary by
Android version. Prefer inexact scheduling unless exact timing is a
demonstrated requirement. If exact alarms are offered, explain the
permission and battery implications and verify current Android policy
before implementation.

## 9. Offline and backup strategy

-   No network calls in core workflows.
-   Bundled catalog assets are read-only defaults; user data lives in
    SQLite.
-   v1.1 backup export serializes villages, upgrades, preferences, and
    schema version to JSON.
-   Import must validate format, IDs, timestamps, and foreign keys
    before replacing or merging data.
-   Never overwrite current user data without a confirmation and a
    recoverable backup.
-   Avoid storing backups in a hidden or app-inaccessible location.

## 10. Error handling

Use typed application failures for expected errors: - validation
error. - village not found. - capacity/slot conflict. - database
operation failed. - notification permission denied. - notification
scheduling failed. - invalid backup file.

Show user-friendly messages. Avoid swallowing exceptions. Logs should
not include unnecessary personal data.

## 11. Migration and schema policy

-   Enable Drift schema versioning and migrations from the first
    database release.
-   Add migration tests for every schema change.
-   Never edit a released schema without a migration.
-   Seed bundled catalog data idempotently and version it separately
    from user records.
-   Avoid destructive migration strategies unless explicitly approved
    for a disposable development database.

## 11. Android home-screen widget architecture

Native Android home-screen widgets are implemented using `home_widget` (AppWidgetProvider):
- **Upgrade Overview Widget (`UpgradeOverviewWidgetProvider`)**: Shows selected village name, active upgrades badge count, nearest upcoming upgrade name/category, remaining duration/countdown, and visual progress bar.
- **Builder Status Widget (`BuilderStatusWidgetProvider`)**: Shows selected village, total/available/busy builder stats, and active builder occupancy summary.
- **Data Synchronization (`HomeWidgetSyncService`)**: Maintains a lightweight read-only snapshot in SharedPreferences updated on upgrade state changes, village switches, and app startup. Does not execute battery-draining continuous background loops.

## 12. Testing strategy

### Unit tests

-   remaining-time calculation.
-   start-time/duration conversion.
-   past-due state.
-   lifecycle transition validation.
-   reminder timestamp generation and skipping past reminders.
-   stable notification ID mapping.
-   builder capacity and slot conflicts.

### Database tests

-   create/update/archive/delete village.
-   cascade/restrict behavior for upgrades.
-   query active upgrades by village.
-   all-village upcoming sort.
-   migrations and seed idempotency.

### Widget tests

-   village switcher.
-   empty dashboard.
-   active upgrade card.
-   custom timer form validation.
-   notification settings/permission states.

### Device/integration tests

-   create timer and receive scheduled notification.
-   edit timer and verify old reminders are cancelled.
-   cancel timer and verify reminders are removed.
-   restart device and confirm schedule reconciliation.
-   deny notification permission.
-   app remains correct after force-close and reopening.
-   timezone and system-clock changes.

## 13. Key trade-offs and known limitations

-   Local notifications require Android permissions and may be delayed
    by battery restrictions or manufacturer-specific behavior.
-   The app cannot automatically know whether an upgrade finished in the
    game. The user must mark it complete or manually update the timer.
-   Catalog durations may change as the game changes; bundled catalog
    entries need a source and review process.
-   Local-only data means uninstalling the app can remove data unless a
    backup exists.
-   Cross-device sync is deliberately not part of v1.

## 14. Profile-first entry & display preferences architecture

### Profile-first entry (`VillageProfilesScreen`)
- The application boots directly into `VillageProfilesScreen`, presenting all user-created village profiles as distinct cards displaying Town Hall, Builder Hall, and Builder capacity badges.
- Tapping a village opens `DashboardScreen(selectedVillageId: village.id)`.
- Eliminates duplicate switchers: Dashboard AppBar presents a clean village title with levels and a back button returning to `VillageProfilesScreen`.

### Display & formatting preferences
- User-customizable time format: 12-hour (`03:45 PM`) vs 24-hour (`15:45`).
- User-customizable date format: `DD/MM/YYYY`, `MM/DD/YYYY`, and `YYYY-MM-DD`.
- Stored in `SharedPreferences` and managed reactively via `displayPreferencesProvider`.
- All database timestamps remain in UTC (`DateTime` in UTC); formatting is strictly a presentation-layer concern handled by `DateTimeFormat`.

### Dynamic offline support QR code
- Offline dynamic QR generation using `qr_flutter` rendered from `AppSupportLinks.qrPayload` (`9739337301@jupiteraxis`).
- No external network or QR generation API dependencies.
- Quick copy affordance with snackbar confirmation.

### SFX player pooling
- Multi-instance round-robin audio player pool in `AudioService` with `AndroidAudioFocus.none` context preventing latency, clipped audio, or dropped chimes on rapid successive taps.

## 15. Navigation hierarchy, themes & startup optimization

### Profile editing and bottom-right FAB
- `VillageProfilesScreen` serves as the central hub for profile management: each profile card includes an inline Edit action (`Icons.edit_outlined`) launching `AddVillageSheet(village: village)` to update name, Town Hall level, Builder Hall level, builder capacity, and notes directly on the existing SQLite record without duplicating data.
- The Add Village action is positioned as a bottom-right `FloatingActionButton.extended`, aligning with the design pattern used in the Upgrade and Planner screens while eliminating redundant header buttons.

### Scoped internal tabs
- Internal tabs (`PlannerScreen` and `LevelsScreen`) strictly scope all queries and data presentation to the village selected on the opening screen. Profile switch dropdowns are completely removed from internal screens to prevent context confusion.

### Back vs Home navigation & PopScope
- Explicit separation between Back navigation (`Navigator.maybePop` / Android system back) and Home navigation (`Icons.home_outlined`).
- `DashboardScreen` wraps its view hierarchy with `PopScope`: system back invocations on non-zero tabs (Planner, Levels, Settings) return to Tab 0 (Dashboard) instead of exiting the village context. Back on Tab 0 returns cleanly to `VillageProfilesScreen`.

### Startup performance and lazy audio
- Background services (notification reconciliation, exact alarm checks, home widget synchronization) are deferred by 2 seconds off the critical launch frame.
- Audio player instances are created lazily upon first audio playback demand rather than eagerly constructing method channels during boot, delivering instantaneous sub-second profile screen rendering.

### Dynamic Material 3 themes
- Appearance options: System Default, Dark Mode (default), and Light Mode managed by `themePreferencesProvider` and stored in `SharedPreferences` (`pref_theme_mode`).
- `AppColors` dynamically toggles between high-contrast light and dark palettes via `setLight(bool)`, seamlessly supporting existing design token references.
- Dedicated `buildLightTheme()` and `buildDarkTheme()` provide Material 3 compliance.

### Relative completion date formatting
- `DateTimeFormat.relativeCompletionDateTime` formats upgrade completion targets into intuitive relative human-readable representations: `Today, <time>`, `Tomorrow, <time>`, or localized calendar dates for later days, with accurate handling for near-midnight transitions across day boundaries.

## 16. Clash of Clans JSON import & backup/restore architecture

### Village JSON import architecture
- **Parser (`CocVillageJsonParser`)**: 100% offline, deterministic parser supporting all standard CoC export sections (`buildings`, `traps`, `units`, `siege_machines`, `heroes`, `spells`, `pets`, `equipment`, `buildings2`, `traps2`, `units2`, `heroes2`, `helpers`, `boosts`, `decos`, `obstacles`, and nested `types[].modules[]`).
- **Catalogue mapping (`CocDataIdCatalog`)**: Built-in repository mapping 150+ game data IDs to canonical names, facilities, and subcategories across Home Village and Builder Base. Unrecognized or future IDs are isolated in an unmapped preview list without halting the import.
- **Quantity and multi-level persistence**: Schema version 7 extends `VillageItemLevels` with `quantity` and `dataId` columns and a composite unique constraint on `(villageId, category, itemName, currentLevel)`, faithfully representing distributions such as 40 level 13 walls and 260 level 14 walls.
- **Timer calculation**: `snapshot_time = timestamp`, `remaining_seconds = timer`, `completion_time = snapshot_time + remaining_seconds`. Future completions schedule active upgrades with calculated remaining time; past completions record the level in the Levels tab and flag the expired timer for review. Helper timers (`helper_timer`, `helper_cooldown`) are explicitly ignored.
- **Transactional import service (`CocVillageImportService`)**: Executes entire import inside a single SQLite transaction with Merge vs Replace support, duplicate upgrade skipping, Town Hall / Builder Hall updates, and audit logging to the `VillageImports` table. Automatically reconciles notifications and widgets post-transaction.

### Full application backup & restore (`BackupService`)
- **Format**: Portable `.clashcommandbackup` ZIP archive containing:
  - `manifest.json`: Versioned metadata (`appName`, `appVersion`, `backupFormatVersion: 1`, `databaseSchemaVersion: 7`, record counts per table).
  - `database.json`: Full typed JSON dump of all 8 Drift tables.
  - `preferences.json`: Exported user key-value preferences from `SharedPreferences`.
- **Restoration safety**:
  - Validates archive structure, application identifier, and supported format versions prior to executing restore.
  - Automatically creates a local safety backup (`safety_pre_restore.clashcommandbackup`) before wiping existing tables.
  - Clears tables in strict foreign-key order and inserts restored rows within a single atomic database transaction. If an error occurs, the transaction automatically rolls back.
  - Automatically reschedules all notifications and syncs home-screen widgets following successful restoration.
