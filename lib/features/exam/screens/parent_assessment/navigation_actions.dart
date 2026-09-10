part of '../parent_assessment_tab.dart';

extension _ParentAssessmentNavigationActions on _ParentAssessmentTabState {
  List<ParentAssessmentEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _entries;
    }
    return _allEntries
        .where((entry) {
          final searchable = <String>[
            homeExamTitle(context, entry.exam),
            homeExamDateLabel(entry.exam),
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  void _openExamReview(GeneratedExam exam) {
    final examId = exam.examId ?? exam.id;
    if (examId == null || examId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamReviewScreen(examId: examId, initialExam: exam),
      ),
    );
  }

  void _openLearningProgress() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LearningProgressScreen(
          profileId: profileStableId(widget.activeProfile),
          examService: widget.examService,
          initialEntries: List<ParentAssessmentEntry>.unmodifiable(_allEntries),
        ),
      ),
    );
  }

  Future<void> _openFakeAssessment() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    final fakeExamService = FakeAssessmentExamService(
      delegate: widget.examService,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiAssessmentScreen(
          examService: fakeExamService,
          purpose: examPurposeAssessment,
          typeOfExam: examTypeGeneral,
          gradeLabel: widget.activeProfile?.grade?.label,
          profileId: profileStableId(widget.activeProfile),
          allowQuestionNavigation: false,
          onResultBack: () {
            if (!mounted) {
              return;
            }
            final navigator = Navigator.of(context);
            if (assessmentTabRoute == null) {
              navigator.popUntil((route) => route.isFirst);
              return;
            }
            navigator.popUntil((route) => identical(route, assessmentTabRoute));
          },
        ),
      ),
    );
    if (mounted) {
      await _loadAssessments(forceRefresh: true, page: 1);
    }
  }

  Future<void> _openFakeAssessmentWithGradeSelection() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    final fakeExamService = FakeAssessmentExamService(
      delegate: widget.examService,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          examService: fakeExamService,
          examShakeService: const NoopExamShakeService(),
          examPurpose: examPurposeAssessment,
          profileId: profileStableId(widget.activeProfile),
          initialGradeId: profileGradeStableId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
          onResultBack: () {
            if (!mounted) {
              return;
            }
            final navigator = Navigator.of(context);
            if (assessmentTabRoute == null) {
              navigator.popUntil((route) => route.isFirst);
              return;
            }
            navigator.popUntil((route) => identical(route, assessmentTabRoute));
          },
        ),
      ),
    );
    if (mounted) {
      await _loadAssessments(forceRefresh: true, page: 1);
    }
  }

  Future<void> _openAssessment() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          examPurpose: examPurposeAssessment,
          profileId: profileStableId(widget.activeProfile),
          initialGradeId: profileGradeStableId(widget.activeProfile),
          initialGradeLabel: widget.activeProfile?.grade?.label,
          onResultBack: () {
            if (!mounted) {
              return;
            }
            final navigator = Navigator.of(context);
            if (assessmentTabRoute == null) {
              navigator.popUntil((route) => route.isFirst);
              return;
            }
            navigator.popUntil((route) => identical(route, assessmentTabRoute));
          },
        ),
      ),
    );
    if (mounted) {
      await _loadAssessments(forceRefresh: true, page: 1);
    }
  }
}
