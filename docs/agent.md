# Agent Instructions --- Clash Command

You are implementing **Clash Command**, a new personal, offline-first
Android app for tracking Clash of Clans upgrade timers. Follow these
instructions for all work in this repository.

## Before changing code

1.  Read `prod.md`, `architecture.md`, and `essential-architecture.md`.
2.  Read the relevant skill in `.agent/`.
3.  Inspect the existing repository before assuming a file, package,
    version, or architecture exists.
4.  If the repository is empty, propose a small implementation plan
    before creating the project structure.
5.  Prefer current stable Flutter/Dart releases and check package
    compatibility at implementation time.
6.  Do not start feature implementation until the user approves the
    planning documents or explicitly asks to proceed.

## Product boundaries

-   Android-first Flutter app; all core data and features work offline.
-   No website, PWA, backend, authentication, cloud sync, Docker, Redis,
    Celery, or server-side jobs.
-   Do not clone Clocktower or copy its code. Implement from scratch.
-   Do not request/store Supercell credentials, inspect game files,
    modify game APKs, or automate gameplay.
-   No ads, analytics SDKs, trackers, or unneeded network permissions.
-   Upgrade entry must support both a bundled local catalog and
    user-defined custom timers.
-   Catalog data must be sourced and reviewed; do not invent exact
    in-game upgrade durations.

## Implementation workflow

1.  Implement domain models and pure timer/lifecycle services first.
2.  Add Drift schema, repositories/DAOs, migrations, and database tests.
3.  Implement village management and custom timers.
4.  Build the village-focused dashboard and navigation.
5.  Add catalog selection with explicit duration confirmation when data
    is uncertain.
6.  Add local notifications behind a service interface.
7.  Add reconciliation on app launch and Android reboot, where
    supported.
8.  Add history, backup, and polish only after the core workflows are
    stable.
9.  Work in small steps. After each step, run formatting, analysis, and
    relevant tests.
10. Summarize files changed, commands/tests run, and remaining risks at
    the end of a task.

## Coding rules

-   Keep UI, domain logic, persistence, and platform services separated.
-   Do not run database queries from widgets.
-   Do not put timer arithmetic in presentation widgets.
-   Use `DateTime` consistently; store absolute timestamps in UTC and
    format them in local time for display.
-   Use stable notification identifiers. Never rely on Dart's default
    `hashCode` for persisted notification identity.
-   Make database migrations explicit and test them.
-   Prefer small feature-oriented modules over giant files or
    speculative abstractions.
-   Use meaningful names, null safety, and typed models.
-   Avoid global mutable state.
-   Use Riverpod for state and dependency wiring, not as a reason to
    create excessive providers.
-   Handle asynchronous errors and show useful user-facing feedback.
-   Preserve data when migrations or backup restores fail.

## UI requirements

-   Dark, polished gaming utility; not a generic template and not a
    direct recreation of Clash of Clans.
-   Restrained charcoal/graphite surfaces with a small, consistent
    accent palette.
-   Strong information hierarchy and readable timer text.
-   Village-focused default dashboard with a clear village switcher.
-   Support empty states, errors, confirmation for destructive actions,
    and accessible tap targets.
-   Do not use Bootstrap or introduce a web frontend.

## Notification requirements

-   Ask for permission contextually, not on the first launch without
    explanation.
-   Timer tracking must work if permission is denied.
-   Editing/cancelling/completing/deleting an upgrade must update/cancel
    notifications.
-   Reconcile intended reminders with active upgrades on launch and
    after reboot where supported.
-   Verify current Android exact-alarm and notification permission
    requirements before configuration.
-   Do not claim exact-time delivery is guaranteed.

## Completion checklist

-   [ ] Acceptance criteria from `prod.md` are met.
-   [ ] `dart format` completed.
-   [ ] `flutter analyze` clean of new errors.
-   [ ] Relevant tests pass.
-   [ ] Failure and empty states are covered.
-   [ ] No unintended network or data collection added.
-   [ ] No out-of-scope feature or dependency introduced.
