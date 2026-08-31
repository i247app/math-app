import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/auth/presentation/device_verification_screen.dart';

void main() {
  testWidgets('shows trusted devices and sends to the selected device', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var selectedDeviceId = 4;
    var didSend = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: DeviceVerificationScreen(
            devices: const <AuthTrustedDevice>[
              AuthTrustedDevice(
                deviceId: 4,
                deviceName: 'TECNO SPARK Go 1',
                platform: 'android',
              ),
              AuthTrustedDevice(
                deviceId: 5,
                deviceName: 'iPad Pro',
                platform: 'ios',
              ),
            ],
            selectedDeviceId: selectedDeviceId,
            isLoading: false,
            isSending: false,
            onBack: () {},
            onRetry: () {},
            onSelectDevice: (deviceId) => selectedDeviceId = deviceId,
            onSend: () => didSend = true,
          ),
        ),
      ),
    );

    expect(find.text('Xác minh thiết bị mới'), findsOneWidget);
    expect(find.text('TECNO SPARK Go 1'), findsOneWidget);
    expect(find.text('iPad Pro'), findsOneWidget);

    await tester.tap(find.text('iPad Pro'));
    expect(selectedDeviceId, 5);

    await tester.ensureVisible(find.text('Gửi mã'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gửi mã'));
    expect(didSend, isTrue);
  });
}
