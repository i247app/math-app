import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/main.dart';

void main() {
  group('authentication entry characterization', () {
    testWidgets('starts on the welcome screen', (tester) async {
      await tester.pumpWidget(const NumiApp());

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
    });

    testWidgets(
      'reveals the phone region for digits and delays email errors until submit',
      (tester) async {
        FlutterSecureStorage.setMockInitialValues(<String, String>{});
        await tester.pumpWidget(const NumiApp());

        final welcomeLogin = find.text('ĐĂNG NHẬP');
        await tester.ensureVisible(welcomeLogin);
        await tester.tap(welcomeLogin);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login')), findsOneWidget);
        expect(find.text('🇻🇳'), findsNothing);

        final input = find.byType(EditableText);
        await tester.enterText(input, 'learner');
        await tester.pump();

        expect(find.text('🇻🇳'), findsNothing);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);

        final submitButton = find.byType(ElevatedButton);
        expect(
          tester.widget<ElevatedButton>(submitButton).onPressed,
          isNotNull,
        );

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);

        await tester.enterText(input, '090');
        await tester.pumpAndSettle();

        expect(find.text('🇻🇳'), findsOneWidget);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);
      },
    );
  });
}
