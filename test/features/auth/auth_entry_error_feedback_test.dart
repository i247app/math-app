import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_card.dart';

void main() {
  for (final mode in AuthEntryMode.values) {
    for (final reducedMotion in [false, true]) {
      testWidgets(
        '$mode error feedback resets and repeats (reduced=$reducedMotion)',
        (tester) async {
          final controller = TextEditingController(text: 'invalid@example');
          final lingo = LingoProvider();
          addTearDown(controller.dispose);
          addTearDown(lingo.dispose);
          String? error;
          var fail = true;
          await tester.pumpWidget(
            LingoScope(
              lingo: lingo,
              child: MaterialApp(
                theme: ThemeData(extensions: const [AppThemeColors.light]),
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(disableAnimations: reducedMotion),
                    child: StatefulBuilder(
                      builder: (context, update) => AuthEntryCard(
                        controller: controller,
                        region: PhoneRegion.vn,
                        mode: mode,
                        showPhoneRegion: false,
                        onRegionChanged: (_) {},
                        onSubmitIdentifier: () =>
                            update(() => error = fail ? 'Invalid input' : null),
                        actionLabel: 'Confirm',
                        isSubmitting: false,
                        isCheckingIdentifier: false,
                        canSubmit: true,
                        canLoginWithPin: false,
                        onLoginWithPin: () {},
                        onIdentifierChanged: (_) => update(() => error = null),
                        identifierErrorText: error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          Color border() =>
              (tester
                          .widget<Container>(
                            find.byKey(const ValueKey('auth-identifier-box')),
                          )
                          .decoration!
                      as BoxDecoration)
                  .border!
                  .top
                  .color;
          double offset() => tester
              .widget<Transform>(
                find.byKey(const ValueKey('auth-identifier-shake')),
              )
              .transform
              .storage[12];
          final normal = border();
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          expect(border(), AppThemeColors.light.error);
          expect(offset(), reducedMotion ? 0 : isNot(0));
          expect(controller.text, 'invalid@example');
          await tester.pumpAndSettle();
          expect(border(), normal);
          expect(offset(), 0);
          expect(find.text('Invalid input'), findsOneWidget);

          // The same error on another submit must replay without a new message.
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          expect(border(), AppThemeColors.light.error);
          await tester.enterText(find.byType(TextField), 'valid@example.com');
          await tester.pump();
          expect(border(), normal);
          fail = false;
          await tester.tap(find.byType(ElevatedButton));
          await tester.pumpAndSettle();
          expect(border(), normal);
          expect(find.text('Invalid input'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
