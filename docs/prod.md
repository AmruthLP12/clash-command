# Clash Command --- Product Specification

**Status:** Initial specification --- ready for technical review\
**Product:** Clash Command\
**Platform:** Android, offline-first\
**Document purpose:** Define what the first version should do before
implementation begins.

## 1. Product vision

Clash Command is a personal Android companion app for manually tracking
upgrades across multiple Clash of Clans villages. It helps the user
answer three questions quickly:

1.  What is upgrading in each village right now?
2.  When will each upgrade finish?
3.  Which builder or upgrade slot will become available next?

The app is a standalone utility, not a game client. It does not log in
to Supercell, read game files, automate gameplay, or require a Clash of
Clans APK.

## 2. Product principles

-   **Offline first:** Core functionality works without an internet
    connection.
-   **Local ownership:** User data is stored on the device in SQLite.
-   **Manual by design:** The user enters or selects an upgrade and
    supplies its duration or remaining time.
-   **Reliable timekeeping:** Store absolute timestamps; never depend on
    a continuously running countdown.
-   **Low complexity:** No account system, backend, website, cloud sync,
    Docker, or job queue in v1.
-   **Purposeful UI:** Dark, polished, game-inspired visual identity
    without copying the game UI or using unlicensed assets.
-   **Recoverable:** Timers can be edited, completed, cancelled, and
    reconstructed after the app is reopened or the device restarts.

## 3. Target user and primary use case

The initial target user is one person managing several villages on one
Android device. The primary workflow is:

1.  Open Clash Command.
2.  Select a village.
3.  Review its builder/upgrade slots and completion times.
4.  Start an upgrade using a catalog entry or custom timer.
5.  Receive an optional local notification before or at completion.
6.  Mark the upgrade complete and optionally start the next one.

## 4. Scope

### 4.1 MVP --- must have

#### Village management

-   Create, edit, archive, and delete a village.
-   Store a display name and optional Town Hall level.
-   Store builder capacity as a configurable integer.
-   Show the selected village clearly.
-   Provide a village switcher.
-   Prevent accidental deletion with confirmation.
-   Warn before deleting a village that has active upgrades.

#### Upgrade tracking

-   Start an upgrade from a built-in, locally stored catalog where a
    suitable entry exists.
-   Start a custom upgrade by entering a name, category, and duration or
    remaining time.
-   Associate an upgrade with a village and, where applicable, a
    builder/slot.
-   Store start time, expected completion time, status, and optional
    notes.
-   Display remaining time and local completion date/time.
-   Edit an active timer, including correcting the expected finish time.
-   Mark an upgrade complete early or after its expected completion.
-   Cancel an upgrade without marking it complete.
-   Prevent duplicate active upgrades on the same builder/slot.
-   Support multiple simultaneous upgrades up to the village's
    configured capacity.
-   Provide a useful empty state when no upgrades are active.

#### Notifications

-   Optional notification at completion.
-   Optional pre-alert offsets (initial defaults: 30 minutes before and
    5 minutes before; user can disable either).
-   Request notification permission contextually, when the user enables
    alerts or schedules the first notification.
-   Reschedule notifications after edits.
-   Cancel notifications when an upgrade is cancelled or deleted.
-   Reconcile notification schedules when the app launches and after
    device reboot.
-   Show a clear status when notifications are disabled or permission is
    denied.

#### Dashboard and navigation

-   Default to the **village-focused dashboard**.
-   Village switcher at the top.
-   Selected village summary: Town Hall level if provided, active
    upgrades, available slots, and next completion.
-   Upgrade/slot cards with name, category, progress indication,
    remaining time, and completion time.
-   A secondary "All villages" upcoming-completions view for a
    cross-village overview.
-   Navigation to village management, upgrade history, settings, and
    catalog/custom-entry flow.
-   Accessible tap targets and readable countdown text.

#### Local data and settings

-   Persist all app data in SQLite.
-   Store notification preferences locally.
-   Provide an export/backup in a later MVP increment if it can be
    implemented safely without delaying core tracking; see v1.1.
-   No user account or network requirement.

### 4.2 V1.1 --- after the MVP is stable

-   JSON backup and restore, with validation and schema version
    metadata.
-   Upgrade history with filters by village, category, and date.
-   More complete building/hero/research catalog.
-   Optional home-screen widget if maintenance cost is reasonable.
-   More detailed progress summaries.
-   User-selectable reminder presets and quiet hours.

### 4.3 Explicitly out of scope for v1

-   Website or PWA.
-   Backend, API server, user registration, cloud synchronization, or
    multi-device synchronization.
-   Supercell account login or credential storage.
-   Automatic reading of the live village or game state.
-   Importing or modifying Clash of Clans APKs, game files, or private
    game data.
-   Gameplay automation, botting, or actions performed in the game.
-   Ads, analytics SDKs, tracking, or monetization.
-   Social features, clan management, or public profiles.
-   Mandatory internet connection.
-   Docker, Redis, Celery, or server-side background jobs.

## 5. Upgrade entry model

The app supports two entry modes.

### Catalog entry

-   Choose a category and a catalog item.
-   Use a known default duration only when that duration is verified and
    appropriate for the selected upgrade level.
-   If the catalog cannot determine the correct duration, ask the user
    to enter or confirm it.
-   Do not imply that the catalog is automatically synchronized with
    current game balance.

### Custom entry

-   Required: upgrade name, village, duration or remaining time.
-   Optional: category, builder/slot, notes, start timestamp.
-   Duration input should use a simple human-friendly control
    (hours/minutes/days) and validate values.
-   The user may enter remaining time instead of elapsed time.
-   If the user enters a completion date/time, show the calculated
    duration before saving.

## 6. Core user stories and acceptance criteria

### US-01: Create a village

**As a user**, I can add a village with a name, Town Hall level, and
builder capacity.

Acceptance: - A village can be created without internet. - Required
fields are validated. - The new village appears in the switcher
immediately. - The database retains it after app restart.

### US-02: Start a catalog upgrade

**As a user**, I can select an upgrade catalog item, confirm duration,
and start tracking it.

Acceptance: - The upgrade is associated with the selected village. -
Expected completion is calculated from the chosen start time and
duration. - Any existing active upgrade assigned to the same slot is
handled safely; no silent overwrite occurs.

### US-03: Start a custom timer

**As a user**, I can track an upgrade even if it is not in the catalog.

Acceptance: - A custom name and duration are sufficient. - Category and
slot can be omitted if not relevant. - The upgrade appears on the
dashboard after saving.

### US-04: Receive a reminder

**As a user**, I can receive an optional notification before or when an
upgrade completes.

Acceptance: - Permission denial is handled without a crash. -
Notification IDs are stable and associated with upgrade records. -
Editing the expected completion time updates the scheduled
notifications. - Cancelled/deleted upgrades do not leave stale scheduled
notifications. - The app does not claim exact delivery is guaranteed;
Android settings and manufacturer battery restrictions may affect
delivery.

### US-05: Recover after restart

**As a user**, I can reopen the app after hours or reboot the device and
see correct remaining times.

Acceptance: - Remaining time is derived from
`expected_completion_at - current_time`. - No countdown state is treated
as the source of truth. - Active upgrade data survives process death and
device restart.

### US-06: Switch villages

**As a user**, I can switch villages and see only the selected village's
active upgrades, with a separate way to view all villages.

Acceptance: - Switching villages does not alter timer data. -
All-villages view is sorted by expected completion time.

## 7. UX and visual direction

-   Dark, refined gaming utility; not an imitation of Clash of Clans.
-   Use charcoal/graphite surfaces, restrained warm gold or amber
    accents, clear status colors, and high-contrast typography.
-   Avoid excessive gradients, glows, noisy textures, or oversized
    decorative game imagery.
-   Prioritize information hierarchy: village → available slots → active
    upgrades → next completion.
-   Countdown should be prominent, with exact completion date/time
    available nearby.
-   Use icons consistently and provide labels for icon-only controls.
-   Support small Android screens, large text settings, and portrait
    orientation.
-   Provide loading, empty, error, permission-denied, and
    no-active-upgrade states.

## 8. Data and privacy

-   All user-entered data stays in the app's local SQLite database.
-   No network access is required for core functionality.
-   Do not request or store Supercell credentials.
-   Do not collect analytics or device identifiers.
-   Backup/export, when added, must be user-initiated and explain where
    the file is saved.
-   Deleting a village must clearly explain whether its upgrade history
    will also be deleted.

## 9. Success criteria for v1

The MVP is successful when: - The user can manage multiple villages. -
The user can create catalog-based and custom upgrade timers. - The
dashboard remains correct after app closure, reopening, and reboot. -
Notifications are scheduled, edited, and cancelled correctly under
supported Android conditions. - All core features work offline. - No
server or account setup is required. - The app has no known data-loss
path in ordinary create/edit/complete/cancel workflows.

## 10. Release approach

1.  Implement and test the database and timer domain first.
2.  Build village management and custom timers.
3.  Add catalog support with conservative, verified data.
4.  Add notifications and reboot reconciliation.
5.  Add history and backup after core behavior is stable.
6.  Test on a physical Android device, including permission denial,
    reboot, time-zone changes, and battery optimization.
