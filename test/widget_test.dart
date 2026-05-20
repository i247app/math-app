import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi_flutter/features/onboarding/data/avatar_picker.dart';
import 'package:numi_flutter/features/onboarding/data/otp_auth_api.dart';
import 'package:numi_flutter/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:numi_flutter/main.dart';

void main() {
  testWidgets('shows NUMI welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    expect(find.text('NUMI'), findsOneWidget);
    expect(find.text('BẮT ĐẦU'), findsOneWidget);
  });

  testWidgets('shows phone length error before enabling OTP button',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsNothing);

    await tester.enterText(find.byType(EditableText), '09012');
    await tester.pumpAndSettle();

    expect(find.text('Số điện thoại chưa đủ ký tự.'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsNothing);
  });

  testWidgets('opens OTP screen then home after successful phone login',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.pumpAndSettle();

    expect(find.text('MÃ XÁC NHẬN'), findsOneWidget);
    final otpDigits = '7152'.split('');
    for (var index = 0; index < otpDigits.length; index++) {
      final digit = otpDigits[index];
      await tester.enterText(find.byType(EditableText).at(index), digit);
    }
    await tester.tap(find.text('Xác nhận  →'));
    await tester.pumpAndSettle();

    expect(find.text('Home page'), findsOneWidget);
    expect(find.text('0901234567'), findsOneWidget);
  });

  testWidgets('supports US region and numeric-only phone entry',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Chọn quốc gia'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('US').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '202abc5550101');

    final editableText = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editableText.controller.text, '202 555 0101');
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('opens signup screen after OTP verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0999999999');
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký'), findsOneWidget);
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(find.text('MÃ XÁC NHẬN'), findsOneWidget);

    final otpDigits = '7152'.split('');
    for (var index = 0; index < otpDigits.length; index++) {
      await tester.enterText(
        find.byType(EditableText).at(index),
        otpDigits[index],
      );
    }
    await tester.tap(find.text('Xác nhận  →'));
    await tester.pumpAndSettle();

    expect(find.text('ẢNH ĐẠI DIỆN'), findsOneWidget);
    expect(find.textContaining('Username'), findsOneWidget);
    expect(find.textContaining('Email'), findsOneWidget);
    expect(find.text('Nhập tên của bé'), findsOneWidget);
    expect(find.text('Nhập email'), findsOneWidget);
  });

  test('updates avatar path after picking an image', () async {
    final cubit = OnboardingCubit(
      avatarPicker: const _FakeAvatarPickerService('/tmp/avatar.png'),
    );

    await cubit.pickAvatar();

    expect(cubit.state.avatarPath, '/tmp/avatar.png');
    expect(cubit.state.isPickingAvatar, isFalse);
    await cubit.close();
  });
}

class _FakeAvatarPickerService extends AvatarPickerService {
  const _FakeAvatarPickerService(this.path);

  final String? path;

  @override
  Future<String?> pickAvatarPath() async => path;
}

class _FakeOtpAuthService implements OtpAuthService {
  @override
  Future<PhoneCheckResult> checkPhone(String phone) async {
    return PhoneCheckResult(phone: phone, exists: true, userId: 'user-1');
  }

  @override
  Future<AuthPhoneLookupResult> checkAuthPhone(String phone) async {
    if (phone == '0999999999') {
      return AuthPhoneLookupResult(phone: phone, exists: false);
    }

    return AuthPhoneLookupResult(
      phone: phone,
      exists: true,
      user: LoginUser(id: 'user-1', phone: phone),
    );
  }

  @override
  Future<LoginUser> loginWithPhone(String phone) async {
    if (phone == '0999999999') {
      throw const OtpAuthException('User not found', status: 202);
    }

    return LoginUser(id: 'user-1', phone: phone);
  }

  @override
  Future<LoginUser> signupWithPhone({
    required String phone,
    required String name,
    String? email,
    String? avatarPath,
  }) async {
    return LoginUser(
      id: 'user-register-1',
      name: name,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<SendOtpResult> sendLoginOtp(String phone) async {
    return const SendOtpResult(
      expiresIn: 180,
      otpId: 'otp-1',
      otpCode: '7152',
      purpose: 'login',
    );
  }

  @override
  Future<SendOtpResult> sendRegisterOtp(String phone) async {
    return const SendOtpResult(
      expiresIn: 180,
      otpId: 'otp-register-1',
      otpCode: '7152',
      purpose: 'register',
    );
  }

  @override
  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
    String otpType = loginOtpType,
  }) async {
    return VerifyOtpResult(
      isValid: otpCode == '7152',
      user: otpCode == '7152' && otpType == loginOtpType
          ? const LoginUser(id: 'user-1', phone: '0901234567')
          : null,
    );
  }
}
