import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/screens/signup_with_phone.dart';

class _PhoneAuthService implements AuthService {
  _PhoneAuthService(this.response);

  final Map<String, dynamic> response;
  String? checkedPhone;
  String? sentOtpPhone;
  AuthOtpKind? sentOtpKind;

  @override
  Future<dynamic> checkIdentifier(String identifier) async {
    checkedPhone = identifier;
    return response;
  }

  @override
  Future<SendOtpResult> sendOtp({
    required String loginName,
    required AuthOtpKind kind,
    int? userId,
    int? targetDeviceId,
  }) async {
    sentOtpPhone = loginName;
    sentOtpKind = kind;
    return const SendOtpResult(expiresIn: 30);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  Future<void> showPhoneScreen(
    WidgetTester tester,
    _PhoneAuthService service,
    LingoProvider lingo,
    ValueChanged<String> onOtpSent,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: SignupWithPhone(
            onBack: () {},
            authService: service,
            onOtpSent: onOtpSent,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0702465814');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
  }

  testWidgets('phone signup sends OTP when enabled', (tester) async {
    final service = _PhoneAuthService(<String, dynamic>{
      'mstatus': 200,
      'email_otp_enable': false,
      'phone_otp_enable': true,
    });
    final lingo = LingoProvider();
    String? readyPhone;

    await showPhoneScreen(
      tester,
      service,
      lingo,
      (phone) => readyPhone = phone,
    );

    expect(service.checkedPhone, '+84702465814');
    expect(service.sentOtpPhone, '+84702465814');
    expect(service.sentOtpKind, AuthOtpKind.signup);
    expect(readyPhone, '+84702465814');
  });

  testWidgets('registered phone shows an inline error without sending OTP', (
    tester,
  ) async {
    final service = _PhoneAuthService(<String, dynamic>{'mstatus': 4206});
    final lingo = LingoProvider();
    String? readyPhone;

    await showPhoneScreen(
      tester,
      service,
      lingo,
      (phone) => readyPhone = phone,
    );

    expect(
      find.text(lingo.lookup(AppKeys.signupPhoneAlreadyRegistered)),
      findsOneWidget,
    );
    expect(service.sentOtpPhone, isNull);
    expect(readyPhone, isNull);
  });

  testWidgets('disabled phone OTP stays on the phone screen', (tester) async {
    final service = _PhoneAuthService(<String, dynamic>{
      'mstatus': 200,
      'phone_otp_enable': false,
      'email_otp_enable': true,
    });
    final lingo = LingoProvider();
    String? readyPhone;

    await showPhoneScreen(
      tester,
      service,
      lingo,
      (phone) => readyPhone = phone,
    );

    expect(
      find.text(lingo.lookup(AppKeys.signupOtpUnavailable)),
      findsOneWidget,
    );
    expect(service.sentOtpPhone, isNull);
    expect(readyPhone, isNull);
  });
}
