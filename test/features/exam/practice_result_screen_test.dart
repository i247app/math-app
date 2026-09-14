import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/practice_result_screen.dart';

void main() {
  testWidgets('shows first-attempt score and regenerates the same grade', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final service = _RecordingPracticeService();
    GeneratedExam? generatedExam;
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
            correctAnswers: 2,
            totalQuestions: 6,
            examService: service,
            profileId: 21,
            userExamId: 99,
            onPracticeAgainGenerated: (exam) => generatedExam = exam,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('2/6'), findsOneWidget);
    expect(find.text('Đúng'), findsOneWidget);
    expect(find.text('LỚP 3'), findsNothing);
    expect(find.text('Luyện tập lại'), findsOneWidget);

    await tester.tap(find.text('Luyện tập lại'));
    await tester.pump();

    expect(service.requestedExamType, examTypePractice);
    expect(service.requestedGradeLabel, 'Lớp 3');
    expect(service.requestedProfileId, 21);
    expect(service.requestedUserExamId, 99);
    expect(generatedExam?.examType, examTypePractice);
    expect(generatedExam?.grade, 3);
    expect(tester.takeException(), isNull);
  });

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
  String? requestedExamType;
  String? requestedGradeLabel;
  int? requestedProfileId;
  int? requestedUserExamId;
  int? completedUserExamId;
  String? completedStatus;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
    int? userExamId,
  }) async {
    requestedExamType = examType;
    requestedGradeLabel = gradeLabel;
    requestedProfileId = profileId;
    requestedUserExamId = userExamId;
    return const GeneratedExam(
      examId: 301,
      examType: examTypePractice,
      grade: 3,
      questions: <ExamQuestion>[
        ExamQuestion(
          questionName: '2 + 2 = ?',
          questionNumber: 1,
          rightAnswer: 'A',
          answers: <ExamAnswer>[
            ExamAnswer(label: 'A', content: '4'),
            ExamAnswer(label: 'B', content: '5'),
          ],
        ),
      ],
    );
  }

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
