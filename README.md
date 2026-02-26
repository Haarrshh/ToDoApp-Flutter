# To-Do Flutter App

A production-oriented Flutter To-Do application with Provider state management, app flavors, offline support, and security checks.

## Setup

### Prerequisites

- Flutter SDK (see [flutter.dev](https://flutter.dev))
- Dart 3.10+

### Install and run

```bash
flutter pub get
flutter run
```

For a specific flavor (see below):

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev
```

## Flavor configuration

The app supports four environments: **dev**, **staging**, **qa**, **prod**.

### Android

Product flavors are defined in `android/app/build.gradle.kts`. Run with:

```bash
flutter run --flavor dev --dart-define=FLAVOR=dev
flutter run --flavor staging --dart-define=FLAVOR=staging
flutter run --flavor qa --dart-define=FLAVOR=qa
flutter run --flavor prod --dart-define=FLAVOR=prod
```

Build release APK/App Bundle:

```bash
flutter build apk --flavor prod --dart-define=FLAVOR=prod
flutter build appbundle --flavor prod --dart-define=FLAVOR=prod
```

### iOS

Pass the flavor via Dart define when running or building. In Xcode you can add to the Run scheme: **Arguments** → **Dart-Define**: `FLAVOR=dev` (or staging/qa/prod).

```bash
flutter run --dart-define=FLAVOR=dev
flutter build ios --dart-define=FLAVOR=prod
```

Default flavor when `FLAVOR` is not set: **dev**.

## Architecture

- **State management**: Provider. A single `TodoProvider` holds the list, loading/error state, and performs CRUD and sync.
- **Data layer**: 
  - **TodoRepository**: Talks to local SQLite (sqflite) and to the JSONPlaceholder API. When online, it fetches/syncs; when offline, it reads/writes only locally. Pending changes are synced when back online.
- **Core**:
  - **Config**: `EnvConfig` reads `FLAVOR` and exposes API base URL and app title per environment.
  - **Network**: `ApiClient` for HTTP (GET/POST/PUT/DELETE); endpoints in `ApiEndpoints`.
  - **Database**: `AppDatabase` (sqflite) with a single `todos` table; repository uses it for offline and cache.
  - **Security**: `DeviceSecurity` uses `flutter_jailbreak_detection`; if the device is rooted/jailbroken, the app shows `SecurityBlockScreen` and does not load the main app.
  - **Error handling**: `AppException` hierarchy; `setupGlobalErrorHandling` for Flutter errors; `CrashNotifier` for zone errors. Unhandled errors show a crash screen with a refresh button that returns to the main app.
- **Connectivity**: `ConnectivityHelper` (connectivity_plus) drives online/offline behavior and triggers sync when coming online.
- **UI**: Feature-first structure under `lib/features/` (todo, crash, security); shared widgets and theme under `global_components/` and `core/theme/`. Layout uses `Responsive` for padding on different screen sizes.

## Project structure

```
lib/
  main.dart                 # Entry, zone guard, security check, Provider root
  app.dart                  # MaterialApp, theme, home
  core/
    config/                 # EnvConfig, flavors
    constants/
    database/               # sqflite
    network/                # ApiClient, endpoints
    security/               # DeviceSecurity
    error/                  # Exceptions, global handler, CrashNotifier
    theme/                  # AppTheme, AppColors
    utils/                  # ConnectivityHelper, Responsive
  features/
    todo/
      data/                 # TodoModel, TodoRepository
      domain/               # TodoProvider
      presentation/         # screens, widgets (TodoTile)
    crash/                  # CrashScreen
    security/               # SecurityBlockScreen
  global_components/
    widgets/                # AppButton, AppTextField, LoadingIndicator, EmptyState, ErrorView
```

## API

The app uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) for todos: `GET/POST/PUT/DELETE /todos`. Data is cached and synced locally via sqflite.

## Security

- Root (Android) and jailbreak (iOS) detection: if the device is compromised, only `SecurityBlockScreen` is shown; the main app is not started.

## Crash handling

- `runZonedGuarded` captures async errors and reports them to `CrashNotifier`.
- When a crash is reported, the UI switches to `CrashScreen` with a **Refresh** button that clears the crash state and shows the app again.

Ensure the project builds and runs:

```bash
flutter pub get
flutter analyze
flutter run --dart-define=FLAVOR=dev
```
