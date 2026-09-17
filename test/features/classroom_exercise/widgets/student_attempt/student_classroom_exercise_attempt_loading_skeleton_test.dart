import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_loading_skeleton.dart';

void main() {
  testWidgets('does not overflow on a short screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              height: 587,
              child: StudentClassroomExerciseAttemptLoadingSkeleton(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
