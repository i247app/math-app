import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_service_scope.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/navigation/passcode_navigator.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';
import 'package:numi/features/auth/widgets/passcode/passcode_action_button.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final verification in [false, true]) {
    testWidgets(
      'app navigator builds the ${verification ? 'verification' : 'setup'} screen and returns success',
      (tester) async {
        String? submitted;
        final route = await _pump(
          tester,
          verification: verification,
          onSubmit: (pin) async {
            submitted = pin;
            return null;
          },
        );
        final screen = tester.widget<PasscodeScreen>(
          find.byType(PasscodeScreen),
        );
        expect(
          screen.mode,
          verification ? PasscodeScreenMode.verify : PasscodeScreenMode.setup,
        );
        expect(
          screen.titleKey,
          verification
              ? AppKeys.verifyPasscodeTitle
              : AppKeys.createPasscodeTitle,
        );
        expect(
          screen.primaryLabelKey,
          verification ? AppKeys.passcodeRemove : null,
        );
        await _submit(tester, '2468');
        expect(submitted, '2468');
        expect(await route.result, isTrue);
        expect(find.byType(PasscodeScreen), findsNothing);
        expect(find.text('Open PIN'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'canceling ${verification ? 'verification' : 'setup'} returns false without submitting',
      (tester) async {
        int submits = 0;
        final route = await _pump(
          tester,
          verification: verification,
          onSubmit: (_) async {
            submits++;
            return null;
          },
        );
        tester.widget<PasscodeScreen>(find.byType(PasscodeScreen)).onBack();
        await tester.pumpAndSettle();
        expect(await route.result, isFalse);
        expect(submits, 0);
        expect(find.text('Open PIN'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'validation errors stay on the form and a valid retry completes the route',
    (tester) async {
      final route = await _pump(
        tester,
        verification: true,
        onSubmit: (pin) async => pin == '2468' ? null : 'Incorrect PIN',
      );
      await _submit(tester, '0000');
      expect(find.byType(PasscodeScreen), findsOneWidget);
      expect(find.text('Incorrect PIN'), findsOneWidget);
      await _submit(tester, '2468');
      expect(await route.result, isTrue);
      expect(find.byType(PasscodeScreen), findsNothing);
    },
  );

  testWidgets('a route dismissed without a result returns false', (
    tester,
  ) async {
    final route = await _pump(tester, onSubmit: (_) async => null);
    Navigator.of(tester.element(find.byType(PasscodeScreen))).pop();
    await tester.pumpAndSettle();
    expect(await route.result, isFalse);
  });

  testWidgets(
    'late success after Back does not pop the underlying Settings route',
    (tester) async {
      final completed = Completer<String?>();
      final route = await _pump(tester, onSubmit: (_) => completed.future);
      final screen = tester.widget<PasscodeScreen>(find.byType(PasscodeScreen));
      final submit = screen.onSubmit('2468');
      screen.onBack();
      completed.complete(null);
      await submit;
      await tester.pumpAndSettle();
      expect(await route.result, isFalse);
      expect(find.text('Open PIN'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<({Future<bool> result})> _pump(
  WidgetTester tester, {
  bool verification = false,
  required PasscodeSubmit onSubmit,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final lingo = LingoProvider();
  addTearDown(lingo.dispose);
  late Future<bool> result;
  await tester.pumpWidget(
    AppServiceScope(
      services: AppServices(),
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  final navigator = context.read<PasscodeNavigator>();
                  result = verification
                      ? navigator.verify(
                          context: context,
                          titleKey: AppKeys.verifyPasscodeTitle,
                          primaryLabelKey: AppKeys.passcodeRemove,
                          onSubmit: onSubmit,
                        )
                      : navigator.setup(
                          context: context,
                          titleKey: AppKeys.createPasscodeTitle,
                          onSubmit: onSubmit,
                        );
                },
                child: const Text('Open PIN'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open PIN'));
  await tester.pumpAndSettle();
  return (result: result);
}

Future<void> _submit(WidgetTester tester, String pin) async {
  await tester.enterText(find.byType(TextField), pin);
  await tester.pump();
  await tester.tap(find.byType(PasscodeActionButton));
  await tester.pumpAndSettle();
}
