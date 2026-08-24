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

If platform folders need to be regenerated:

```bash
make create-platforms
```

For Xcode:

```bash
open ios/Runner.xcworkspace
```

Then choose an iPhone Simulator and press Run.

