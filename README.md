# Clash Command

<!--
SEO description: Clash Command is a Flutter Android app for tracking Clash of Clans upgrade timers offline, managing villages, and monitoring builder availability.
Keywords: Clash Command, Clash of Clans timer tracker, Flutter Android app, offline upgrade assistant, village timer manager, local SQLite app, APK build guide
-->

Clash Command is an Android-first Flutter app for tracking Clash of Clans upgrade timers offline. It helps users quickly see what is upgrading, when it will finish, and which builder or slot will become available next. The app is intentionally local-first, manual, and privacy-friendly rather than depending on cloud sync or a backend.

## Current status

This project is now in an active implementation phase. The repository includes:

- a Flutter Android project scaffold
- basic domain logic for upgrade timing
- a working timer service and tests
- a sample village dashboard using Riverpod
- planning and architecture docs for the full MVP

The app is not a full production release yet, but the foundation is now in place and can be expanded into the complete MVP described in the planning docs.

## Problem it solves

Clash Command helps answer these questions fast:

- What is currently upgrading in each village?
- When does each upgrade finish?
- Which builder or slot becomes available next?
- What is the next completion window across villages?

## Product goals

- Android-first Flutter experience
- Offline-first local data workflow
- No backend or cloud sync required
- Local SQLite persistence for villages and upgrades
- Reliable absolute timestamp tracking
- Manual upgrade entry and optional local reminder support
- Clear recovery after app restart or device reboot

## Tech stack

- Flutter + Dart
- Riverpod for app state management
- SQLite via Drift planned for persistent data
- Local notifications planned for reminder alerts
- Material 3 dark themed UI
- Flutter testing and analysis tools

## Repository structure

- [lib/](lib/) — Flutter application source
- [test/](test/) — project tests
- [android/](android/) — Android platform configuration
- [docs/](docs/) — product, architecture, and agent planning documents
- [README.md](README.md) — project overview and setup guide

## Prerequisites

Before running the app, install the required tools:

- Flutter SDK
- Android SDK
- Java 17+
- Android emulator or a physical Android device
- A working Linux/macOS/Windows environment with Flutter configured

For Linux, the setup usually looks like this:

```bash
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$HOME/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
flutter doctor
```

If Flutter reports missing Android SDK components, install them with:

```bash
sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"
```

## Run locally

Clone the repository:

```bash
git clone https://github.com/<your-username>/clash-command.git
cd clash-command
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

If you want to run on a connected device or emulator:

```bash
flutter devices
flutter run -d <device-id>
```

### Run on a custom web port

Use a fixed port for local browser testing:

```bash
flutter run -d chrome --web-port 8081
```

Or run the web-server target on a custom port:

```bash
flutter run -d web-server --web-port 8081 --web-hostname 127.0.0.1
```

### Run and access from your machine IP

To expose the app to other devices on the same network, bind to all interfaces and use your machine IP:

```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

Then open:

```bash
http://<your-machine-ip>:8080
```

Example:

```bash
hostname -I
# example output: 192.168.1.25
# open http://192.168.1.25:8080
```

You can also use the project Makefile:

```bash
make run-chrome-port PORT=8081
make run-web-local PORT=8081
make run-web-network PORT=8080 HOST=0.0.0.0
make run-web-ip PORT=8080 HOST=0.0.0.0
```

## Build Android APK

### Debug APK

```bash
flutter build apk --debug
```

This produces a debug APK in:

```bash
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```bash
flutter build apk --release
```

This creates a release APK in:

```bash
build/app/outputs/flutter-apk/app-release.apk
```

### Signed release APK for distribution

For a production-ready APK, create a keystore and configure signing:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties` with values like:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/home/you/upload-keystore.jks
```

Then build the signed APK:

```bash
flutter build apk --release
```

If you want an Android App Bundle for Play Store submission instead of a plain APK:

```bash
flutter build appbundle --release
```

The output goes to:

```bash
build/app/outputs/bundle/release/app-release.aab
```

## Useful commands

```bash
flutter clean
flutter pub get
flutter test
flutter analyze
flutter run
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

## Quality and validation

The project is expected to follow these rules:

- keep all core timers and logic testable
- store absolute timestamps and compute remaining time from the current clock
- keep business rules separate from UI code
- avoid direct SQL work in widgets
- prefer local first and offline-safe behaviors

## Development notes

This app is being built as a local utility for personal upgrade tracking. It deliberately avoids:

- user accounts
- cloud sync
- backend services
- live game automation
- Supercell login or game-state scraping
- ad or tracking systems

## SEO and AI crawler friendly summary

Clash Command is a Flutter Android app for managing Clash of Clans upgrade timers offline. It tracks village upgrades, monitors builder availability, and helps users understand completion times without cloud sync or live game integration. The project is built with Flutter, Dart, Riverpod, and Android tooling, and it supports local development, testing, and APK generation for Android distribution.

## Documentation

Planning and architecture guidance for the full product are in:

- [docs/prod.md](docs/prod.md)
- [docs/architecture.md](docs/architecture.md)
- [docs/essential-architecture.md](docs/essential-architecture.md)
- [docs/development-guide.md](docs/development-guide.md)
- [docs/agent.md](docs/agent.md)
- [docs/README.md](docs/README.md)

## Notes

This README is intended to be both human-readable and machine-readable for search and AI indexing. It reflects the current state of the project and includes the command set needed to run, test, and package the app into Android APK output.
