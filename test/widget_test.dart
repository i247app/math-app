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

    expect(find.text('Đăng nhập'), findsOneWidget);
    await tester.tap(find.text('Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mã OTP vừa gửi: 7152'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
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

  testWidgets('opens child profile setup after OTP verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: _FakeOtpAuthService()));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0999999999');
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký'), findsOneWidget);
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();

    expect(
      find.text('Số điện thoại này chưa tồn tại trong hệ thống NUMI.'),
      findsOneWidget,
    );
    expect(find.text('0999999999'), findsOneWidget);
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();

    for (var index = 0; index < 4; index++) {
      await tester.enterText(
        find.byType(EditableText).at(index),
        '9',
      );
    }
    await tester.tap(find.text('Xác nhận  →'));
    await tester.pumpAndSettle();

    expect(find.text('ẢNH ĐẠI DIỆN'), findsOneWidget);
    expect(find.text('Mẫu giáo'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(-900, 0));
    await tester.pumpAndSettle();
    expect(find.text('Lớp 5'), findsOneWidget);
    expect(find.text('Kết nối tri thức'), findsOneWidget);
    expect(find.text('Chân trời sáng tạo'), findsOneWidget);
    expect(find.text('Cánh Diều'), findsOneWidget);
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
  Future<SendOtpResult> sendLoginOtp(String phone) async {
    return const SendOtpResult(
      expiresIn: 180,
      otpId: 'otp-1',
      otpCode: '7152',
      purpose: 'login',
    );
  }

  @override
  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  }) async {
    return VerifyOtpResult(
      isValid: otpCode == '7152',
      user: otpCode == '7152'
          ? const LoginUser(id: 'user-1', phone: '0901234567')
          : null,
    );
  }
}
