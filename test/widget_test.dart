import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/main.dart';

void main() {
  group('authentication entry characterization', () {
    testWidgets('starts on the welcome screen', (tester) async {
      await tester.pumpWidget(const NumiApp());

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
      expect(find.text('NUMI'), findsOneWidget);
    });

    testWidgets('continues from welcome details to the signup login entry', (
      tester,
    ) async {
      await tester.pumpWidget(const NumiApp());

      await tester.tap(find.text('BẮT ĐẦU'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('welcome-details')), findsOneWidget);

      await tester.tap(find.text('BẮT ĐẦU'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(find.text('ĐĂNG KÝ'), findsAtLeastNWidgets(1));
    });

    testWidgets('opens the login entry directly from welcome', (tester) async {
      await tester.pumpWidget(const NumiApp());

      await tester.tap(find.text('ĐĂNG NHẬP'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(find.text('Đăng nhập'), findsAtLeastNWidgets(1));
    });
  });
}
