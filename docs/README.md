# Clash Command Documentation

Clash Command is a planned Android-first Flutter app for tracking Clash of Clans upgrade timers offline. This repository currently contains the planning and architecture foundation for the product, not a completed app implementation.

## Project status

- Status: Planning and technical design stage
- Platform: Android-first, offline-first
- Core focus: village management, upgrade tracking, local notifications, and reliable timer calculations
- Current state: No Flutter app source, database schema, or production code has been generated yet

## Documentation map

- [prod.md](prod.md) — product vision, user stories, MVP scope, and acceptance criteria
- [architecture.md](architecture.md) — technical architecture, layer boundaries, data model, and timer rules
- [essential-architecture.md](essential-architecture.md) — concise implementation rules and quality gates for agents
- [agent.md](agent.md) — instructions for AI or human contributors implementing the app

## Supporting agent knowledge

The repository also includes reusable agent guidance under [.agent](../.agent):

- product specification guidance
- Flutter architecture guidance
- offline data patterns
- Android notification rules
- UI design guidelines
- testing expectations

These materials are intended to inform implementation, not to replace a live app codebase.

## Product direction

Clash Command is designed to help a single user manage multiple villages and track active upgrades without depending on a backend, account sync, or live game integration. The app is meant to be local-first, recoverable after restarts, and resilient when device notifications or permissions are limited.

## Recommended next implementation steps

1. Confirm the approved MVP scope and user stories.
2. Bootstrap the Flutter project and verify current stable package versions.
3. Implement the domain layer first: village models, upgrade lifecycle, and timer logic.
4. Add the local SQLite schema and repository layer.
5. Build the village dashboard and upgrade-entry flows.
6. Add local notification scheduling and reconciliation.
7. Validate behavior with unit, widget, and integration tests.

## Notes

This repo is intentionally organized as a planning workspace. The implementation should follow the rules in the architecture and essential architecture documents and should remain scoped to an offline local utility app rather than a game client or cloud service.
