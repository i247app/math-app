import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_service_scope.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/navigation/passcode_navigator.dart';
import 'package:numi/features/session/data/passcode_service.dart';
import 'package:numi/features/settings/controllers/settings_passcode_controller.dart';
import 'package:numi/features/settings/navigation/settings_passcode_flow.dart';
import 'package:numi/features/settings/widgets/menu/passcode_settings_sheet.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets(
    'creating a PIN uses the injected Auth contract and updates Settings',
    (tester) async {
      final service = _Passcodes();
      final routes = _Routes()..newPin = '2468';
      final controller = await _pump(tester, service, routes);
      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();
      expect(routes.calls, [
        (kind: 'setup', title: AppKeys.createPasscodeTitle, primary: null),
      ]);
      expect(service.saved, [(7, '2468')]);
      expect(controller.hasPasscode, isTrue);
    },
  );

  testWidgets('canceling PIN creation leaves Settings unchanged', (
    tester,
  ) async {
    final service = _Passcodes();
    final routes = _Routes();
    final controller = await _pump(tester, service, routes);
    await tester.tap(find.text('Open PIN'));
    await tester.pumpAndSettle();
    expect(service.saved, isEmpty);
    expect(controller.hasPasscode, isFalse);
  });

  testWidgets('changing a PIN verifies the current PIN before opening setup', (
    tester,
  ) async {
    final service = _Passcodes()..pin = '1234';
    final routes = _Routes()
      ..attempts = ['0000', '1234']
      ..newPin = '2468';
    await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.change);
    expect(routes.calls, [
      (
        kind: 'verify',
        title: AppKeys.enterCurrentPasscodeTitle,
        primary: AppKeys.passcodeContinue,
      ),
      (kind: 'setup', title: AppKeys.changePasscodeTitle, primary: null),
    ]);
    expect(routes.validationMessages.first, isNotEmpty);
    expect(routes.validationMessages.last, isNull);
    expect(service.verified, [(7, '0000'), (7, '1234')]);
    expect(service.saved, [(7, '2468')]);
  });

  testWidgets('failed verification does not open setup or change the PIN', (
    tester,
  ) async {
    final service = _Passcodes()..pin = '1234';
    final routes = _Routes()
      ..attempts = ['0000']
      ..newPin = '2468';
    await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.change);
    expect(routes.calls.single.kind, 'verify');
    expect(routes.validationMessages.single, isNotEmpty);
    expect(service.saved, isEmpty);
    expect(service.pin, '1234');
  });

  testWidgets('canceling setup after verification retains the old PIN', (
    tester,
  ) async {
    final service = _Passcodes()..pin = '1234';
    final routes = _Routes()..attempts = ['1234'];
    await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.change);
    expect(routes.calls.map((call) => call.kind), ['verify', 'setup']);
    expect(service.saved, isEmpty);
    expect(service.pin, '1234');
  });

  testWidgets('removing a PIN verifies it with the remove intent', (
    tester,
  ) async {
    final service = _Passcodes()..pin = '1234';
    final routes = _Routes()..attempts = ['1234'];
    final controller = await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.remove);
    expect(routes.calls, [
      (
        kind: 'verify',
        title: AppKeys.verifyPasscodeTitle,
        primary: AppKeys.passcodeRemove,
      ),
    ]);
    expect(service.cleared, [7]);
    expect(controller.hasPasscode, isFalse);
  });

  testWidgets('canceling verification does not remove the PIN', (tester) async {
    final service = _Passcodes()..pin = '1234';
    final routes = _Routes();
    final controller = await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.remove);
    expect(service.cleared, isEmpty);
    expect(controller.hasPasscode, isTrue);
  });

  testWidgets('remove failures stay in Settings and retain the PIN state', (
    tester,
  ) async {
    final service = _Passcodes()
      ..pin = '1234'
      ..failClear = true;
    final routes = _Routes()..attempts = ['1234'];
    final controller = await _pump(tester, service, routes);
    await _select(tester, PasscodeSettingsAction.remove);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(controller.hasPasscode, isTrue);
    expect(service.pin, '1234');
  });

  testWidgets('a missing account cannot open a PIN route', (tester) async {
    final routes = _Routes()..newPin = '2468';
    final service = _Passcodes();
    await _pump(tester, service, routes, userId: null);
    await tester.tap(find.text('Open PIN'));
    await tester.pumpAndSettle();
    expect(routes.calls, isEmpty);
    expect(service.saved, isEmpty);
  });
}

Future<SettingsPasscodeController> _pump(
  WidgetTester tester,
  _Passcodes service,
  _Routes routes, {
  int? userId = 7,
}) async {
  final controller = SettingsPasscodeController(service: service);
  await controller.load(userId);
  final lingo = LingoProvider();
  addTearDown(controller.dispose);
  addTearDown(lingo.dispose);
  await tester.pumpWidget(
    AppServiceScope(
      services: AppServices(passcodeNavigator: routes),
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => const SettingsPasscodeFlow().open(
                  context: context,
                  userId: userId,
                  controller: controller,
                ),
                child: const Text('Open PIN'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

Future<void> _select(WidgetTester tester, PasscodeSettingsAction action) async {
  await tester.tap(find.text('Open PIN'));
  await tester.pumpAndSettle();
  final sheet = tester.widget<PasscodeSettingsSheet>(
    find.byType(PasscodeSettingsSheet),
  );
  if (action == PasscodeSettingsAction.change) {
    sheet.onChange();
  } else {
    sheet.onRemove();
  }
  await tester.pumpAndSettle();
}

class _Routes implements PasscodeNavigator {
  String? newPin;
  List<String> attempts = [];
  final calls = <({String kind, String title, String? primary})>[];
  final validationMessages = <String?>[];
  @override
  Future<bool> setup({
    required BuildContext context,
    required String titleKey,
    required PasscodeSubmit onSubmit,
  }) async {
    calls.add((kind: 'setup', title: titleKey, primary: null));
    final pin = newPin;
    return pin != null && await onSubmit(pin) == null;
  }

  @override
  Future<bool> verify({
    required BuildContext context,
    required String titleKey,
    required String primaryLabelKey,
    required PasscodeSubmit onSubmit,
  }) async {
    calls.add((kind: 'verify', title: titleKey, primary: primaryLabelKey));
    for (final pin in attempts) {
      final error = await onSubmit(pin);
      validationMessages.add(error);
      if (error == null) return true;
    }
    return false;
  }
}

class _Passcodes implements PasscodeService {
  String? pin;
  bool failClear = false;
  final saved = <(int, String)>[];
  final verified = <(int, String)>[];
  final cleared = <int>[];
  @override
  Future<bool> hasPasscode(int userId) async => pin != null;
  @override
  Future<void> setPasscode({
    required int userId,
    required String passcode,
  }) async {
    saved.add((userId, passcode));
    pin = passcode;
  }

  @override
  Future<bool> verifyPasscode({
    required int userId,
    required String passcode,
  }) async {
    verified.add((userId, passcode));
    return pin == passcode;
  }

  @override
  Future<void> clearPasscode(int userId) async {
    if (failClear) throw StateError('storage failed');
    cleared.add(userId);
    pin = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
