import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/exam_attempt_screen.dart';
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

  testWidgets('refresh scrolls without sharing a controller position', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final examService = _FakeExamService();

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: examService,
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(grade: 2, level: 3),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester.state<ScrollableState>(find.byType(Scrollable)).position.jumpTo(0);
    await tester.pump();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(examService.statsRequests, 2);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('grade-roadmap-level-3')), findsOneWidget);
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

  testWidgets('selected grade shows its highest level from GRADE stats', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final service = _FakeExamService(
      stats: const <ExamStats>[
        ExamStats(
          correctNumber: 8,
          scorePercentage: 80,
          skippedNumber: 0,
          totalQuestions: 10,
          examType: examTypeGrade,
          status: 'COMPLETE',
          grade: 1,
          level: 4,
        ),
        ExamStats(
          correctNumber: 8,
          scorePercentage: 80,
          skippedNumber: 0,
          totalQuestions: 10,
          examType: examTypeGrade,
          status: 'COMPLETE',
          grade: 1,
          level: 7,
        ),
        ExamStats(
          correctNumber: 8,
          scorePercentage: 80,
          skippedNumber: 0,
          totalQuestions: 10,
          examType: examTypeGrade,
          status: 'COMPLETE',
          grade: 2,
          level: 3,
        ),
        ExamStats(
          correctNumber: 0,
          scorePercentage: 0,
          skippedNumber: 0,
          totalQuestions: 10,
          examType: examTypeGrade,
          status: 'CANCEL',
          grade: 3,
          level: 8,
        ),
        ExamStats(
          correctNumber: 10,
          scorePercentage: 100,
          skippedNumber: 0,
          totalQuestions: 10,
          examType: examTypePractice,
          status: 'COMPLETE',
          grade: 2,
          level: 10,
        ),
      ],
    );

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            initialGrade: 1,
            examService: service,
            initialGrades: const <GradeModel>[
              GradeModel(id: 1, label: 'Lớp 1'),
              GradeModel(id: 2, label: 'Lớp 2'),
              GradeModel(id: 3, label: 'Lớp 3'),
            ],
            gradeService: _UnusedGradeService(),
            gradeProgressStore: const _FakeProgressStore(
              ProfileGradeProgress(grade: 1, level: 2),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(service.requestedStatsExamType, examTypeGrade);
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byKey(const ValueKey('grade-roadmap-level-7')),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      1.04,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-8-locked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-6-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-7-completed')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('grade-roadmap-grade-pill')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('grade-card-assets/icons/2.svg')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byKey(const ValueKey('grade-roadmap-level-3')),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      1.04,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-4-locked')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-1-completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-2-completed')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('grade-roadmap-grade-pill')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('grade-card-assets/icons/3.svg')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-1-locked')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-2-locked')),
      findsOneWidget,
    );
  });

  for (var grade = 0; grade <= 5; grade++) {
    testWidgets('grade $grade starts with level 1 unlocked', (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      final service = _FakeExamService();

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: GradeRoadmapScreen(
              profileId: 11,
              initialGrade: grade,
              examService: service,
              gradeProgressStore: const _FakeProgressStore(
                ProfileGradeProgress.initial,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.requestedStatsExamType, examTypeGrade);
      expect(
        find.byKey(ValueKey('grade-roadmap-grade-title-$grade')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('grade-roadmap-level-1-locked')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('grade-roadmap-level-2-locked')),
        findsOneWidget,
      );
    });
  }

  testWidgets('ticks earlier levels even without a passing attempt', (
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
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grade-roadmap-level-3-completed')),
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

    expect(find.byType(ExamAttemptScreen), findsOneWidget);
    final assessment = tester.widget<ExamAttemptScreen>(
      find.byType(ExamAttemptScreen),
    );
    expect(assessment.examType, examTypeGrade);
    expect(assessment.level, 1);
  });

  testWidgets('a completed historical level generates that level again', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final service = _FakeExamService();

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: service,
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

    expect(find.byType(ExamAttemptScreen), findsOneWidget);
    expect(service.generatedLevels, <int?>[1]);
    expect(service.generatedExamTypes, <String>[examTypeGrade]);
  });

  testWidgets('a skipped unlocked level generates its own grade exam', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final service = _FakeExamService();

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: GradeRoadmapScreen(
            profileId: 11,
            examService: service,
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

    expect(find.byType(ExamAttemptScreen), findsOneWidget);
    expect(service.generatedLevels, <int?>[2]);
    expect(service.generatedExamTypes, <String>[examTypeGrade]);
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
  _FakeExamService({this.stats = const <ExamStats>[]});

  final List<ExamStats> stats;
  int statsRequests = 0;
  String? requestedStatsExamType;
  final List<int?> generatedLevels = <int?>[];
  final List<String> generatedExamTypes = <String>[];

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    generatedLevels.add(level);
    generatedExamTypes.add(examType);
    return GeneratedExam(
      examId: 500,
      userAiExamId: 500,
      userExamId: 600,
      examType: examType,
      grade: 2,
      level: level,
      questions: const <ExamQuestion>[
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
  }

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
  }) async {
    statsRequests++;
    requestedStatsExamType = examType;
    return stats;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
