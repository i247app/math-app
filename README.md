# NUMI Flutter App

Flutter source for the NUMI onboarding and phone verification flow.

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

