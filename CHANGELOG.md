# Changelog

All notable changes to Clash Command are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Full Village Editing & Deletion**: Added edit modal and deletion confirmation dialog explaining cascade deletion of active upgrades and activity events.
- **Village Notes & Capacity**: Added notes field and 1-6 builder capacity configuration.
- **Visible Upgrade Action Controls**: Replaced hidden long-press actions with visible popup menu affordance (`PopupMenuButton`) on every upgrade card.
- **Upgrade Detail Sheet (`UpgradeDetailSheet`)**: Tap-to-inspect detail view displaying countdown, progress bar, started at, expected completion, notes, quick actions (Complete, Edit, Cancel, Delete), and recent upgrade activity.
- **Upgrade Editing (`AddUpgradeSheet`)**: Supports modifying upgrade name, category, builder slot, notes, and remaining duration without unintentionally rewriting the original start time.
- **Activity History & Audit Trail**:
  - Added Drift `HistoryEvents` table with schema version 2 migration (`from < 2`).
  - Added `HistoryEventsDao` with methods to stream village and upgrade events.
  - Automatically records events for village creation, editing, deletion, upgrade starting, completion, cancellation, reopening, timer editing, and deletion.
  - Added dedicated `HistoryScreen` with village and event-type filter chips and reverse-chronological timeline.
- **Dedicated Settings Screen (`SettingsScreen`)**:
  - Live system notification permission status check and contextual rationale dialog.
  - Master toggles for completion alerts and upcoming pre-completion reminders.
  - Configurable reminder intervals (60m, 30m, 10m, 5m, 1m) with immediate notification reconciliation.
  - Instant test notification trigger to verify device alert delivery.
  - Offline-first architecture note and app version information.
- **Main Navigation Bar**: Bottom navigation bar switching smoothly between Dashboard, Activity History, and Settings.
- **WebAssembly SQLite Assets**: Matched `sqlite3.wasm` and `drift_worker.js` with `drift: 2.35.2` to eliminate WebAssembly link/instantiation errors on web targets.

### Fixed
- Fixed module export paths in `lib/database/openers.dart` to properly reference the `openers/` subfolder.
- Fixed `Village.copyWith` and `Upgrade.copyWith` to allow nulling-out optional fields via explicit clear flags.
- Fixed notification body text in `NotificationPlanService` to display actual village names instead of raw UUIDs.
- Fixed Android Gradle build desugaring and Java 17 toolchain configurations.

