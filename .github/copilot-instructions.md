# Copilot / AI Agent Instructions for Shoppinglist

Purpose: give an AI coding agent the minimal, high-value knowledge to be productive in this Flutter app.

- Project root: Flutter app. Key entry: `lib/main.dart` (initializes Firebase and provides `Autenticazione` via `Provider`).
- Primary UI folder: `lib/pages/` (each page often maps to a single Dart file; examples: `homepage.dart`, `scrivi_lista.dart`).
- Account logic: `lib/account/controllers/autenticazione.dart` — uses `firebase_auth`, `google_sign_in`, and writes user records via `pages/services/database.dart`.
- Data layer: `lib/pages/services/database.dart` (Firestore operations). When changing Firestore structure, update this file and any callers (e.g., `homepage.dart`, `scrivi_lista.dart`).
- Shared/ui constants: `lib/standard/` (colors, drawer, and named constants). Look at `standard/costanti.dart` and `standard/MyDrawer.dart` for styling and navigation conventions.

Architecture & patterns (what to look for)
- Global state: small app-level provider in `main.dart` — `Provider(create: (context) => Autenticazione())`. Prefer reusing this provider for authentication state and avoid creating multiple `FirebaseAuth.instance` usage unless explicitly required for tests.
- Auth flow: `Autenticazione` handles Google sign-in and email/password registration; it calls `DatabaseService(uid: ...).updateUserData(...)` to create/update Firestore user documents. Keep this pattern when adding new auth flows.
- Navigation: Mostly uses `Navigator.push`/`pushReplacement` with `MaterialPageRoute` (see `main.dart` splash and `homepage.dart` dialogs that push `ScriviLista`). Follow existing route patterns rather than introducing a new routing library unless requested.
- Localized strings: many strings are in Italian (UX text and UI labels). When editing UI copy, preserve language consistency or add a clear i18n plan.
- List types: the list of page types is defined inline in `homepage.dart` (`selezionaTipoPagina` array). If you add types or colors, update both `homepage.dart` and `standard/costanti.dart` color mappings.

Build / test / run (validated by reading `pubspec.yaml`)
- To fetch packages: `flutter pub get`.
- Run on connected device/emulator: `flutter run -d <device-id>` or just `flutter run`.
- Build APK: `flutter build apk`.
- Run tests: `flutter test` (there is a `test/widget_test.dart`).
- Firebase: the app calls `Firebase.initializeApp()` in `main.dart`. Confirm platform-specific Firebase configuration files exist (iOS/macOS `GoogleService-Info.plist`, Android `google-services.json`) in repo or in dev environment. If missing, ask the maintainer before changing initialization.

Project-specific dependencies to be aware of (from `pubspec.yaml`)
- `firebase_core`, `firebase_auth`, `cloud_firestore` — Firestore + Auth are core to app behavior.
- `provider` — used for DI/global state (see `main.dart`).
- `google_sign_in` — used by `Autenticazione`.
- `share_plus`, `random_string`, `intl`, `rate_my_app` — features to inspect before modifying related UX flows.

Files to inspect first for most tasks
- `lib/main.dart` — startup, Provider wiring, splash screen.
- `lib/account/controllers/autenticazione.dart` — auth helper and Firestore user creation.
- `lib/pages/homepage.dart` — main app view, list creation flow, color/type mapping.
- `lib/pages/services/database.dart` — Firestore reads/writes (change here impacts data model).
- `lib/pages/services/scrivi_lista.dart` — write/edit list view (list item creation).
- `lib/standard/costanti.dart` — color and UI constants used across pages.

Conventions & gotchas
- Many filenames and UI text are in Italian — follow existing naming/localization when adding UI.
- Colors are centralized in `standard/costanti.dart`; change there for consistent theming.
- IDs for lists are generated using `random_string` (`randomAlphaNumeric(28)`) in `homepage.dart` — preserve this when changing ID mechanics or coordinate forwards/backwards compatibility with Firestore keys.
- Auth methods update user profile and then call `DatabaseService.updateUserData(...)`. Do not remove this step; otherwise the database user documents will be out of sync.
- Avoid introducing major architectural changes (new DI frameworks, routing solutions) without a short proposal — the app is small and expects simple, direct navigation.

When making edits
- Run `flutter pub get` then `flutter run` to verify quick changes on device/emulator.
- Run `flutter test` for automated checks; there is minimal test coverage — prefer manual UI checks for most UI work.
- If changing Firestore schema: update `lib/pages/services/database.dart`, then update any callers (`homepage.dart`, `scrivi_lista.dart`).

If unsure, open these files and quote lines in your PR for clarity: `lib/main.dart`, `lib/pages/homepage.dart`, `lib/account/controllers/autenticazione.dart`, `lib/pages/services/database.dart`.

Feedback
- If any sections are unclear or you expect other setup steps (CI, Firebase config), tell me and I will iterate the instructions.
