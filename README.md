# NUMI Flutter App

Flutter source for NUMI AI Math.

## Project structure

Code is grouped by feature, with folders named after their responsibility:

```text
lib/
  app/                         # Startup, navigation and dependency wiring
    controllers/               # App-wide flow coordination
    composition/               # Service creation and feature integration
    navigation/
  core/                        # Network, theme, localization and platform tools
  shared/                      # UI and helpers used by multiple features
  features/
    classroom_exercise/
      screens/                 # Pages and dashboard tabs
      widgets/                 # UI pieces within this feature
      controllers/             # State and user actions
      models/                  # Models used by the app
      data/                    # API clients, service interfaces and cache
      helpers/                 # Formatting and other focused helper functions
```

Other features follow the same layout. Create a folder only when it is needed;
small features do not need every folder. Related widgets or screen parts can
stay together in a subfolder. Navigation contracts belong in `navigation/`.

- Use `classroom_exercise` for file/folder names and `ClassroomExercise` in type
  names. Use `student_` and `teacher_` when the two roles have different flows.
- Keep state and request handling in controllers; screens handle rendering,
  dialogs, haptics and navigation.
- Keep a service interface beside its implementation in `data/`, such as
  `classroom_exercise_service.dart` and `classroom_exercise_api.dart`.
- API payload models stay in `*_api_models.dart` when their shape differs from
  the app models. `*_conversion.dart` converts them using `toModel()` or
  `toDto()`. There are no separate `dto/`, `mappers/` or `contracts/` folders.
- API values such as `HOMEWORK`, JSON keys, translation keys and asset paths
  retain their existing values. `HOMEWORK` is still a purpose alongside `QUIZ`
  and `EXAM`; renaming the feature does not change the backend contract.

Tests live under `test/`, grouped by feature or shared component. Architecture
checks are performed during refactoring rather than kept as permanent tests.

## Run

Install Flutter first, then run:

```bash
make setup
make run
```

Without `make`, run the equivalent commands from the repository root:

```bash
cp env.example .env
flutter pub get
dart run build_runner build
flutter run
```

## Test

Run the complete suite with detailed progress and deterministic scheduling:

```bash
make test
```

Without `make`:

```bash
flutter test --reporter expanded --concurrency=1
```

The reporter prints the current test file and test name. If no test name is
printed, check `flutter --version` first: Flutter may be waiting for write
access to its SDK cache rather than waiting on a test.

If platform folders need to be regenerated:

```bash
make create-platforms
```

For Xcode:

```bash
open ios/Runner.xcworkspace
```

Then choose an iPhone Simulator and press Run.

