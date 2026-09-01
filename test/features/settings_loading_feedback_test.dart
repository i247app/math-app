import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/profile/presentation/widgets/list/profile_radio.dart';
import 'package:numi/features/settings/presentation/widgets/account/settings_save_button.dart';

void main() {
  testWidgets('save button keeps loading feedback inside the action', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SettingsSaveButton(isLoading: true, onTap: () => tapCount++),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
    await tester.tap(find.byType(SettingsSaveButton));
    expect(tapCount, 0);
  });

  testWidgets('switching profile replaces only its radio with a spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ProfileRadio(isActive: false, isLoading: true),
        ),
      ),
    );

    expect(find.byType(ProfileRadio), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
