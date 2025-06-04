# MedMinder2 - README

## Project Overview
**MedMinder2** is a Flutter-based medication management app designed to help users track medications, manage doses, and receive timely reminders. It leverages **Riverpod** for state management, **Drift** for local database storage, **get_storage** for lightweight persistence, and **flutter_local_notifications ^19.2.1** for scheduling notifications. The app is currently running on an Android emulator, allowing users to add, edit, delete medications, and manage doses for each medication.

## Core Features
1. **Medication Tracking**:
    - Users can add, edit, and delete medications with details like name, concentration, unit (e.g., mg, mL), stock quantity, and form (e.g., tablet, capsule).
    - Data is stored locally in a **Drift** SQLite database (`medminder.sqlite`).
- **Dose Management**:
    - Users can add, edit, and delete doses for each medication, specifying amount, unit, and optional weight-based calculations.
    - Supports weight-based dosing calculations using dose per kg.
    - Doses are linked to medications via foreign keys.
3. **Scheduling and Notifications**:
    - Users can set schedules for doses (planned, not yet implemented).
    - Notifications will be triggered using **flutter_local_notifications** (planned).
4. **Unit Conversions and Calculations**:
    - Supports unit conversions (e.g., mL to tsp, mg to IU) via `MedCalculations` in `lib/core/calculations.dart` (not yet integrated in UI).
    - Calculates weight-based doses and reconstitution volumes (planned).
5. **User Interface**:
    - Clean UI with a **Home Screen** listing medications, a **Medication Screen** for adding/editing, a **Dose Screen** for dose management, and reusable widgets (e.g., `MedicationCard`, `DialogInput`).
    - Theming defined in `lib/core/theme.dart` with a teal primary color.

## Planned Functionality
- **Notification System**:
    - Implement `NotificationService` to schedule notifications based on `Schedules` table entries.
- **Calculations**:
    - Integrate `MedCalculations` into `DoseScreen` for weight-based dosing (e.g., `dosePerKg`).

## Current Status
- **Date**: June 4, 2025, 3:55 PM AEST
- **Platform**: Android (API 34, Pixel 6 emulator)
- **Environment**: Windows 11, Flutter 3.32.1 (stable), Dart 3.8.1
- **Project Directory**: `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2`
- **App Behavior**:
    - **Home Screen**: Displays a list of medications with `MedicationCard` widgets, showing "No medications added" when empty.
    - **Medication Screen**: Allows adding and editing medications with validated inputs.
    - **Dose Screen**: Supports adding and deleting doses for a medication, displaying them in a list (in progress).
    - **Debug Logging**: Logs database operations for medications and doses.
- **Resolved Issues**:
    - Android v1 embedding error: Fixed by creating `medminder2` with v2 embedding.
    - Desugaring error: Resolved by enabling `isCoreLibraryDesugaringEnabled` and `multiDexEnabled`.
    - Backup issues: Corrected PowerShell commands to `C:\Users\kook1\AndroidStudioProjects\Projects\medminder_backup`.
    - `Column` conflict: Fixed by importing Drift with `as drift` prefix.
    - ### Resolved Issues
- Fixed `CardTheme` type mismatch in `core/theme.dart` by using `CardThemeData`.
- Verified edit dose functionality populates form fields correctly.
- ### New Features
- Updated `MedicationCard` on `HomeScreen` to display total stock, e.g., "50 x 100mg Tablets remaining".
- ### New Features
- Added helper text to `DoseScreen` fields for clarity.
- Increased field spacing in `DoseScreen` to prevent label overlap.
- Implemented dynamic summary (e.g., "2 x 250mg daily on Mon, Wed") in `DoseScreen`.

## Project Structure
- **Flutter Code** (`lib/`):
    - `core/`: Utilities (`calculations.dart`, `constants.dart`, `theme.dart`, `utils.dart`)
    - `data/`: Database setup (`database.dart`, `database.g.dart`)
    - `screens/`: UI screens (`home_screen.dart`, `medication_screen.dart`, `dose_screen.dart`)
    - `services/`: Business logic (`drift_service.dart`, `notification_service.dart`)
    - `widgets/`: Reusable UI components (`dialog_input.dart`, `medication_card.dart`)
    - `main.dart`: Entry point
- **Android Configuration** (`android/`):
    - `app/build.gradle.kts`: Configured for desugaring, Java 17, v2 embedding
    - `app/src/main/AndroidManifest.xml`: v2 embedding
    - `local.properties`: Flutter SDK at `C:\Users\kook1\dev\flutter`, Android SDK at `C:\Users\kook1\AppData\Local\Android\Sdk`
- **Dependencies**:
    - `flutter_local_notifications: ^19.2.1`
    - `flutter_riverpod: ^2.6.1`
    - `drift: ^2.22.0`
    - `get_storage: ^2.1.1`
    - See `pubspec.yaml` for full list

## Setup Instructions
1. **Open Project**:
    - Open `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2` in Android Studio.
2. **Sync Gradle**:
    - Go to **File > Project Structure > Project**.
    - Ensure **Android Gradle Plugin Version** is `8.7.4` and **Gradle Version** is `8.14`.
    - Sync (**File > Sync Project with Gradle Files**).
3. **Run Emulator**:
    - In **Device Manager**, create/use an emulator:
        - Device: Pixel 6, API 34 (x86_64)
        - Settings: 2GB RAM, 512MB VM Heap, 2 CPU cores, hardware acceleration
    - Verify:
      ```powershell
      adb devices