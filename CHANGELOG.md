# Changelog

All notable changes to Clash Command are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-10-24

### Changed & Improved
- **Dashboard Screen UI/UX Hierarchy**:
  - Replaced cluttered card layout with a clean hierarchy: Top-level Village Realm Switcher (`Home Village` vs `Builder Base`), icon-based Category Selector, and category-filtered upgrade list.
  - Eliminated dropdown for primary category selection in favor of dedicated, high-contrast icon buttons with active upgrade counts.
  - Upgrades are strictly filtered to the selected category, eliminating screen clutter and visual density.
  - Converted the village profile switcher to a compact AppBar dropdown when multiple villages exist.
  - Replaced heavy summary cards with a sleek, lightweight capacity banner and expandable accordion for village notes.
- **Add Upgrade Form & Zero-Lag Search Optimization**:
  - Pre-indexed the local 1,000+ item catalogue into an $O(1)$ category cache, eliminating search latency and memory allocations on keystrokes.
  - Resolved `FocusNode` rebuild bug that caused focus loss, IME composing glitches, and keyboard stutter.
  - Replaced category dropdown in the form with clear icon-based controls matching the dashboard's village and facility selectors.
- **Simplified Single Destination Level Input**:
  - Replaced the confusing two-field From Level / To Level input with a single optional field labelled **Upgrade to level** (e.g. `68`).
  - Fixed the multi-digit text input issue, ensuring values like `67`, `68`, and `100` are completely preserved without truncation or digit loss.
  - Validates positive integers with catalogue-verified limits while preserving freedom for custom upgrade levels.
  - Standardized compact display across cards, details, and activity logs as `Archer Tower → Lv. 68`.
- **RenderFlex Overflow & Small Screen Responsiveness**:
  - Bound bottom sheets with `SafeArea`, max-height constraints, and keyboard `viewInsets` padding so the form scrolls smoothly on small screens.
  - Constrained autocomplete options menu height (`maxHeight: 180`) to prevent keyboard collision and layout overflow.
  - Made upgrade card text and timer columns responsive with text truncation and wrapping to eliminate horizontal overflows on narrow screens.

## [1.0.2] - 2026-10-23

### Added
- **Town Hall 18 & Extensible Level Architecture (`TownHallConstants`)**:
  - Added support for Town Hall 18 in village setup and upgrade catalogue.
  - Replaced hardcoded limits with a centralized, data-driven `TownHallConstants` structure so future Town Hall levels (including TH19) can be added via configuration without rewriting form UI or core tracking logic.
- **Four Distinct Upgrade Facilities & Categories**:
  - **Home Village — Builder**: Buildings, defenses, heroes, traps, and walls.
  - **Home Village — Laboratory**: Elixir troops, dark elixir troops, spells, and siege machines.
  - **Builder Base — Builder**: Builder Base buildings, defenses, heroes, and traps.
  - **Builder Base — Star Laboratory**: Builder Base troop research.
  - Preserved backward compatibility for all legacy stored categories (`building`, `hero`, `defense`, `laboratory`, etc.).
- **Upgrade Name Autocomplete & Local Suggestion Catalogue**:
  - Interactive searchable autocomplete dropdown that filters matching suggestions case-insensitively with partial matching.
  - Prioritizes exact matches, prefix matches, and items unlockable at the village's current Town Hall level.
  - Contextual subtitles in suggestions displaying building/troop type and confirmed maximum level.
  - Strict category partitioning so suggestions are never mixed across facilities (e.g. Home Lab troops never appear under Builder Base buildings).
- **Custom Upgrade Suggestions Persistence**:
  - Users can enter and save completely custom upgrade names without being blocked.
  - Added Drift table `CustomUpgradeSuggestions` and DAO with case-insensitive and whitespace-trimmed deduplication.
  - Saved custom names automatically appear in future autocomplete queries for the same category.
- **Optional From Level & To Level Fields**:
  - Optional `fromLevel` and `toLevel` integer fields on add and edit upgrade sheets.
  - Smart suggestion: Selecting a catalogue item auto-fills suggested initial levels; entering From Level suggests `fromLevel + 1` for To Level.
  - Form validation ensures positive integers and enforces `toLevel > fromLevel` when both fields are provided.
  - Compact title representation on upgrade cards and detail views: `Archer Tower · Lv. 18 → 19`.
  - Preserved level metadata across editing and activity-history timeline entries.
- **Drift Database Schema v3 Migration**:
  - Incremented schema version to 3 with non-destructive `onUpgrade` step adding `from_level` and `to_level` nullable columns to `upgrades` and creating `custom_upgrade_suggestions`.
  - All existing village records, upgrade timers, and historical events remain fully intact.

## [1.0.1] - 2026-10-22

### Added
- **Native Android Home-Screen Widgets**:
  - **Upgrade Overview Widget (`UpgradeOverviewWidgetProvider`)**: Shows Clash Command badge, village name, active upgrades badge, nearest upcoming upgrade name/category, countdown timer, and styled progress bar. Tap opens app.
  - **Builder Status Widget (`BuilderStatusWidgetProvider`)**: Shows village name, free vs busy builder counts, total builders, and compact builder occupancy summary. Tap opens app.
  - **Widget Data Synchronization (`HomeWidgetSyncService`)**: Maintains a lightweight, read-only native snapshot updated automatically on upgrade creation, editing, status change, village switching, and app launch.
  - **Android Widget Manifest & Layouts**: Added `res/layout/widget_upgrade_overview.xml`, `res/layout/widget_builder_status.xml`, provider metadata in `res/xml/`, and receivers in `AndroidManifest.xml`.
- **Notification Diagnostics Section in Settings**:
  - Live readout of system notification permission status.
  - Exact-alarm scheduling mode status (Exact vs Inexact While-Idle).
  - Count of currently active upgrades in the database.
  - Real-time count of pending alarms/notifications queued in the Android system.
  - Next expected completion timestamp in device local time.
- **Distinctive App Branding & Launcher Icons**:
  - Designed an original Clash Command emblem featuring a reinforced war crest shield, upward progression arrow, strategic command star, and golden studs on an obsidian battle background.
  - Added high-resolution master asset (`assets/branding/logo.png`) and transparent badge (`assets/branding/logo_transparent.png`).
  - Generated full Android mipmap legacy icons (`ic_launcher.png`) and adaptive foreground icons (`ic_launcher_foreground.png`) across `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, and `xxxhdpi`.
  - Added Android adaptive icon definition (`mipmap-anydpi-v26/ic_launcher.xml`) with safe-zone margin geometry and dark background color (`#1A1A1A`).
  - Added web icons and favicon (`web/icons/`, `web/favicon.png`).
  - Added reproducible asset generation script (`scripts/generate_branding_assets.py`) and `make branding` target.
  - Integrated emblem and active version display (`Version 1.0.1 (Build 2)`) into the in-app Settings screen.
- **Release & Versioning Documentation**:
  - Created comprehensive release guide in `docs/releases.md` detailing versioning strategy (`MAJOR.MINOR.PATCH+BUILD`), debug vs release APKs, release signing setup, pre-release quality checklist, and release notes template.
  - Added optional release keystore support via `android/key.properties` with fallback to debug keys in `android/app/build.gradle.kts`.
  - Explicitly ignored release keys and `key.properties` in `.gitignore`.
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
- **Upgrade Completion Notification Delivery**: Fixed the bug where test notifications worked but scheduled upgrade notifications failed to fire.
  - Declared `ScheduledNotificationReceiver` and `ScheduledNotificationBootReceiver` in `AndroidManifest.xml` (required by FlutterLocalNotifications 16+ so Android AlarmManager broadcasts are not dropped).
  - Added `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` permissions.
  - Upgraded schedule mode to `AndroidScheduleMode.exactAllowWhileIdle` with graceful fallback to `inexactAllowWhileIdle` to guarantee execution while device is idle or in Android Doze mode.
  - Ensured UTC TZDateTime interpretation to eliminate timezone offset discrepancies.
  - Fixed notification reconciler bug where existing pending requests were incorrectly skipped instead of updating to the latest target fire time.
  - Added native `requestExactAlarmsPermission()` and integrated an "Allow Exact Alarms" action in Settings diagnostics to ensure exact-to-the-minute delivery on Android 13/14+.
  - Updated `upgrades_notifier.dart` to respect user notification preferences and village names across all upgrade lifecycle actions.
  - Expanded `idsForUpgrade` to cancel all 10 possible pre-alerts and obsolete completion alarms.
- **Android Home-Screen Widget Crash ("Error loading the widgets")**: Fixed the launcher inflation crash.
  - Replaced forbidden `<View>` divider tags with `<FrameLayout>` across `widget_upgrade_overview.xml` and `widget_builder_status.xml`, satisfying Android's strict `RemoteViews` class allowlist.
  - Fixed horizontal progress bar attribute resolution by referencing `@android:style/Widget.ProgressBar.Horizontal` instead of theme-dependent attributes.
  - Added top-level `try / catch` error handlers with logging inside widget providers.
  - Set `android:exported="true"` on widget receivers to ensure launcher compatibility across diverse OEM launchers.
- **Live Seconds Countdown for Imminent Upgrades**:
  - Implemented live `MM:SS` seconds countdown (`04:59`, `02:37`, `00:45`, etc.) whenever remaining time is strictly less than 5 minutes (< 300s).
  - Added an adaptive 1-second refresh ticker that activates exclusively during the < 5 minute window and cleanly disposes when completed or inactive.
  - Integrated seconds display across Dashboard upgrade cards, Upgrade Detail sheets, and native Android home-screen widgets.
  - Added unit test coverage covering 5m, 4m59s, 1m, 1s, 0s, and negative durations.
- **Village Builder Capacity**: Fixed builder availability counting to use village `builderCapacity` rather than hardcoded assumptions.
- Fixed module export paths in `lib/database/openers.dart` to properly reference the `openers/` subfolder.
- Fixed `Village.copyWith` and `Upgrade.copyWith` to allow nulling-out optional fields via explicit clear flags.
- Fixed notification body text in `NotificationPlanService` to display actual village names instead of raw UUIDs.
- Fixed Android Gradle build desugaring and Java 17 toolchain configurations.

