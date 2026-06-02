# Agent Guide

## Project Summary

This repository is a Flutter mobile app named `numi_flutter`. It implements the NUMI onboarding and phone verification flow for a math learning app. The active product surface is a guided onboarding sequence:

1. Welcome screen
2. Phone login screen
3. OTP verification screen
4. Child profile setup screen

The app is currently Android-focused in the checked-in platform files. The README also references iOS generation through `flutter create --platforms=ios,android .`.

## Stack

- Flutter with Material 3
- Dart SDK `>=3.4.0 <4.0.0`
- State management: `flutter_bloc`
- Networking: `dio`
- JSON serialization: `json_annotation` with `json_serializable` and `build_runner`
- Lints: `flutter_lints`
- Tests: `flutter_test`
- API config loaded from `.env` as a Flutter asset

## Important Files

- `lib/main.dart`: app startup, loads `ApiConfig`, then runs `NumiApp`.
- `lib/app/numi_app.dart`: top-level `MaterialApp`, theme setup, optional auth service injection for tests.
- `lib/core/config/api_config.dart`: minimal `.env` parser. Currently reads `API_BASE_URL`.
- `lib/core/network/auth_models.dart`: shared `json_annotation` request/response models for signup and login.
- `lib/core/network/auth_models.g.dart`: generated JSON serialization code; do not edit by hand.
- `lib/core/network/network_client.dart`: single shared network API file. Owns Dio setup, request/response logging, timeout setup, JSON POST handling, transport error mapping, and endpoint methods such as signup/login.
- `env.example`: committed template for local API configuration.
- `lib/core/theme/app_colors.dart`: shared color tokens for the app.
- `lib/core/utils/phone_input_formatter.dart`: region-aware phone number formatting.
- `lib/features/onboarding/presentation/numi_home.dart`: main onboarding coordinator, `BlocProvider`, animated screen switching, OTP preview dialog, snackbar errors.
- `lib/features/onboarding/presentation/bloc/onboarding_cubit.dart`: onboarding state and state transitions.
- `lib/features/onboarding/data/otp_auth_api.dart`: auth service interface and temporary local OTP verification. It calls the shared `NetworkApi` rather than defining endpoint calls locally.
- `lib/features/onboarding/data/avatar_picker.dart`: avatar picker abstraction.
- `lib/features/onboarding/domain/phone_region.dart`: supported phone regions and formatting limits.
- `lib/features/onboarding/presentation/screens/`: screen-level widgets for each onboarding step.
- `lib/features/onboarding/presentation/widgets/`: reusable visual widgets and app background.
- `test/auth_models_test.dart`: serialization tests for auth request and response models.
- `test/auth_api_client_test.dart`: Dio client tests using a fake HTTP adapter.
- `test/widget_test.dart`: widget tests with fake OTP and avatar services.

## Architecture Notes

- The code follows a light feature-first layout under `lib/features/onboarding`.
- `NumiApp` accepts an optional `OtpAuthService`; keep this injection path intact because widget tests rely on it.
- `OnboardingCubit` owns the flow state. UI widgets should call cubit methods instead of duplicating navigation or API logic.
- `OtpAuthService` is an abstraction. Preserve this interface when changing API behavior so tests and future mock services stay simple.
- UI state is represented by immutable `OnboardingState` plus `copyWith`. When adding nullable fields, add explicit `clear...` flags if callers need to reset them to `null`.
- Most reusable UI primitives live in `common_widgets.dart`. Prefer reusing them before creating new button/card variants.
- `requestLoginOtp` now calls `OtpAuthService.sendLoginOtp` directly. The service delegates login to `NetworkApi`, then returns a local fake OTP until the real OTP API is available.

## API Behavior

- `ApiConfig.load()` reads `.env` from the Flutter asset bundle.
- `pubspec.yaml` includes `.env` under `flutter.assets`; keep that entry if runtime API config is still required.
- `.env` is local runtime configuration and is ignored by `.gitignore`; use `env.example` as the committed template.
- When setting up a fresh checkout, copy `env.example` to `.env` and adjust `API_BASE_URL` if needed.
- `NetworkClient` expects `ApiConfig.baseUrl` to provide the server root.
- `NetworkApi` is the single place for concrete endpoint methods. Features should not define their own endpoint clients.
- Current configured host: `https://x21.i247.com/go`.
- Auth endpoints used today:
  - `POST /auth/login` with `LoginRequest { phone }`
  - `POST /users/create` with `SignupRequest { phone, email? }`
- The shared API wrapper expects a JSON object response with `mstatus == 200`; otherwise it throws `NetworkException` using `mmessage`, `debug`, or `status`.
- Request/response logging is centralized in `NetworkClient` through Dio `LogInterceptor`.
- Login currently stores a local fake OTP code `1234` and verifies that locally. Replace this behavior when the backend OTP flow is available.
- Generated auth models are intentionally pinned to Dart-3.4-compatible generator versions in `pubspec.yaml`.

## Network Guide

- Put all Dio setup in `lib/core/network/network_client.dart`; do not create Dio instances in feature folders or widgets.
- Put all concrete API endpoint calls in `NetworkApi` in `lib/core/network/network_client.dart`.
- Put request and response JSON models in `lib/core/network/*_models.dart` files with `json_annotation`; commit the generated `*.g.dart` files.
- Feature data services, such as `OtpAuthApi`, may call `NetworkApi` and map shared network responses into feature-specific state/results.
- Widgets and cubits must not call Dio, `NetworkClient`, or endpoint paths directly. They should call feature services or cubit methods.
- Keep endpoint paths, payload construction, timeout policy, logging, and transport error mapping out of UI code.
- Treat backend logical errors separately from HTTP transport errors: `NetworkClient` handles transport/invalid JSON; `NetworkApi` validates API response envelopes such as `mstatus`.
- Do not keep placeholder or mock values for fields that should come from a real API response. Show loading, empty, or error states until real data is available, and display only mapped backend data for real API-backed values.
- When adding or changing a request/response model, run `dart run build_runner build --delete-conflicting-outputs`.

## UI Conventions

- The app uses a soft mint/teal visual language defined in `AppColors`.
- Most text is Vietnamese. Preserve existing wording style and accents when editing product copy.
- The app is multilingual. Any new or changed user-facing string must be added to `AppKeys` and `AppStrings` for both Vietnamese and English, then referenced through `context.getText`, `context.formatText`, `context.readText`, or `AppStrings.current`.
- Responsive behavior is handled with `MediaQuery` checks such as compact height `< 760` and tight width `< 370`.
- Screen content is constrained to a phone-sized width through `ScreenFrame`.
- Screen changes use `AnimatedSwitcher` in `NumiHome`; keep keys stable when adding or changing screens.
- Haptic feedback is used for invalid or primary interactions. Keep it lightweight and purposeful.
- For select/dropdown inputs, use a bottom sheet selector by default unless the design or user explicitly asks for another interaction. Prefer creating or reusing a shared bottom-sheet select input widget when multiple screens need the same behavior.
- If a task asks to implement or rebuild a UI from Figma and the Figma design cannot be fetched through the connector, do not implement it from guesses or local approximations. Stop and ask the user to reconnect/provide the Figma design context.
- When implementing Figma screens, do not blindly translate absolute Figma coordinates into `Stack` + `Positioned`. Prefer normal Flutter layout primitives such as `Column`, `Row`, `Padding`, `SizedBox`, `Spacer`, `Expanded`, `Flexible`, `Align`, `Center`, `AspectRatio`, `FractionallySizedBox`, `ConstrainedBox`, `GridView`, and `ListView`.
- Use `Stack` / `Positioned` only when the design genuinely requires overlapping or anchored decorative layers. Do not use positional layout for ordinary vertical content, buttons, headers, forms, cards, or lists.
- For new Figma implementation work, do not create viewport scaling helpers or multiply Figma values by a `scale` factor. Use the numeric spacing, size, radius, and font values from Figma directly unless a responsive constraint is explicitly needed.
- Icons in Figma-driven screens must come from stable local Figma-exported SVG/icon assets. Do not substitute Material icons unless the Figma node does not provide an icon and the user approves the substitution.
- Avoid hardcoded canvas dimensions like `_designWidth`, `_designHeight`, or `constraints.maxWidth / 390` for new Figma work. Size and space UI from the actual device constraints, safe-area padding, content constraints, and relative layout rules.
- Avoid hardcoded width/height unless the element has a real fixed design role such as an icon, avatar, toolbar button, or known asset ratio. Prefer min/max constraints and relative sizing for screen sections.
- Avoid fixed heights and fixed aspect ratios for containers with text or dynamic content unless the design truly requires clipping. Use intrinsic layout, padding, min/max constraints, `Flexible`/`Expanded`, and scrollable content where appropriate so localization, font metrics, and backend data do not cause overflow.

## Common Commands

Run these from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
dart format lib test
dart run build_runner build --delete-conflicting-outputs
```

If platform folders need to be regenerated:

```bash
flutter create --platforms=ios,android .
```

## Testing Guidance

- Do not add new tests unless the user explicitly asks for tests.
- Do not run `flutter test` unless the user explicitly asks to run tests.
- Existing tests may remain in place, but normal implementation work should avoid creating or modifying test files.
- If changing `lib/core/network/auth_models.dart`, rerun build_runner and commit the generated `auth_models.g.dart`.
- Current implementation status: `flutter analyze` passed after the Dio/json model changes. Full `flutter test` was not run because the user asked to stop test execution.

## Change Guidelines

- Do not hardcode API hosts in Dart files; use `.env` and `ApiConfig`.
- Keep non-secret defaults in `env.example`; keep machine-specific values in `.env`.
- Do not remove `NumiApp.authService` unless tests are updated with an equivalent injection path.
- Keep phone formatting logic in `PhoneInputFormatter` and region metadata in `PhoneRegion`.
- Keep onboarding business logic in `OnboardingCubit`; screens should remain mostly presentational.
- Keep request and response wire shapes in `lib/core/network/auth_models.dart`, not as ad hoc maps in UI code.
- Keep Dio transport details and endpoint methods inside `NetworkApi` / `NetworkClient` in `lib/core/network/network_client.dart`.
- UI and cubits should call feature services such as `OtpAuthService`, not `NetworkApi` directly.
- Avoid broad visual rewrites unless requested. The current UI is highly custom and hand-tuned for mobile sizing.
- Be careful with `.env`: it is bundled as an app asset in this project, so do not put production secrets in it.

## Known Gaps

- The project currently has Android platform files checked in; iOS files are not present in this checkout.
- The README run command says `cd numi_flutter`, but this repository root is already the Flutter project root.
- The OTP resend label says "after 30 seconds", but there is no visible countdown enforcement in the current UI.
- OTP verification is local and temporary. It does not call a backend OTP verification endpoint yet.
