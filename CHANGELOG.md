# Changelog

All notable changes to Clash Command are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2026-10-31

### Added
- **Profile Card Editing & Bottom-Right FAB**:
  - Added an Edit button on every village card in `VillageProfilesScreen` opening `AddVillageSheet(village: village)` to edit name, Town Hall level, Builder Hall level, builder capacity, and notes without duplicate entries.
  - Moved Add Village action to a bottom-right `FloatingActionButton.extended` with gold accent styling, removing the old header button and avoiding duplicate add actions.
- **Dynamic Light & Dark Themes**:
  - Implemented `ThemePreferencesNotifier` with System Default, Dark Mode (default), and Light Mode options persisted in `SharedPreferences` (`pref_theme_mode`).
  - Implemented `buildLightTheme()` and `buildDarkTheme()` in `app_theme.dart` with high-contrast surfaces, readable text, and gold accents.
  - Upgraded `AppColors` with dynamic getters and palette switching (`setLight`) adapting all existing color references across the app.
  - Added Appearance & Theme configuration card in Settings with `SegmentedButton`.
- **Relative Completion Dates (Today & Tomorrow)**:
  - Added `DateTimeFormat.relativeCompletionDateTime` formatting completions as `Today, <time>` or `Tomorrow, <time>`, and formatted calendar dates for later days.
  - Integrated into `UpgradeCard`, `UpgradeDetailSheet`, and Dashboard Next upgrade indicator. Accurately accounts for midnight transitions using local calendar day comparisons.
- **Back vs Home Navigation Semantics**:
  - Distinguished genuine Back actions (`Navigator.maybePop`) from Home navigation (`Icons.home_outlined`).
  - Added `PopScope` on `DashboardScreen`: system back on Planner, Levels, or Settings tabs returns to tab 0 (Dashboard). System back on Dashboard returns to profile selection.
  - Added leading Home button on internal tabs returning directly to the active village Dashboard.

### Changed & Fixed
- **Scoped Internal Tabs Strictly to Selected Village**:
  - Removed all `DropdownButton` village switchers from Planner and Levels screens. All internal tabs strictly scope data to the active profile chosen at app launch.
  - Replaced headers with clean, static titles and active village subtitles.
- **Startup Latency Elimination**:
  - Eliminated all eager `AudioPlayer` channel creation at startup; audio player pool is now instantiated lazily on demand.
  - Deferred background notification reconciliation, exact alarm init, and widget sync by 2 seconds off the critical launch path.
- **Refined Audio Experience**:
  - Constrained audio playback strictly to meaningful actions: opening a profile (`playVillageSwitch`), starting an upgrade (`playUpgradeStart`), adding a plan (`playItemAdd`), adding a level entry (`playItemAdd`), and saving a village (`playConfirm`).
  - Removed all sound effects from bottom navigation tab clicks, screen opening, Back/Home buttons, scrolling, and typing.

## [1.0.7] - 2026-10-31

### Added
- **Dynamic In-App Support QR Code**:
  - Dynamically generated offline UPI QR code powered by `qr_flutter` with exact payload `9739337301@jupiteraxis` configured in `AppSupportLinks.qrPayload`.
  - Displayed prominently in Settings → Support inside a high-contrast white card with quick copy button and scan instructions.
- **Display & Formatting Preferences**:
  - User-configurable time format: 12-hour (`03:45 PM`) vs 24-hour (`15:45`).
  - User-configurable calendar date format: `DD/MM/YYYY`, `MM/DD/YYYY`, and `YYYY-MM-DD`.
  - Persisted in local `SharedPreferences` and reactively wired via `displayPreferencesProvider` across `UpgradeCard`, `UpgradeDetailSheet`, `HistoryScreen`, `LevelsScreen`, and `DashboardScreen`.
- **Profile-First App Entry Experience**:
  - Introduced `VillageProfilesScreen` as the initial application screen displaying all saved village profile cards with Town Hall, Builder Hall, and Builder capacity badges.
  - Branded startup loading animation with glowing pulse and error recovery state.
  - Tapping any village card directly opens that village's dashboard.
- **Support Documentation**:
  - Added root-level `SUPPORT.md` outlining the ad-free, 100% free open-source mission, voluntary UPI ID (`9739337301@jupiteraxis`), Ko-fi, PayPal, and developer portfolio links.
  - Updated `README.md` with Support and Contributions section linking to `SUPPORT.md`.
- **Audio Service SFX Pool & Focus Optimization**:
  - Multi-instance round-robin audio player pool eliminating dropped sound effects during rapid taps.
  - Pre-allocated audio volumes and `AndroidAudioFocus.none` context preventing latency and audio clipping.

### Changed & Fixed
- **Eliminated Duplicate Profile Selectors**:
  - Removed redundant `_VillageDropdownTitle` from Dashboard AppBar and removed duplicate horizontal choice chips from the dashboard body.
  - Dashboard AppBar now displays the selected village name and Town Hall/Builder Hall levels with a clean back button to return to village profiles.
- **Simplified External Links in App**:
  - Removed separate GitHub repository and GitHub profile tiles from in-app UI. Retained developer portfolio, Ko-fi, and PayPal donation links.

## [1.0.6] - 2026-10-31

### Added
- **Instant Staged App Startup**:
  - Eliminated the 5–10 second blocking startup delay by running `runApp()` immediately upon app execution.
  - Deferred heavy services (`notificationServiceProvider.initialize()`, `notificationReconcilerProvider.reconcile()`, `homeWidgetSyncServiceProvider.syncWidgets()`) to non-blocking post-frame background tasks.
  - Added `_DashboardSkeleton` with smooth placeholder cards to display the UI shell instantly without spinners or layout jumps.
- **Audio System & Ambient Soundtrack**:
  - Procedurally synthesized 8 original 16-bit 44.1kHz PCM audio assets in `assets/audio/` (button tap, village switch, upgrade start, upgrade complete, item add, confirm, error, and a seamless 5-second harmonic ambient music loop).
  - Implemented `AudioService` with Android lifecycle observation (`WidgetsBindingObserver`) to auto-pause music in background and resume on foreground.
  - Added Audio Settings section in Settings with toggles for Sound Effects (ON by default) and Ambient Music (OFF by default), plus smooth volume sliders (0–100%) persisted in `SharedPreferences`.
  - Wired interactive audio chimes to bottom navigation, village switching, upgrade creation, planner additions, and confirmations.
- **Prominent Village/Profile Switcher & Persistence**:
  - Added horizontal profile choice chips directly on the Dashboard header for instant 1-tap village switching.
  - Automatically loads and persists `last_selected_village_id` via `SharedPreferences`.
- **TH17 Hero Cap Updates & Dragon Duke**:
  - Updated built-in catalogue max levels to official Town Hall 17 release values:
    - Barbarian King: Max Level 100 (up from 95)
    - Archer Queen: Max Level 100 (up from 95)
    - Grand Warden: Max Level 75 (up from 70)
    - Royal Champion: Max Level 50 (up from 45)
    - Minion Prince: Max Level 90 (up from 40)
    - Added new TH17 Hero `Dragon Duke` (minTownHall: 17, maxLevel: 20)
    - Verified Battle Machine and Battle Copter max level caps at 35 (Builder Hall 10).
- **Settings — About & Developer Support Enhancements**:
  - Added dedicated Activity History navigation tile in Settings.
  - Added live links to developer Portfolio (`https://amruthlp.vercel.app/`) and Ko-fi (`https://ko-fi.com/amruthlp`).
  - Added friendly open-source community support message in Settings.

### Changed & Fixed
- **Navigation Bar Streamlining**:
  - Reduced bottom navigation from 5 destinations to 4: `Dashboard`, `Planner`, `Levels`, and `Settings`.
  - Moved `Activity History` into Settings as an accessible dedicated screen.
- **Track Upgrade — Duration Inputs & Validation**:
  - Days, hours, and minutes input fields now start empty instead of prefilled with `0`.
  - Empty fields are treated as `0`; validation error displays only when total duration is 0 or all fields are blank.
- **Planner → Start Upgrade Duration Transfer**:
  - Fixed bug where starting an upgrade from the Planner reset remaining duration to 0 by adding `initialDurationSeconds` to `AddUpgradeSheet` and passing `item.durationSeconds`.
  - Automatically transitions planner item status to `started` upon starting the upgrade.
- **Planner — Simplified Single Resource Cost Entry**:
  - Streamlined resource entry to a single dropdown selector and amount input field, removing the redundant `+` chip UI while maintaining 100% backwards-compatibility with existing data.

## [1.0.5] - 2026-10-24

### Added
- **Levels Tab — Item Types & Subcategory Classification**:
  - Implemented full 5-tier selection hierarchy: Village -> Category -> Item Type -> Item Name -> Current Level.
  - Interactive, functional item type selectors with visible selection state:
    - **Home Village — Builder**: `Buildings`, `Defences`, `Traps`, `Heroes`, `Hero Pets`, `Other`.
    - **Home Village — Laboratory**: `Troops`, `Spells`, `Siege Machines`, `Other`.
    - **Builder Base — Builder**: `Buildings`, `Defences`, `Traps`, `Heroes`, `Other`.
    - **Builder Base — Star Laboratory**: `Troops`, `Other`.
  - Autocomplete catalogue immediately updates to display only items matching the active item type.
  - Added 10 verified Hero Pets (`L.A.S.S.I`, `Electro Owl`, `Mighty Yak`, `Unicorn`, `Frosty`, `Diggy`, `Poison Lizard`, `Phoenix`, `Spirit Fox`, `Angry Jelly`) with confirmed TH unlock levels (TH14–16) and max levels.
  - Auto-inference: selecting a known catalogue item automatically suggests the correct item type while allowing manual override.
  - Subcategory filtering on `LevelsScreen` and concise item type badge indicators on cards (`🛡️ Defence`, `👑 Hero`, `🐾 Pet`, `⚔️ Troop`, `✨ Spell`, `🏛️ Building`, `⚠️ Trap`) replacing redundant category labels.
- **Levels Tab — Fully Editable Tracked Items**:
  - Full editability of item name, realm, category, item type, village assignment, and current level in `AddLevelSheet`.
  - Safe uniqueness conflict resolution: editing or renaming an item to match an existing record in the same village and category merges into the existing record cleanly without SQLite constraint failures.
- **Advanced Upgrade Planner — Duration and Resource Planning**:
  - Optional estimated duration entry with days, hours, and minutes fields, prefilled when editing.
  - Optional required resources entry supporting tailored resource types by realm (Home Village: Gold, Elixir, Dark Elixir; Builder Base: Builder Gold, Builder Elixir) with numeric amounts and multi-resource support.
  - Compact duration and color-coded resource badge indicators directly on planner cards.
  - Comprehensive Planner Filter & Search panel:
    - Text search by item name.
    - Status filtering (Planned, In Progress / Started, Completed, All).
    - Category filtering (Builder, Laboratory, Star Laboratory, All).
    - Priority filtering (High, Medium, Low, All).
    - Duration range filtering (< 1 day, 1–3 days, 3–7 days, > 7 days, or unset).
    - Resource type filtering (Gold, Elixir, Dark Elixir, Builder Gold, Builder Elixir).
    - Active filter counter badge with a one-tap "Clear all" reset action.
- **Settings — Developer & Support Links**:
  - Dedicated "Developer & Support" section in Settings.
  - Direct links to the official GitHub repository and developer GitHub profile.
  - Configurable portfolio and PayPal donation links with explicit, informative fallbacks when not yet configured.
  - Support QR code viewer with tap-to-enlarge modal dialog for easy scanning.
  - Centralized link and QR configuration in `AppSupportLinks` (`lib/core/constants/app_support_links.dart`).
  - Safe URL opening using `url_launcher` with error handling and user-friendly notifications.
- **Drift Database Schema v6 Migration**:
  - Upgraded schema version to 6 with non-destructive migrations adding `duration_seconds` and `resources_json` columns to `planner_items`, and `item_type` column to `village_item_levels`.

### Changed & Improved
- **App Startup Performance & Lazy Loading**:
  - Replaced eager screen construction with lazy tab initialization (`_loadedTabs` set with `IndexedStack`).
  - Secondary tabs (Planner, Levels, History, Settings) are deferred and instantiated only upon first navigation, eliminating initial launch latency and premature database queries.
  - Loaded tabs retain their widget trees, state, and scroll positions across tab switches without reloading or rebuilding.

## [1.0.4] - 2026-10-24

### Added
- **Dedicated Upgrade Planner (`PlannerScreen`)**:
  - Added full Upgrade Planner accessible directly from the bottom navigation bar (`NavigationBar` index 1).
  - Users can record planned future upgrades (village, category, name with autocomplete, target level, priority, notes) without starting timers or alerts.
  - Interactive drag-and-drop reordering with persistent order updates.
  - Priority management (High, Medium, Low) and "Mark as Next" highlighting.
  - One-tap "Start Upgrade" button that prefills the active upgrade sheet and marks the planned item as started to prevent duplicate timers.
- **Village Progress / Current Levels Tracker (`LevelsScreen`)**:
  - Added dedicated Levels Tracker accessible from the bottom navigation bar (`NavigationBar` index 2).
  - Strictly scoped to individual village accounts, storing current levels of buildings, troops, and heroes independently without cross-village collisions.
  - Searchable list with category filtering, quick inline `+` / `-` level increment/decrement controls, and edit/delete actions.
  - Idempotent integration with active upgrade completion: completing an upgrade automatically updates or creates the current level record without duplicate increments on repeat visits.
- **Builder Hall Level Support (`builderHallLevel`)**:
  - Added `builderHallLevel` column to `Villages` table and `Village` domain model.
  - Selection dropdown (`BH 1` to `BH 10` backed by `BuilderHallConstants`) in `AddVillageSheet`.
  - Contextual display in the AppBar and village selection badges (`TH18 · BH10`).
  - Catalogue autocomplete suggestions prioritize items unlockable at or below the village's Builder Hall level.
- **Drift Database Schema v4 Migration**:
  - Upgraded schema version to 4 with non-destructive migration adding `builder_hall_level` column to `villages`, `planner_items` table, and `village_item_levels` table with uniqueness constraint on `(village_id, category, item_name)`.

### Changed & Improved
- **Cleaner Upgrade Cards**:
  - Suppressed redundant village and category labels (`Home Village — Builder`, `Laboratory`, etc.) from dashboard cards since context is already clear from the top Realm and Category tabs.
  - Preserved slot keys (`Builder 1`), target level badges, countdown timers, and visible action menus.
- **Five-Destination Navigation Bar**:
  - Updated main navigation bar to seamlessly host Dashboard, Planner, Levels, History, and Settings.

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
  - Standardized compact display across cards, details, and activity logs as `Archer Tower · Lv. 68`.
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

