import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/parent_assessment_display_helpers.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_score_badge.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

void main() {
  testWidgets('grade badge is a full ring with a distinct grade color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ParentAssessmentScoreBadge(grade: 3)),
    );

    final ring = tester.widget<ScoreProgressRing>(
      find.byType(ScoreProgressRing),
    );
    expect(ring.progress, 1);
    expect(ring.color, AppColors.grade3);
    expect(ring.trackColor, AppColors.grade3);
    expect(find.text('3'), findsOneWidget);

    final gradeColors = <Color>{
      for (var grade = 0; grade <= 5; grade++)
        parentAssessmentGradeColor(grade),
    };
    expect(gradeColors, hasLength(6));
  });

  testWidgets('ASSESSMENT item title is formatted from grade', (tester) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: Builder(
            builder: (context) => Column(
              children: <Widget>[
                Text(
                  homeExamTitle(
                    context,
                    const GeneratedExam(
                      examType: examTypeAssessment,
                      title: 'Server kindergarten title',
                      grade: 0,
                      questions: <ExamQuestion>[],
                    ),
                  ),
                ),
                Text(
                  homeExamTitle(
                    context,
                    const GeneratedExam(
                      examType: examTypeAssessment,
                      title: 'Server grade title',
                      grade: 1,
                      questions: <ExamQuestion>[],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Toán Đánh Giá - Mẫu Giáo'), findsOneWidget);
    expect(find.text('Toán Đánh Giá - Lớp 1'), findsOneWidget);
    expect(find.text('Server kindergarten title'), findsNothing);
    expect(find.text('Server grade title'), findsNothing);

    await lingo.setLanguage(AppLanguage.en);
    await tester.pump();

    expect(find.text('Math Assessment - Kindergarten'), findsOneWidget);
    expect(find.text('Math Assessment - Grade 1'), findsOneWidget);
  });

  testWidgets('GRADE item title uses its grade and level', (tester) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: Builder(
            builder: (context) => Text(
              homeExamTitle(
                context,
                const GeneratedExam(
                  examType: examTypeGrade,
                  title: 'Server title',
                  grade: 3,
                  level: 7,
                  questions: <ExamQuestion>[],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Bài kiểm tra Level 3.7'), findsOneWidget);
    expect(find.text('Server title'), findsNothing);

    await lingo.setLanguage(AppLanguage.en);
    await tester.pump();

    expect(find.text('Level test 3.7'), findsOneWidget);
  });

  test(
    'successful empty profile response does not fall back to user id',
    () async {
      final service = _RecordingExamService();

      final result = await loadCompletedParentAssessments(
        examService: service,
        profileId: 42,
        userId: 7,
        page: 1,
        size: 5,
      );

      expect(result.exams, isEmpty);
      expect(service.requests, const <_ExamRequest>[
        _ExamRequest(profileId: 42),
      ]);
    },
  );
}

class _RecordingExamService implements ExamService {
  final List<_ExamRequest> requests = <_ExamRequest>[];

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    requests.add(_ExamRequest(userId: userId, profileId: profileId));
    return const ExamListResponse(mstatus: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExamRequest {
  const _ExamRequest({this.userId, this.profileId});

  final int? userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return other is _ExamRequest &&
        other.userId == userId &&
        other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(userId, profileId);
}
