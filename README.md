# MedMinder2

## Project Overview
**MedMinder2** is a Flutter-based medication management app designed to help users track medications, manage doses, and schedule reminders. Built with **Flutter 3.32.1** and **Dart 3.8.1**, it runs on Android (API 34, Pixel 6 emulator) under Windows 11. The app uses **Riverpod** for state management, **Drift** for local SQLite storage (`medminder.sqlite`), **get_storage** for lightweight persistence, and **flutter_local_notifications (^19.2.1)** for reminders. It supports adding, editing, and deleting medications, doses, and schedules, with a clean Material Design UI and robust data validation.

## Importance of `medication_matrix.dart`
The `common/medication_matrix.dart` file is the cornerstone of MedMinder2’s logic, ensuring consistency and reliability:
- **Medication Types**: Defines supported forms (e.g., `Tablet`, `Injection`, `Capsule`) and maps them to UI dropdowns.
- **Unit Management**: Specifies valid units for concentration (e.g., `mg`, `mcg`, `mg/mL`) and administration (e.g., `mL`, `IU`), dynamically sourced by medication type.
- **Calculations and Conversions**: Provides `convertUnit` for unit conversions (e.g., mg to mcg) and `calculateAdministrationDose` for precise dose calculations (e.g., mL for injections).
- **Validation**: Enforces input ranges (0.01–999) via `isValidValue`, preventing invalid entries.
  This file drives UI logic, form validations, and calculations across screens, ensuring accurate and safe medication management.

## Core Features
1. **Medication Management**:
    - Add, edit, delete medications with name, concentration, unit, quantity, and type (e.g., Tablet, Injection).
    - Stored in Drift SQLite database (`medminder.sqlite`).
    - UI: `features/medication/screens/medication_screen.dart` with dynamic summary and validation.
2. **Dose Management**:
    - Create, edit, delete doses linked to medications, supporting tablet counts or concentration-based inputs (e.g., mL for injections).
    - UI: `features/dose/screens/dose_form.dart` with dialog-based inputs and real-time summary updates.
3. **Scheduling**:
    - Set daily or weekly dose schedules with customizable days and times.
    - Partial notification integration via `flutter_local_notifications`.
    - UI: `features/schedule/screens/schedule_screen.dart` with frequency, day selection, and optional dose assignment.
4. **History Tracking**:
    - View dose history across medications.
    - UI: `features/history/screens/history_screen.dart` with medication and schedule details.
5. **Home Screen**:
    - Lists medications via `features/home/widgets/medication_card.dart`, showing stock and schedules.
    - Navigation to Medication, Dose, Schedule, and History screens.
6. **UI and Theming**:
    - Material Design with gradient app bars, full-width cards, and dialog inputs.
    - Theming in `common/theme/app_theme.dart` (primary color: teal).

## Planned Functionality
- **Notifications**: Fully implement `NotificationService` for dose reminders, ensuring exact alarms and multi-day scheduling.
- **Reconstitution Calculator** for Injection and other liquid meds.
- **Expanded Medication Types**: Support additional forms (e.g., `Drops`, `Inhaler`) from `medication_matrix.dart`.
- **Unit Tests**: Add tests for core operations (e.g., Schedule creation, Dose deletion) using the `test` package.

## Current Status
- **Date**: June 6, 2025, 7:00 PM AEST
- **Platform**: Android (API 34, Pixel 6 emulator)
- **Environment**: Windows 11, Flutter 3.32.1 (stable), Dart 3.8.1
- **Project Directory**: `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2`
- **App Behavior**:
    - **Home Screen**: Displays medications, navigates to other screens.
    - **Medication Screen**: Form with dropdown, validated inputs, no overflow, saves to database.
    - **Dose Screen**: Manages doses with tablet/injection support, drop size calibration.
    - **Schedule Screen**: Creates schedules with daily/weekly options, partial notification support.
    - **History Screen**: Shows dose history with medication details.
    - **Debug Logging**: Enabled for database and UI operations.
- **Resolved Issues**:
    - Android v1 embedding upgraded to v2.
    - Desugaring enabled (`isCoreLibraryDesugaringEnabled`, `multiDexEnabled`).
    - Backup path corrected to `C:\Users\kook1\AndroidStudioProjects\Projects\medminder_backup`.
    - Drift `Column` conflict resolved with `as drift` prefix.
    - `CardTheme` mismatch fixed with `CardThemeData`.
    - MedicationScreen overflow (87 pixels) fixed with `SingleChildScrollView`.
- **Recent Updates**:
    - Refactored `MedicationScreen` and `DoseForm` with modular widgets, constants, and optimized code.
    - Refactored `ScheduleScreen` with `ScheduleFormField`, `ScheduleFormCard`, and constants.
    - Proposed folder structure cleanup for feature-based organization.
- Update: Fixed doseTextName typo in SchedulesAddScreen to resolve compilation error.
- Update: Fixed navbar inactive buttons, added MedicationOverviewScreen, and enhanced SchedulesInfoScreen with table views.
- Update: Added medicationId to DosesAddScreen for pre-selection in MedicationOverviewScreen.
- Update: Fixed amount getter error in DosesAddScreen by using _amountController.text.
- Update: Fixed syntax error in SchedulesInfoScreen and added getDoseHistory to AppDatabase.
- Update: Lightened navbar, added dose deletion, enhanced schedule alerts, fixed view statuses, and improved notification logging.
- Update: Fixed app_theme.dart constant error using Color(0xFF9E9E9E) for navbar inactive buttons.
- Update: Fixed LateInitializationError in notifications, lightened navbar, corrected Week view status, and enhanced schedule pre-selection.
- Update: Fixed initializeTimeZones error, added _weekdayToIndex, lightened navbar, and verified pre-selection.
- Update: Fixed LateInitializationError in NotificationService, added _weekdayToIndex, lightened navbar, corrected Week view status, and verified medication pre-selection.
- Update: Added debug button to HomeScreen AppBar for navigation to /debug route.
- - Update: Replaced MedicationsEditScreen with MedicationOverviewScreen, renamed route to /medications-overview, and applied Figma-style UI with animations.
- Fixed animation errors in MedicationOverviewScreen, ensuring smooth Figma-style transitions.
- - Fixed MedicationOverviewScreen gradient errors by using Colors.grey[50]! instead of invalid grey50.
- 
## Project Structure
- **Flutter Code** (`lib/`):
    - `common/`:
        - `constants/`: App-wide constants (`app_colors.dart`, `app_strings.dart`).
        - `mixins/`: Reusable mixins (`controller_mixin.dart`).
        - `theme/`: Theming (`app_theme.dart`).
        - `utils/`: Utilities (`calculations.dart`, `formatters.dart`).
        - `medication_matrix.dart`: Core medication logic.
    - `data/`: Database (`database.dart`, `database.g.dart`).
    - `features/`:
        - `dose/`: Dose management (`screens/dose_screen.dart`, `screens/dose_form.dart`, `widgets/`, `constants/`).
        - `medication/`: Medication management (`screens/medication_screen.dart`, `screens/medication_info_screen.dart`, `widgets/`, `constants/`).
        - `schedule/`: Schedule management (`screens/schedule_screen.dart`, `widgets/`, `constants/`).
        - `history/`: History view (`screens/history_screen.dart`).
        - `home/`: Home screen (`screens/home_screen.dart`, `widgets/medication_card.dart`).
    - `services/`: Logic (`drift_service.dart`, `notification_service.dart`).
    - `widgets/`: App-wide widgets (`dialog_input.dart`, `form_widgets.dart`).
    - `main.dart`: Entry point.
- **Android Configuration** (`android/`):
    - `app/build.gradle.kts`: Desugaring, Java 17, v2 embedding.
    - `app/src/main/AndroidManifest.xml`: Permissions (`SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`).
    - `local.properties`: Flutter SDK at `C:\Users\kook1\dev\flutter`, Android SDK at `C:\Users\kook1\AppData\Local\Android\Sdk`.
- **Dependencies**:
    - `flutter_local_notifications: ^19.2.1`
    - `flutter_riverpod: ^2.6.1`
    - `drift: ^2.22.0`
    - `get_storage: ^2.1.1`
    - `intl: ^0.20.0`
    - `logging: ^1.3.0`
    - `path_provider: ^2.1.5`
    - `sqlite3_flutter_libs: ^0.6.2`
    - `timezone: ^0.10.0`
    - See `pubspec.yaml` for full list.

## Setup Instructions
1. **Open Project**:
    - Load `C:\Users\kook1\AndroidStudioProjects\Projects\medminder2` in Android Studio.
2. **Sync Gradle**:
    - Set **Android Gradle Plugin Version** to `8.7.3` and **Gradle Version** to `8.12` in **File > Project Structure > Project**.
    - Sync via **File > Sync Project with Gradle Files**.
3. **Run Emulator**:
    - Use Pixel 6 emulator (API 34, x86_64, 2GB RAM, 512MB VM Heap, 2 CPU cores, hardware acceleration) in **Device Manager**.
    - Verify with:
      ```powershell
      adb devices