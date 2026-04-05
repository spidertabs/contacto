# Contacto — 2-Day Build Plan

> **Goal:** Deliver a fully functional Android app with fingerprint authentication and contact management within 2 days.
> **Stack:** Flutter · Dart · SQLite (`sqflite`) · `local_auth` · Android Studio
> **Target:** Android 6.0 (API 23)+

---

## At a Glance

| Day | Focus | Deliverable |
|-----|-------|-------------|
| Day 1 | Foundation, Auth & Database | Working fingerprint login + local DB |
| Day 2 | Contact Features, UI Polish & Testing | Complete, testable app |

---

## Day 1 — Foundation, Authentication & Database

### Stage 1 · Project Setup ⏱ ~45 min

**Goal:** Get a clean, runnable Flutter project configured for the build ahead.

- [ ] Create new Flutter project: `flutter create contacto`
- [ ] Configure `pubspec.yaml` — add dependencies:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    sqflite: ^2.3.0
    path: ^1.9.0
    local_auth: ^2.1.8
    path_provider: ^2.1.2
  ```
- [ ] Run `flutter pub get`
- [ ] Set minimum SDK in `android/app/build.gradle`:
  ```gradle
  minSdkVersion 23   // Android 6.0
  ```
- [ ] Add required permissions to `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
  <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
  ```
- [ ] Update `MainActivity.kt` to use `FlutterFragmentActivity` (required by `local_auth`)
- [ ] Verify the app builds and runs on a physical device

**Checkpoint ✅** App launches on device with no errors.

---

### Stage 2 · Project Structure ⏱ ~30 min

**Goal:** Set up a clean folder structure before writing any feature code.

- [ ] Create the following directory layout under `lib/`:

```
lib/
├── main.dart
├── app/
│   └── app.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── register_screen.dart
│   │   │   └── login_screen.dart
│   │   └── auth_service.dart
│   └── contacts/
│       ├── screens/
│       │   ├── contact_list_screen.dart
│       │   ├── add_contact_screen.dart
│       │   └── edit_contact_screen.dart
│       └── contact_service.dart
├── data/
│   ├── database/
│   │   └── database_helper.dart
│   └── models/
│       └── contact.dart
└── shared/
    └── widgets/
        └── fingerprint_button.dart
```

- [ ] Create stub files for each screen (empty `Scaffold` with a title)
- [ ] Set up `main.dart` with `MaterialApp` pointing to `RegisterScreen` as the initial route

**Checkpoint ✅** All files exist; app navigates to a blank register screen.

---

### Stage 3 · Database Layer ⏱ ~1 hr

**Goal:** Build the local SQLite database that stores user and contact data.

- [ ] Implement `DatabaseHelper` singleton in `data/database/database_helper.dart`:
  - `initDB()` — creates the database file
  - `contacts` table schema:
    ```sql
    CREATE TABLE contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      notes TEXT,
      created_at TEXT
    )
    ```
  - `user` table schema (to flag if registration is done):
    ```sql
    CREATE TABLE user (
      id INTEGER PRIMARY KEY,
      registered INTEGER DEFAULT 0
    )
    ```
- [ ] Implement `Contact` model in `data/models/contact.dart`:
  - Fields: `id`, `name`, `phone`, `email`, `notes`, `createdAt`
  - `toMap()` and `fromMap()` methods
- [ ] Implement CRUD methods in `DatabaseHelper`:
  - `insertContact(Contact c)`
  - `getAllContacts()`
  - `updateContact(Contact c)`
  - `deleteContact(int id)`
  - `searchContacts(String query)`
  - `isRegistered()` / `setRegistered()`

**Checkpoint ✅** Unit-test CRUD methods in `main.dart` temporarily (print results to console).

---

### Stage 4 · Fingerprint Authentication Service ⏱ ~1 hr

**Goal:** Implement a reusable service that wraps `local_auth` for registration and login.

- [ ] Implement `AuthService` in `features/auth/auth_service.dart`:
  - `isDeviceBiometricSupported()` → checks hardware support
  - `isFingerprintEnrolled()` → checks enrolled biometrics
  - `authenticate({required String reason})` → triggers the system biometric prompt, returns `bool`
  - `isAppRegistered()` → reads from the `user` table via `DatabaseHelper`
  - `completeRegistration()` → writes registered flag to `user` table
- [ ] Handle edge cases:
  - Device has no fingerprint sensor → show error dialog
  - No fingerprint enrolled in device settings → prompt user to enroll
  - Authentication cancelled by user → return to screen gracefully

**Checkpoint ✅** Call `authenticate()` from a temp button; confirm prompt appears and result is logged.

---

### Stage 5 · Registration & Login Screens ⏱ ~1.5 hr

**Goal:** Build the two auth screens users interact with.

**`RegisterScreen`**
- [ ] Check if already registered on `initState` → redirect to `LoginScreen` if true
- [ ] Check biometric availability on load → show unsupported message if needed
- [ ] Display app logo / name, brief explanation text
- [ ] "Register with Fingerprint" button → calls `AuthService.authenticate()` then `completeRegistration()`
- [ ] On success → navigate to `ContactListScreen`

**`LoginScreen`**
- [ ] Auto-trigger fingerprint prompt on screen load (`initState`)
- [ ] Show a manual "Try Again" button if the prompt is dismissed
- [ ] On success → navigate to `ContactListScreen`
- [ ] On failure (3 attempts) → show lockout message

**Checkpoint ✅** Full auth flow works end-to-end on a physical device: register → login → land on contact list stub.

---

**🌙 End of Day 1 Target**

| ✅ Done |
|--------|
| Project builds and runs |
| SQLite DB with CRUD operations |
| Fingerprint auth service working |
| Register and Login screens functional |
| End-to-end auth flow complete |

---

## Day 2 — Contact Features, UI Polish & Testing

### Stage 6 · Contact List Screen ⏱ ~1.5 hr

**Goal:** The main screen users see after login — a searchable list of their contacts.

- [ ] Implement `ContactListScreen`:
  - Load all contacts from DB on screen init using `DatabaseHelper.getAllContacts()`
  - Display contacts in a `ListView.builder` with name, phone, and an avatar (initials-based)
  - Show an empty state illustration/message when no contacts exist
- [ ] Implement search bar:
  - `TextField` at the top filters the list in real-time
  - Calls `DatabaseHelper.searchContacts(query)` on text change
- [ ] Add a `FloatingActionButton` → navigates to `AddContactScreen`
- [ ] Each list tile:
  - Tap → navigates to `EditContactScreen` (pre-filled)
  - Long press OR swipe → shows delete confirmation dialog
- [ ] `AppBar` with app title and logout icon (returns to `LoginScreen`)

**Checkpoint ✅** Contacts load from DB, search filters results, empty state shows correctly.

---

### Stage 7 · Add Contact Screen ⏱ ~1 hr

**Goal:** A form to create a new contact.

- [ ] Implement `AddContactScreen` with a `Form` widget and `TextFormField`s for:
  - Name *(required)*
  - Phone number
  - Email address
  - Notes
- [ ] Form validation:
  - Name must not be empty
  - Phone must be numeric if provided
  - Email must match basic email format if provided
- [ ] "Save Contact" button:
  - Validates form
  - Calls `DatabaseHelper.insertContact()`
  - Pops back to `ContactListScreen` and refreshes the list
- [ ] "Cancel" button / back navigation discards changes

**Checkpoint ✅** Add a contact, navigate back, confirm it appears in the list.

---

### Stage 8 · Edit & Delete Contact ⏱ ~45 min

**Goal:** Let users update or remove existing contacts.

- [ ] Implement `EditContactScreen`:
  - Receives a `Contact` object as a route argument
  - Pre-fills all fields with existing data
  - "Update Contact" button → calls `DatabaseHelper.updateContact()`, pops back, refreshes list
- [ ] Implement delete flow (from `ContactListScreen`):
  - Confirmation `AlertDialog`: *"Delete [Name]? This cannot be undone."*
  - On confirm → `DatabaseHelper.deleteContact(id)` → remove from list state
  - Show `SnackBar` confirmation: *"Contact deleted"*

**Checkpoint ✅** Edit a contact's phone number, save, verify change persists after app restart.

---

### Stage 9 · UI Polish ⏱ ~1 hr

**Goal:** Make the app look cohesive and professional.

- [ ] Define a consistent `ThemeData` in `app.dart`:
  - Primary color, accent color, font family
  - `AppBar` styling
  - `InputDecoration` theme for uniform text fields
- [ ] `RegisterScreen` & `LoginScreen`:
  - Centered layout with logo placeholder, headline text, and styled button
  - Fingerprint icon with subtle animation (pulse or fade)
- [ ] `ContactListScreen`:
  - Gradient or colored `AppBar`
  - Contact avatars with initials and auto-generated background color
  - Smooth list animations (`AnimatedList` or `AnimatedOpacity`)
- [ ] `AddContactScreen` / `EditContactScreen`:
  - Card-style form layout
  - Floating save button
- [ ] Empty state on contact list:
  - Simple illustration or icon + "No contacts yet. Tap + to add one."
- [ ] Loading indicators (`CircularProgressIndicator`) for any async DB calls

**Checkpoint ✅** App looks consistent across all screens; no raw default Flutter blue theme.

---

### Stage 10 · Testing & Bug Fixing ⏱ ~1.5 hr

**Goal:** Verify all features work correctly under normal and edge-case conditions.

**Functional Testing**

| Test Case | Expected Result |
|-----------|----------------|
| Launch app (first time) | Registration screen appears |
| Register with fingerprint | Redirects to contact list |
| Launch app (returning user) | Login screen appears with auto-prompt |
| Successful fingerprint login | Access granted, contacts load |
| Failed fingerprint (wrong finger) | Error shown, retry option available |
| Add contact with all fields | Contact appears in list |
| Add contact — name field empty | Validation error shown |
| Search for existing contact | Contact found and displayed |
| Search for non-existent contact | Empty result state shown |
| Edit a contact and save | Changes reflected immediately |
| Delete a contact | Contact removed; SnackBar shown |
| Restart app after adding contacts | Contacts persist from SQLite |
| App backgrounded and resumed | Re-authenticates on return |

**Edge Case Testing**

- [ ] Device with no fingerprint sensor → graceful error, not a crash
- [ ] No fingerprints enrolled in device settings → prompt to enroll
- [ ] Very long contact name → truncated in list tile, full in edit screen
- [ ] Empty contacts database → empty state renders correctly
- [ ] Rapid taps on "Save" → no duplicate contacts inserted

**Bug Fixing**

- [ ] Run `flutter analyze` → resolve all warnings and errors
- [ ] Fix any layout overflow issues on smaller screen sizes
- [ ] Ensure `dispose()` is called on all controllers (`TextEditingController`, etc.)

**Checkpoint ✅** All test cases pass; `flutter analyze` reports zero issues.

---

### Stage 11 · Final Build & Delivery ⏱ ~30 min

**Goal:** Produce a working release build and wrap up the project.

- [ ] Increment version in `pubspec.yaml` (e.g., `version: 1.0.0+1`)
- [ ] Build release APK:
  ```bash
  flutter build apk --release
  ```
- [ ] Install and smoke-test the release APK on a physical device
- [ ] Confirm the APK path: `build/app/outputs/flutter-apk/app-release.apk`
- [ ] Take screenshots for the README (`screenshots/` folder)
- [ ] Update `README.md` with final screenshots
- [ ] Final `git commit`: `"chore: release v1.0.0"`

**Checkpoint ✅** Release APK installs cleanly and all features work without debug tools.

---

**🎉 End of Day 2 Target**

| ✅ Done |
|--------|
| Contact list with search |
| Add, edit, delete contacts |
| Data persists across app restarts |
| Polished, consistent UI |
| All test cases passing |
| Release APK built and verified |

---

## Full Timeline Summary

### Day 1

| Time | Stage | Duration |
|------|-------|----------|
| 09:00 | Stage 1 — Project Setup | 45 min |
| 09:45 | Stage 2 — Project Structure | 30 min |
| 10:15 | Stage 3 — Database Layer | 1 hr |
| 11:15 | Stage 4 — Auth Service | 1 hr |
| 12:15 | *Break* | 45 min |
| 13:00 | Stage 5 — Register & Login Screens | 1.5 hr |
| 14:30 | Buffer / catch-up time | 30 min |

### Day 2

| Time | Stage | Duration |
|------|-------|----------|
| 09:00 | Stage 6 — Contact List Screen | 1.5 hr |
| 10:30 | Stage 7 — Add Contact Screen | 1 hr |
| 11:30 | Stage 8 — Edit & Delete | 45 min |
| 12:15 | *Break* | 45 min |
| 13:00 | Stage 9 — UI Polish | 1 hr |
| 14:00 | Stage 10 — Testing & Bug Fixing | 1.5 hr |
| 15:30 | Stage 11 — Final Build & Delivery | 30 min |

---

## Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0          # SQLite database
  path: ^1.9.0             # DB file path resolution
  local_auth: ^2.1.8       # Fingerprint / biometric auth
  path_provider: ^2.1.2    # App directory access

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## Risk & Mitigation

| Risk | Mitigation |
|------|-----------|
| `local_auth` not working on emulator | Use a physical Android device throughout |
| Fingerprint prompt UI varies by device | Test on at least 2 different Android versions |
| SQLite data not persisting | Verify DB path using `path_provider`; check `onCreate` logic |
| Build fails on `minSdkVersion` | Ensure `build.gradle` and `AndroidManifest.xml` are both updated |
| Scope creep eating into Day 2 | Stages 9 (polish) is the only flexible stage — cut if needed |

---

*Built in 2 days. Shipped with confidence.*
