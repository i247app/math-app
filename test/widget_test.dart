import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi_flutter/features/onboarding/data/avatar_picker.dart';
import 'package:numi_flutter/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:numi_flutter/main.dart';

void main() {
  testWidgets('shows NUMI welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

    expect(find.text('NUMI'), findsOneWidget);
    expect(find.text('BẮT ĐẦU'), findsOneWidget);
  });

  testWidgets('opens OTP screen after phone verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.tap(find.text('Gửi mã OTP  →'));
    await tester.pumpAndSettle();

    expect(find.text('MÃ XÁC NHẬN'), findsOneWidget);
    expect(find.text('Xác nhận  →'), findsOneWidget);
  });

  testWidgets('supports US region and numeric-only phone entry',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

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

  testWidgets('opens child profile setup without OTP verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.tap(find.text('Gửi mã OTP  →'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xác nhận  →'));
    await tester.pumpAndSettle();

    expect(find.text('ẢNH ĐẠI DIỆN'), findsOneWidget);
    expect(find.text('Mẫu giáo'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(-900, 0));
    await tester.pumpAndSettle();
    expect(find.text('Lớp 5'), findsOneWidget);
    expect(find.text('Kết nối tri thức với cuộc sống'), findsOneWidget);
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
