part of '../parent_assessment_tab.dart';

extension _ParentAssessmentNavigationActions on _ParentAssessmentTabState {
  void _showAssessmentContentAndLoad() {
    if (_showAssessmentContent) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _showAssessmentContent = true;
      _isLoading = true;
      _hasLoaded = false;
      _errorMessage = null;
    });
    _resetAssessmentScrollAfterBuild();
    unawaited(_loadAssessments(page: 1));
  }

  void _showAssessmentLanding() {
    if (!_showAssessmentContent) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() => _showAssessmentContent = false);
    _resetAssessmentScrollAfterBuild();
  }

  void _resetAssessmentScrollAfterBuild() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      _scrollController.jumpTo(0);
    });
  }

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
    final userAiExamId = exam.examId ?? exam.userAiExamId ?? exam.id;
    final userExamId = exam.userExamId;
    final detailId = userExamId ?? userAiExamId;
    if (detailId == null || detailId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExamReviewScreen(
          examId: userExamId == null ? userAiExamId : null,
          userExamId: userExamId,
          initialExam: exam,
        ),
      ),
    );
  }

  Future<void> _openActiveAssessment(GeneratedExam summaryExam) async {
    final userExamId = summaryExam.userExamId;
    final profileId = profileStableId(widget.activeProfile);
    if (userExamId == null || userExamId <= 0 || profileId == null) {
      return;
    }

    HapticFeedback.selectionClick();
    final result = await showActiveAssessmentDialog(
      context,
      onCancel: () => widget.examService.updateUserExamStatus(
        userExamId: userExamId,
        status: assessmentCanceledStatus,
        profileId: profileId,
      ),
      onContinue: () => widget.examService.getExamDetail(
        userExamId,
        profileId: profileId,
        userExamId: userExamId,
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    if (result.action == ActiveAssessmentDialogAction.canceled) {
      await _loadAssessments(page: 1);
      return;
    }

    final resumedExam = result.exam;
    if (resumedExam == null || resumedExam.questions.isEmpty) {
      return;
    }
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiAssessmentScreen(
          examService: widget.examService,
          initialExam: resumedExam,
          examType: resumedExam.examType ?? examTypeAssessment,
          gradeLabel: AssessmentFlowPolicy.gradeLabel(resumedExam.grade ?? 0),
          profileId: profileId,
          allowQuestionNavigation: false,
          showQuestionNavigation: false,
          isResumedAssessment: true,
          onResultBack: () {
            if (!mounted) return;
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
    if (mounted && _showAssessmentContent) {
      await _loadAssessments(page: 1);
    }
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

  Future<void> _openAssessmentDirectly() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiAssessmentScreen(
          examService: widget.examService,
          examType: examTypeAssessment,
          gradeLabel: widget.activeProfile?.grade?.label,
          profileId: profileStableId(widget.activeProfile),
          allowQuestionNavigation: false,
          showQuestionNavigation: false,
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
    if (mounted && _showAssessmentContent) {
      await _loadAssessments(page: 1);
    }
  }

  Future<void> _openAssessmentWithGradeSelection() async {
    HapticFeedback.lightImpact();
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GradeSelectionScreen(
          user: widget.user,
          initialGrades: widget.initialGrades,
          gradeService: widget.gradeService,
          examService: widget.examService,
          examType: examTypeAssessment,
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
    if (mounted && _showAssessmentContent) {
      await _loadAssessments(page: 1);
    }
  }
}
