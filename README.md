# MedMinder2

## Project Overview
**MedMinder2** is a Flutter-based medication management app designed to help users track medications, manage doses, and receive timely reminders. Built with **Flutter 3.32.1** and **Dart 3.8.1**, it runs on Android (API 34, Pixel 6 emulator) under Windows 11. The app uses **Riverpod** for state management, **Drift** for local SQLite storage (`medminder.sqlite`), **get_storage** for lightweight persistence, and **flutter_local_notifications (^19.2.1)** for reminders. It supports adding, editing, and deleting medications and doses, with a clean UI and robust data validation.

## Importance of `medication_matrix.dart`
The `medication_matrix.dart` file is the cornerstone of MedMinder2’s functionality, centralizing medication-related logic and ensuring consistency across the app. It defines:
- **Medication Types**: Enumerates supported forms (`Tablet`, `Injection`), mapping to UI dropdowns.
- **Unit Management**: Specifies valid units for concentration (`mg`, `mcg`, `mg/mL`, `IU/mL`) and administration (`mg`, `mcg`, `mL`, `IU`), sourced dynamically based on medication type.
- **Calculations and Conversions**: Provides `convertUnit` for unit conversions (e.g., mg to mcg) and `calculateAdministrationDose` for dose calculations (e.g., mL for injections).
- **Validation**: Ensures inputs (concentration, quantity, doses) stay within valid ranges (0.01–999) via `isValidValue`.
  By consolidating these rules, `medication_matrix.dart` ensures accurate dose calculations, consistent unit handling, and type-specific validations, making it integral to the app’s reliability and user safety.

## Core Features
1. **Medication Tracking**:
    - Add, edit, delete medications with name, concentration, unit, quantity, and type (Tablet or Injection).
    - Stored in Drift SQLite database (`medminder.sqlite`).
2. **Dose Management**:
    - Add, edit, delete doses per medication, with amount, unit, and optional weight-based calculations.
    - Linked to medications via foreign keys.
3. **Scheduling and Notifications** (Planned):
    - Schedule dose reminders using `flutter_local_notifications`.
    - Not yet implemented.
4. **Unit Conversions and Calculations**:
    - Leverages `medication_matrix.dart` for conversions (e.g., mg to mcg) and weight-based dosing.
    - UI integration pending for advanced calculations.
5. **User Interface**:
    - **Home Screen**: Lists medications via `MedicationCard` widgets, showing quantity and type.
    - **Medication Screen**: Form for medication details, with validation and dynamic summary (appears after name entry).
    - **Dose Screen**: Manages doses with weight-based calculations and drop size for injections.
    - Theming in `lib/core/theme.dart` (teal primary color).

## Planned Functionality
- Implement `NotificationService` for dose reminders.
- Integrate `MedCalculations` in `DoseScreen` for weight-based dosing.
- Expand medication types beyond Tablet and Injection.

## Current Status
- **Date**: June 5, 2025
- **Platform**: Android (API 34, Pixel 6 emulator)
- **Environment**: Windows 11, Flutter 3.32.1 (stable), Dart 3.8.1
- **Project Directory**: `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2`
- **App Behavior**:
    - **Home Screen**: Displays medications, navigates to Medication or Dose screens.
    - **Medication Screen**: Validates inputs, defaults units to `mg`, uses `Concentration` and `Quantity` labels.
    - **Dose Screen**: Supports dose management, with drop size calibration for injections.
    - **Debug Logging**: Logs database operations.
- **Resolved Issues**:
    - Android v1 embedding fixed with v2.
    - Desugaring enabled (`isCoreLibraryDesugaringEnabled`, `multiDexEnabled`).
    - Backup issues corrected to `C:\Users\kook1\AndroidStudioProjects\Projects\medminder_backup`.
    - Drift `Column` conflict resolved with `as drift` prefix.
    - `CardTheme` mismatch fixed using `CardThemeData`.
- **New Features**:
    - `MedicationCard` displays stock (e.g., "50 x 100mg Tablets remaining").
    - `DoseScreen` includes helper text, increased field spacing, dynamic summary.
    - `MedicationMatrix` integrated for units, calculations, validations.
    - Drop size calibration for injections in `DoseScreen`.

## Project Structure
- **Flutter Code** (`lib/`):
    - `core/`: Utilities (`calculations.dart`, `constants.dart`, `medication_matrix.dart`, `theme.dart`, `utils.dart`, `controller_mixin.dart`)
    - `data/`: Database (`database.dart`, `database.g.dart`)
    - `screens/`: UI (`home_screen.dart`, `medication_screen.dart`, `dose_screen.dart`, `history_screen.dart`)
    - `services/`: Logic (`drift_service.dart`, `notification_service.dart`)
    - `widgets/`: Components (`dialog_input.dart`, `medication_card.dart`, `form_widgets.dart`)
    - `main.dart`: Entry point
- **Android Configuration** (`android/`):
    - `app/build.gradle.kts`: Desugaring, Java 17, v2 embedding
    - `app/src/main/AndroidManifest.xml`: v2 embedding, permissions (e.g., `SCHEDULE_EXACT_ALARM`)
    - `local.properties`: Flutter SDK at `C:\Users\kook1\dev\flutter`, Android SDK at `C:\Users\kook1\AppData\Local\Android\Sdk`
- **Dependencies**:
    - `flutter_local_notifications: ^19.2.1`
    - `flutter_riverpod: ^2.6.1`
    - `drift: ^2.22.0`
    - `get_storage: ^2.1.1`
    - See `pubspec.yaml` for full list

## Setup Instructions
1. **Open Project**:
    - Load `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2` in Android Studio.
2. **Sync Gradle**:
    - Set **Android Gradle Plugin Version** to `8.7.4` and **Gradle Version** to `8.14` in **File > Project Structure > Project**.
    - Sync via **File > Sync Project with Gradle Files**.
3. **Run Emulator**:
    - In **Device Manager**, use/create a Pixel 6 emulator (API 34, x86_64, 2GB RAM, 512MB VM Heap, 2 CPU cores, hardware acceleration).
    - Verify with:
      ```powershell
      adb devices


# MedMinder

MedMinder is a Flutter-based mobile application designed to help users manage their medications, track doses, and schedule reminders. It provides a clean, intuitive interface for adding medications, setting dose amounts, and creating schedules with notifications.

## Features

- **Medication Management**: Add, edit, and delete medications with details like name, concentration, quantity, and type (Tablet or Injection).
- **Dose Tracking**: Create and manage doses for each medication, with support for tablet counts or concentration-based inputs.
- **Scheduling**: Set daily or weekly schedules for doses with customizable days and times, integrated with local notifications.
- **History View**: View a history of all doses across medications.
- **Notifications**: Schedule reminders for doses using Flutter Local Notifications, with support for exact alarms.
- **Database**: Uses Drift for local SQLite storage, with options to export the database to the Download folder.
- **Responsive UI**: Polished Material Design with gradient headers, full-width cards, and dialog-based inputs for text fields.

## Getting Started

### Prerequisites

- Flutter SDK: Follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
- Dart SDK: Included with Flutter.
- Android Studio or VS Code for development.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/medminder.git
   cd medminder