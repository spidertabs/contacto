# Contacto — Setup & Release Notes

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected physical Android device
flutter run

# 3. Run unit tests
flutter test

# 4. Lint check
flutter analyze

# 5. Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

> **Physical device required** — fingerprint prompts from `local_auth` do not work on emulators.
> The device must have at least one fingerprint enrolled in Android Settings → Security.

---

## Android Configuration (already set up)

| File | Configuration |
|------|--------------|
| `android/app/build.gradle` | `minSdkVersion 23` (Android 6.0+) |
| `android/app/src/main/AndroidManifest.xml` | `USE_BIOMETRIC` + `USE_FINGERPRINT` permissions |
| `android/.../MainActivity.kt` | Extends `FlutterFragmentActivity` (required by `local_auth`) |

---

## Project Structure

```
lib/
├── main.dart
├── app/
│   └── app.dart                        # MaterialApp + ContactoTheme
├── shared/
│   ├── theme/
│   │   └── app_theme.dart              # Central ThemeData + color constants
│   └── widgets/
│       ├── contact_avatar.dart         # Initials avatar with deterministic color
│       ├── empty_state.dart            # Reusable empty state widget
│       └── fingerprint_button.dart     # Animated pulse fingerprint button
├── data/
│   ├── models/
│   │   └── contact.dart
│   └── database/
│       └── database_helper.dart        # SQLite singleton — full CRUD
└── features/
    ├── auth/
    │   ├── auth_service.dart
    │   └── screens/
    │       ├── register_screen.dart
    │       └── login_screen.dart
    └── contacts/
        └── screens/
            ├── contact_list_screen.dart
            ├── add_contact_screen.dart
            └── edit_contact_screen.dart
```

---

## All Stages Complete

| Stage | Description | Status |
|-------|-------------|--------|
| 1 | Project setup & dependencies | Done |
| 2 | Folder structure | Done |
| 3 | SQLite database layer | Done |
| 4 | Fingerprint auth service | Done |
| 5 | Register & login screens | Done |
| 6 | Contact list with search | Done |
| 7 | Add contact form | Done |
| 8 | Edit & delete contact | Done |
| 9 | UI polish & theme | Done |
| 10 | Unit tests | Done |
| 11 | Release build | Run flutter build apk --release |

---

## Dependencies

```yaml
sqflite: ^2.3.0        # SQLite
path: ^1.9.0           # DB path resolution
local_auth: ^2.1.8     # Fingerprint / biometric auth
path_provider: ^2.1.2  # App directory access
```
