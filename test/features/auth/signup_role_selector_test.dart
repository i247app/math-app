import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/widgets/signup/signup_role_card.dart';
import 'package:numi/features/auth/widgets/signup/signup_role_selector.dart';

void main() {
  testWidgets('parent appears before student and both select the right role', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    SignupRole? selectedRole;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: Scaffold(
            body: SignupRoleSelector(
              value: null,
              onChanged: (role) => selectedRole = role,
            ),
          ),
        ),
      ),
    );

    final cards = find.byType(SignupRoleCard);
    expect(cards, findsNWidgets(2));
    expect(
      tester.widget<SignupRoleCard>(cards.at(0)).imagePath,
      'assets/icons/parent-role.png',
    );
    expect(
      tester.widget<SignupRoleCard>(cards.at(1)).imagePath,
      'assets/icons/student-role.png',
    );
    expect(
      tester.getTopLeft(cards.at(0)).dx,
      lessThan(tester.getTopLeft(cards.at(1)).dx),
    );

    await tester.tap(cards.at(0));
    expect(selectedRole, SignupRole.parent);
    await tester.tap(cards.at(1));
    expect(selectedRole, SignupRole.student);
  });
}
