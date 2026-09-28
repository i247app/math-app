import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/auth_digit_box.dart';
import 'package:numi/features/auth/widgets/otp/otp_card.dart';

void main() {
  testWidgets('OTP boxes match PIN color until an error is shown', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    addTearDown(() {
      lingo.dispose();
      for (final controller in controllers) {
        controller.dispose();
      }
      for (final focusNode in focusNodes) {
        focusNode.dispose();
      }
    });

    for (final colors in [AppThemeColors.light, AppThemeColors.dark]) {
      for (final hasError in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: <ThemeExtension<dynamic>>[colors]),
            home: LingoScope(
              lingo: lingo,
              child: Scaffold(
                body: OtpCard(
                  controllers: controllers,
                  focusNodes: focusNodes,
                  onChanged: (_, _) {},
                  onEmptyBackspace: (_) {},
                  onConfirm: () {},
                  onResend: () {},
                  isVerifyingOtp: false,
                  resendCountdown: 30,
                  showResendCountdown: false,
                  errorText: hasError ? 'Invalid code' : null,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AuthDigitBox), findsNWidgets(4));
        for (var index = 0; index < 4; index++) {
          final box = find
              .descendant(
                of: find.byType(AuthDigitBox).at(index),
                matching: find.byType(Container),
              )
              .first;
          final decoration =
              tester.widget<Container>(box).decoration! as BoxDecoration;
          expect(
            decoration.border!.top.color,
            hasError ? colors.error : colors.passcodeBorder,
          );
        }
      }
    }
  });

  testWidgets('hides the resend countdown for OTP sent to a trusted device', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final controllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());
    addTearDown(() {
      lingo.dispose();
      for (final controller in controllers) {
        controller.dispose();
      }
      for (final focusNode in focusNodes) {
        focusNode.dispose();
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: Scaffold(
            body: OtpCard(
              controllers: controllers,
              focusNodes: focusNodes,
              onChanged: (_, _) {},
              onEmptyBackspace: (_) {},
              onConfirm: () {},
              onResend: () {},
              isVerifyingOtp: false,
              resendCountdown: 30,
              showResendCountdown: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Gửi lại mã sau 30 giây'), findsNothing);
    expect(find.text('Resend code in 30s'), findsNothing);
  });
}
