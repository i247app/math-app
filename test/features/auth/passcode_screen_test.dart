import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';
import 'package:numi/features/auth/widgets/passcode/passcode_action_button.dart';

void main() {
  Future<void> pumpPasscodeScreen(
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
  }

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
    expect(
      tester
          .widget<PasscodeActionButton>(find.byType(PasscodeActionButton))
          .onPressed,
      isNull,
    );

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

  testWidgets('clears and refocuses the single PIN field for confirmation', (
    tester,
  ) async {
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
    await tester.enterText(field, '1234');
    await tester.pump();
    await tester.ensureVisible(find.byType(PasscodeActionButton));
    await tester.tap(find.byType(PasscodeActionButton));
    await tester.pump();

    expect(submitted, isNull);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);

    await tester.enterText(field, '1234');
    await tester.pump();
    await tester.tap(find.byType(PasscodeActionButton));
    await tester.pump();
    expect(submitted, '1234');
  });
}
