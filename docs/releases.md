# Clash Command — Release & Versioning Workflow Guide

This document defines the release lifecycle, versioning strategy, Android signing setup, and verification workflow for **Clash Command** (`com.clashcommand.clash_command`).

---

## 1. Application Identity

- **Display Name**: `Clash Command` (configured in `android/app/src/main/AndroidManifest.xml`)
- **Package ID / Application ID**: `com.clashcommand.clash_command` (configured in `android/app/build.gradle.kts`)
- **Architecture**: Android-first, offline-first Flutter application backed by local SQLite via Drift.
- **Brand Assets**: Master logo at `assets/branding/logo.png`, adaptive Android launcher icons at `android/app/src/main/res/mipmap-*/`, and in-app branding in Settings.

---

## 2. Versioning Strategy

Clash Command follows [Semantic Versioning 2.0.0](https://semver.org/) combined with Flutter's build number scheme:

```
MAJOR.MINOR.PATCH+BUILD
```

Example: `1.0.1+2`
- **`MAJOR` (`1`)**: Incremented when incompatible changes are introduced (e.g., breaking database schema migrations that cannot be auto-migrated).
- **`MINOR` (`0` -> `1`)**: Incremented when new user-facing functionality or screens are added backwards-compatibly (e.g., dedicated Settings screen, Activity History log, full village editing).
- **`PATCH` (`1`)**: Incremented for backwards-compatible bug fixes, UI polish, branding refinements, or performance optimizations.
- **`BUILD` (`2`)**: A strictly monotonically increasing integer (`versionCode` on Android). Every single distributed APK or App Bundle build must have a strictly higher build number than the previous build.

### Where Versioning is Managed

1. **`pubspec.yaml`**: Primary source of truth.
   ```yaml
   version: 1.0.1+2
   ```
2. **`android/app/build.gradle.kts`**: Automatically reads `versionCode` and `versionName` from Flutter tooling based on `pubspec.yaml`.
3. **`lib/features/settings/presentation/settings_screen.dart`**: In-app About section exposes the current version string (`Version 1.0.1 (Build 2)`) alongside the app logo.

---

## 3. Build Types: Debug vs. Release

| Property | Debug APK (`make build-apk-debug`) | Release APK (`make build-apk-release`) |
| :--- | :--- | :--- |
| **Command** | `flutter build apk --debug` | `flutter build apk --release` |
| **Output Path** | `build/app/outputs/flutter-apk/app-debug.apk` | `build/app/outputs/flutter-apk/app-release.apk` |
| **Compilation** | JIT (Just-in-Time) with debugging symbols | AOT (Ahead-of-Time) compiled, stripped, tree-shaken |
| **Performance** | Slower; development-oriented | Maximum runtime speed and minimal APK size |
| **Signing** | Default Android debug keystore | Custom release keystore (or fallback debug if unconfigured) |
| **Intended Use** | Internal debugging, live hot reload, automated UI tests | Sideload distribution, internal test tracks, store release |

---

## 4. Android Release Signing Setup

`android/app/build.gradle.kts` is configured to look for `android/key.properties`. If the file is not present, it gracefully falls back to debug signing so that developer release builds succeed without extra setup.

For production releases, configure a production keystore:

### Step 4.1: Generate a Keystore (One-Time Setup)

Run the following command to generate an upload/release keystore:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias clashcommand
```

Keep the password and keystore file safe.

### Step 4.2: Create `android/key.properties`

Create a file named `android/key.properties` (or at the project root `key.properties`):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=clashcommand
storeFile=../upload-keystore.jks
```

> [!CAUTION]
> **Never commit keystore files or `key.properties` to version control.** Both `*.jks`, `*.keystore`, and `*key.properties` are explicitly ignored in `.gitignore`.

---

## 5. Branding Asset Generation

App icons and branding images are generated reproducibly via Python using Pillow:

```bash
# Via Makefile
make branding

# Or directly
python3 scripts/generate_branding_assets.py
```

Generated assets:
- `assets/branding/logo.png` (512x512 Master App Emblem with dark battle background)
- `assets/branding/logo_transparent.png` (512x512 Transparent shield emblem)
- `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` (Legacy icons)
- `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher_foreground.png` (Adaptive foreground)
- `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` (Adaptive icon definition)
- `android/app/src/main/res/values/colors.xml` (`ic_launcher_background` hex color)
- `web/icons/` and `web/favicon.png` (Web platform icons)

---

## 6. Pre-Release Quality Checklist

Before tagging or distributing a release, run through this verification checklist:

1. **Static Analysis**:
   ```bash
   make analyze
   # flutter analyze
   ```
   Must complete with **0 issues**.

2. **Automated Tests**:
   ```bash
   make test
   # flutter test
   ```
   Must pass all tests without failures.

3. **Changelog Update**:
   Update `CHANGELOG.md` with the new version section and release notes.

4. **Version Bump**:
   Update `version: X.Y.Z+B` in `pubspec.yaml` and update the About text in `settings_screen.dart` if applicable.

5. **Clean Release Build**:
   ```bash
   make clean
   make build-apk-release
   ```
   Verify that `build/app/outputs/flutter-apk/app-release.apk` is generated and note its file size.

6. **Device Smoke Test**:
   Install the APK on an Android device or emulator:
   ```bash
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
   Verify:
   - App launches cleanly with the new shield launcher icon.
   - Villages can be created, edited, and switched.
   - Upgrades can be started, countdown timers tick down, and progress updates.
   - History logs record all events accurately.
   - Settings screen displays the app logo and matching version string.
   - Test notification is received properly.

---

## 7. Release Notes Template

When creating a release (e.g. GitHub Release, internal distribution email, or test track notes), use the following standardized template:

```markdown
# Clash Command v[X.Y.Z] — [Release Name]

> **[Release Tagline — e.g., "Distinctive Shield Branding & Complete Upgrade Management"]**

[A concise 2-3 sentence description summarizing the goal and impact of this release.]

---

### What's New

- **[Feature or Area 1]**: [Short bullet description]
- **[Feature or Area 2]**: [Short bullet description]
- **[Feature or Area 3]**: [Short bullet description]

### Improvements & Fixes

- [Bug fix or performance optimization 1]
- [Bug fix or performance optimization 2]

### Known Issues & Limitations

- [Known non-blocking limitation, or "None identified for this release."]

---

### Build Details

- **Version**: `[X.Y.Z]`
- **Build Number**: `[B]`
- **Package ID**: `com.clashcommand.clash_command`
- **Build Type**: `Release APK (AOT)`
- **File Name**: `app-release.apk`
- **File Size**: `[XX.X MB]`
- **SHA-256 Checksum**: `[computed sha256 checksum]`
```

