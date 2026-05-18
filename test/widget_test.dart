import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi_flutter/features/onboarding/data/avatar_picker.dart';
import 'package:numi_flutter/features/onboarding/data/otp_auth_api.dart';
import 'package:numi_flutter/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:numi_flutter/main.dart';

void main() {
  final authService = _FakeOtpAuthService();

  testWidgets('shows NUMI welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: authService));

    expect(find.text('NUMI'), findsOneWidget);
    expect(find.text('BẮT ĐẦU'), findsOneWidget);
  });

  testWidgets('opens OTP screen after phone verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: authService));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.tap(find.text('Gửi mã OTP  →'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mã OTP vừa gửi: 1234'), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    expect(find.text('MÃ XÁC NHẬN'), findsOneWidget);
    expect(find.text('Xác nhận  →'), findsOneWidget);
  });

  testWidgets('supports US region and numeric-only phone entry',
      (WidgetTester tester) async {
    await tester.pumpWidget(NumiApp(authService: authService));

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
    await tester.pumpWidget(NumiApp(authService: authService));

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.tap(find.text('Gửi mã OTP  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    for (var index = 0; index < 4; index++) {
      await tester.enterText(
        find.byType(EditableText).at(index),
        '${index + 1}',
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
  Future<SendOtpResult> sendLoginOtp(String phone) async {
    return const SendOtpResult(
      expiresIn: 180,
      otpId: 'otp-1',
      otpCode: '1234',
      purpose: 'login',
    );
  }

  @override
  Future<VerifyOtpResult> verifyLoginOtp({
    required String phone,
    required String otpCode,
  }) async {
    return VerifyOtpResult(
      isValid: otpCode == '1234',
      user: otpCode == '1234'
          ? const LoginUser(id: 'user-1', phone: '0901234567')
          : null,
    );
  }
}
