import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_select_student_card.dart';
import 'package:numi/features/classroom/presentation/tabs/parent_room_tab.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';
import 'package:numi/features/home/widgets/home_missing_student_dialog.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  testWidgets('room empty state uses the no-profile mascot and both actions', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ParentRoomSelectStudentCard(
              onChooseProfile: () {},
              onCreateProfile: () {},
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, parentNoStudentMascotAsset);
    expect(find.text('Chưa có hồ sơ'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Chọn hồ sơ'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Tạo hồ sơ'), findsOneWidget);
  });

  testWidgets('room hides its header when no child profile exists', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ParentRoomTab(
              user: null,
              profiles: const [],
              activeProfile: null,
              isActive: true,
              activeRefreshTick: 0,
              assignmentService: _UnusedAssignmentService(),
              onRefreshProfiles: () async {},
              onActivateProfile: (_) async {},
              onProfileSaved: () {},
              onOpenClassroomTab: () {},
              onOpenProfileMenu: () {},
              bottomPadding: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(PageHeader), findsNothing);
    expect(find.byType(ParentRoomSelectStudentCard), findsOneWidget);
  });

  testWidgets('parent home automatically offers profile creation only once', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var dialogShownCount = 0;

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ParentHomeContent(
              user: null,
              profiles: const [],
              activeProfile: null,
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const [],
              gradeService: _UnusedGradeService(),
              quizService: _UnusedQuizService(),
              onRefreshProfiles: () async {},
              onActivateProfile: (_) async {},
              onProfileSaved: () {},
              onOpenProfileMenu: () {},
              onOpenClassroomTab: () {},
              onOpenPracticeTab: () {},
              onParentAssessmentStateChanged: (_) {},
              bottomPadding: 0,
              showChildProfileDialogOnStart: true,
              onChildProfileDialogShown: () => dialogShownCount++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(HomeMissingStudentDialog), findsOneWidget);
    expect(find.text('Tạo hồ sơ ngay'), findsOneWidget);
    expect(dialogShownCount, 1);

    await tester.ensureVisible(find.text('Để sau'));
    await tester.pump();
    await tester.tap(find.text('Để sau'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeMissingStudentDialog), findsNothing);

    await tester.pump();
    expect(find.byType(HomeMissingStudentDialog), findsNothing);
    expect(dialogShownCount, 1);
  });

  testWidgets('ordinary parent home does not automatically show the dialog', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ParentHomeContent(
              user: null,
              profiles: const [],
              activeProfile: null,
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const [],
              gradeService: _UnusedGradeService(),
              quizService: _UnusedQuizService(),
              onRefreshProfiles: () async {},
              onActivateProfile: (_) async {},
              onProfileSaved: () {},
              onOpenProfileMenu: () {},
              onOpenClassroomTab: () {},
              onOpenPracticeTab: () {},
              onParentAssessmentStateChanged: (_) {},
              bottomPadding: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(HomeMissingStudentDialog), findsNothing);
  });
}

class _UnusedGradeService implements GradeService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedQuizService implements QuizService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAssignmentService implements ClassroomExerciseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
