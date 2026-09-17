import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/practice_result_screen.dart';

void main() {
  testWidgets('closing practice does not update assessment status', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _RecordingPracticeService();
    var didClose = false;
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: PracticeResultScreen(
            grade: 3,
            correctAnswers: 4,
            totalQuestions: 6,
            examService: service,
            profileId: 21,
            userExamId: 99,
            onBack: () => didClose = true,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('practice-result-close')));
    await tester.pump();

    expect(service.completedUserExamId, isNull);
    expect(service.completedStatus, isNull);
    expect(didClose, isTrue);
    expect(tester.takeException(), isNull);
  });
}

class _RecordingPracticeService implements ExamService {
  int? completedUserExamId;
  String? completedStatus;

  @override
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {
    completedUserExamId = userExamId;
    completedStatus = status;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
