import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/otp/otp_card.dart';

void main() {
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
