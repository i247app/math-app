import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/exam_review_entry_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/models/grade.dart';

void main() {
  testWidgets('shows ten levels and places the mascot at the current level', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(
                grade: 2,
                level: 3,
                highestUnlockedGrade: 2,
                highestUnlockedLevel: 4,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LỚP 2'), findsOneWidget);
    for (var level = 1; level <= 10; level++) {
      expect(
        find.byKey(ValueKey('grade-roadmap-level-$level')),
        findsOneWidget,
      );
    }
    expect(
      find.image(const AssetImage('assets/images/grade-roadmap-mascot.png')),
      findsOneWidget,
    );

    final levelColors = <Color>{};
    for (var level = 1; level <= 10; level++) {
      final button = tester.widget<DecoratedBox>(
        find.byKey(ValueKey('grade-roadmap-level-$level-button')),
      );
      final decoration = button.decoration as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      levelColors.add(gradient.colors.last);
    }
    expect(levelColors, hasLength(10));
  });

  testWidgets('grade pill opens grade selection and swipes stay disabled', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            initialGrades: const <GradeModel>[
              GradeModel(id: 1, label: 'Lớp 1'),
              GradeModel(id: 2, label: 'Lớp 2'),
              GradeModel(id: 3, label: 'Lớp 3'),
            ],
            gradeService: _UnusedGradeService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(
                grade: 2,
                level: 3,
                highestUnlockedGrade: 2,
                highestUnlockedLevel: 4,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LỚP 2'), findsOneWidget);

    await tester.drag(find.byType(GradeRoadmapScreen), const Offset(-180, 0));
    await tester.pumpAndSettle();

    expect(find.text('LỚP 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('grade-roadmap-grade-pill')));
    await tester.pumpAndSettle();

    expect(find.byType(GradeSelectionScreen), findsOneWidget);
    final gradeSelection = tester.widget<GradeSelectionScreen>(
      find.byType(GradeSelectionScreen),
    );
    expect(gradeSelection.examType, examTypeGrade);
    expect(gradeSelection.profileId, 11);
    expect(gradeSelection.initialGradeLabel, 'Lớp 2');
    expect(gradeSelection.selectionOnly, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('grade-card-assets/icons/3.svg')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GradeSelectionScreen), findsNothing);
    expect(find.byType(GradeRoadmapScreen), findsOneWidget);
    expect(find.text('LỚP 3'), findsOneWidget);
  });

  testWidgets('shows completed badge only for a passed attempt', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(grade: 1, level: 3),
            ),
            initialExams: const <GeneratedExam>[
              GeneratedExam(
                userExamId: 100,
                examStatus: 'COMPLETE',
                examType: examTypeGrade,
                grade: 1,
                level: 1,
                grading: ExamGrading(scorePercentage: 70),
                questions: <ExamQuestion>[],
              ),
              GeneratedExam(
                userExamId: 101,
                examStatus: 'COMPLETE',
                examType: examTypeGrade,
                grade: 1,
                level: 2,
                grading: ExamGrading(scorePercentage: 40),
                questions: <ExamQuestion>[],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('grade-roadmap-level-1-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-2-completed')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-2-button')),
      findsOneWidget,
    );
  });

  testWidgets('an unlocked historical level can be attempted again', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(
                grade: 2,
                level: 3,
                highestUnlockedGrade: 2,
                highestUnlockedLevel: 3,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final historicalLevel = find.byKey(const ValueKey('grade-roadmap-level-1'));
    await tester.ensureVisible(historicalLevel);
    await tester.pumpAndSettle();
    await tester.tap(historicalLevel);
    await tester.pumpAndSettle();

    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    final assessment = tester.widget<AiAssessmentScreen>(
      find.byType(AiAssessmentScreen),
    );
    expect(assessment.examType, examTypeGrade);
    expect(assessment.level, 1);
  });

  testWidgets('a completed historical level opens review instead of generate', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(grade: 2, level: 3),
            ),
            initialExams: const <GeneratedExam>[
              GeneratedExam(
                userExamId: 600,
                examStatus: 'COMPLETE',
                examType: examTypeGrade,
                grade: 2,
                level: 1,
                grading: ExamGrading(scorePercentage: 70),
                questions: <ExamQuestion>[],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final completedLevel = find.byKey(const ValueKey('grade-roadmap-level-1'));
    await tester.ensureVisible(completedLevel);
    await tester.pumpAndSettle();
    await tester.tap(completedLevel);
    await tester.pumpAndSettle();

    expect(find.byType(ExamReviewScreen), findsOneWidget);
    expect(find.byType(AiAssessmentScreen), findsNothing);
  });

  testWidgets('a skipped jump level opens the jump source review', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: _FakeExamService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(grade: 2, level: 3),
            ),
            initialExams: const <GeneratedExam>[
              GeneratedExam(
                userExamId: 600,
                examStatus: 'COMPLETE',
                examType: examTypeGrade,
                grade: 2,
                level: 1,
                grading: ExamGrading(scorePercentage: 100),
                questions: <ExamQuestion>[],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final skippedLevel = find.byKey(const ValueKey('grade-roadmap-level-2'));
    await tester.ensureVisible(skippedLevel);
    await tester.pumpAndSettle();
    await tester.tap(skippedLevel);
    await tester.pumpAndSettle();

    expect(find.byType(ExamReviewScreen), findsOneWidget);
    final review = tester.widget<ExamReviewScreen>(
      find.byType(ExamReviewScreen),
    );
    expect(review.userExamId, 600);
    expect(find.byType(AiAssessmentScreen), findsNothing);
  });
}

class _UnusedGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) {
    throw StateError('The initial grade list should be used by this test.');
  }
}

class _FakeProgressStore implements ProfileGradeProgressStore {
  const _FakeProgressStore(this.progress);

  final ProfileGradeProgress progress;

  @override
  Future<ProfileGradeProgress> read(int profileId) async => progress;

  @override
  Future<void> save(int profileId, ProfileGradeProgress progress) async {}

  @override
  Future<ProfileGradeProgress> saveIfHigher(
    int profileId,
    ProfileGradeProgress progress,
  ) async => progress;
}

class _FakeExamService implements ExamService {
  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async => const GeneratedExam(
    examId: 500,
    userAiExamId: 500,
    userExamId: 600,
    examType: examTypeGrade,
    grade: 2,
    level: 1,
    questions: <ExamQuestion>[
      ExamQuestion(
        questionName: '1 + 1 = ?',
        questionNumber: 1,
        rightAnswer: 'A',
        answers: <ExamAnswer>[
          ExamAnswer(label: 'A', content: '2'),
          ExamAnswer(label: 'B', content: '3'),
        ],
      ),
    ],
  );

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  }) async => const GeneratedExam(
    userExamId: 600,
    examStatus: 'COMPLETE',
    examType: examTypeGrade,
    grade: 2,
    level: 1,
    grading: ExamGrading(
      correctNumber: 1,
      totalQuestions: 1,
      scorePercentage: 100,
    ),
    questions: <ExamQuestion>[
      ExamQuestion(
        questionName: '1 + 1 = ?',
        questionNumber: 1,
        rightAnswer: 'A',
        answers: <ExamAnswer>[
          ExamAnswer(label: 'A', content: '2'),
          ExamAnswer(label: 'B', content: '3'),
        ],
      ),
    ],
  );

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async => const <ExamStats>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
