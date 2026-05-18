# NUMI Flutter App

Flutter source for the NUMI onboarding and phone verification flow.

## Run

Install Flutter first, then run:

```bash
cd numi_flutter
flutter create --platforms=ios,android .
flutter pub get
flutter run
```

Set the backend host in `.env`:

```dotenv
API_BASE_URL=http://10.0.2.2:8000
```

For Xcode:

```bash
open ios/Runner.xcworkspace
```

Then choose an iPhone Simulator and press Run.

