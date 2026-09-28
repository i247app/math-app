import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/localization/strings/auth_strings.dart';
import 'package:numi/core/localization/strings/settings/settings_strings.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';
import 'package:numi/features/auth/widgets/passcode/passcode_action_button.dart';
import 'package:numi/features/welcome/widgets/numi_brand_text.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Vietnamese PIN login copy uses the shorter wording', () {
    expect(authStrings['vi']?[AppKeys.loginWithPin], 'Đăng nhập bằng PIN');
    expect(
      settingsStrings['vi']?[AppKeys.createPasscodeSubtitle],
      'Mã PIN để đăng nhập',
    );
    expect(settingsStrings['vi']?[AppKeys.passcodeCreate], 'Tạo');
    expect(
      settingsStrings['en']?[AppKeys.createPasscodeSubtitle],
      'PIN for login',
    );
    expect(settingsStrings['en']?[AppKeys.passcodeCreate], 'Create');
    expect(settingsStrings['vi']?[AppKeys.unlockPasscodeTitle], 'Mã PIN');
    expect(settingsStrings['vi']?[AppKeys.unlockPasscodeSubtitle], 'Mã PIN');
  });

  Future<LingoProvider> pumpPasscodeScreen(
    WidgetTester tester, {
    required PasscodeScreenMode mode,
    required Future<String?> Function(String) onSubmit,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: PasscodeScreen(mode: mode, onBack: () {}, onSubmit: onSubmit),
        ),
      ),
    );
    await tester.pump();
    return lingo;
  }

  testWidgets('setup action and description localize to English', (
    tester,
  ) async {
    final originalLanguage = AppLanguageState.current;
    addTearDown(() => AppLanguageState.current = originalLanguage);
    final lingo = await pumpPasscodeScreen(
      tester,
      mode: PasscodeScreenMode.setup,
      onSubmit: (_) async => null,
    );
    await lingo.setLanguage(AppLanguage.en);
    await tester.pump();

    expect(find.text('PIN for login'), findsOneWidget);
    expect(find.text('CREATE'), findsOneWidget);
  });

  testWidgets('deletes PIN digits without a hardware backspace event', (
    tester,
  ) async {
    String? submitted;
    await pumpPasscodeScreen(
      tester,
      mode: PasscodeScreenMode.unlock,
      onSubmit: (code) async {
        submitted = code;
        return null;
      },
    );

    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    expect(find.byType(NumiBrandText), findsOneWidget);
    expect(find.text('PIN'), findsNothing);
    expect(find.text('Mã PIN'), findsOneWidget);
    expect(
      tester
          .widget<PasscodeActionButton>(find.byType(PasscodeActionButton))
          .onPressed,
      isNull,
    );
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

    for (final code in ['123', '12', '1', '']) {
      await tester.enterText(field, code);
      await tester.pump();
      expect(tester.widget<TextField>(field).controller!.text, code);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      expect(find.text('•'), findsNWidgets(code.length));
    }

    await tester.enterText(field, '9876');
    await tester.pump();
    expect(
      tester
          .widget<PasscodeActionButton>(find.byType(PasscodeActionButton))
          .onPressed,
      isNotNull,
    );
    await tester.ensureVisible(find.byType(PasscodeActionButton));
    await tester.tap(find.byType(PasscodeActionButton));
    await tester.pump();
    expect(submitted, '9876');
  });

  testWidgets('creates a visible PIN with one submit', (tester) async {
    String? submitted;
    await pumpPasscodeScreen(
      tester,
      mode: PasscodeScreenMode.setup,
      onSubmit: (code) async {
        submitted = code;
        return null;
      },
    );

    final field = find.byType(TextField);
    expect(find.byType(NumiBrandText), findsNothing);
    expect(find.text('Tạo Mã PIN'), findsOneWidget);
    expect(find.text('Mã PIN để đăng nhập'), findsOneWidget);
    expect(find.text('TẠO'), findsOneWidget);
    expect(tester.widget<TextField>(field).obscureText, isFalse);
    await tester.enterText(field, '1234');
    await tester.pump();
    for (final digit in ['1', '2', '3', '4']) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(find.text('•'), findsNothing);
    await tester.ensureVisible(find.byType(PasscodeActionButton));
    await tester.tap(find.byType(PasscodeActionButton));
    await tester.pump();

    expect(submitted, '1234');
    expect(tester.widget<TextField>(field).controller!.text, '1234');
    expect(find.text('Nhập Lại Mã PIN'), findsNothing);
    expect(find.text('•'), findsNothing);
    for (final digit in ['1', '2', '3', '4']) {
      expect(find.text(digit), findsOneWidget);
    }
  });
}
