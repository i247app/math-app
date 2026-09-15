part of '../parent_assessment_tab.dart';

extension _ParentAssessmentNavigationActions on _ParentAssessmentTabState {
  void _showAssessmentContentAndLoad() {
    if (_showAssessmentContent) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _showAssessmentContent = true;
      _contentExamType = examTypeAssessment;
      _isLoading = true;
      _hasLoaded = false;
      _errorMessage = null;
    });
    _resetAssessmentScrollAfterBuild();
    unawaited(_loadAssessments(page: 1));
  }

  void _showGradeContentAndLoad() {
    if (_showAssessmentContent && _contentExamType == examTypeGrade) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _showAssessmentContent = true;
      _contentExamType = examTypeGrade;
      _isLoading = true;
      _hasLoaded = false;
      _errorMessage = null;
      _entries = const <ParentAssessmentEntry>[];
      _allEntries = const <ParentAssessmentEntry>[];
      _activeEntry = null;
      _pagination = null;
    });
    _resetAssessmentScrollAfterBuild();
    unawaited(_loadAssessments(page: 1));
  }

  void _showAssessmentLanding() {
    if (!_showAssessmentContent) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _showAssessmentContent = false;
      _contentExamType = examTypeAssessment;
    });
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
    if (_isOpeningActiveAssessment) {
      return;
    }
    final profileId = profileStableId(widget.activeProfile);
    if (profileId == null) {
      return;
    }

    HapticFeedback.selectionClick();
    _updateState(() {
      _isOpeningActiveAssessment = true;
      _errorMessage = null;
    });

    if (summaryExam.questions.isEmpty) {
      final message = context.readText(AppKeys.examDetailLoadFailed);
      _updateState(() {
        _isOpeningActiveAssessment = false;
        _errorMessage = message;
      });
      _showActiveAssessmentLoadError(message);
      return;
    }

    if (!mounted) {
      return;
    }
    _updateState(() => _isOpeningActiveAssessment = false);
    final assessmentTabRoute = ModalRoute.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiAssessmentScreen(
          examService: widget.examService,
          initialExam: summaryExam,
          examType: summaryExam.examType ?? _contentExamType,
          gradeLabel: AssessmentFlowPolicy.gradeLabel(summaryExam.grade ?? 0),
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

  void _showActiveAssessmentLoadError(String message) {
    if (Scaffold.maybeOf(context) == null) {
      return;
    }
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openLearningProgress() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LearningProgressScreen(
          profileId: profileStableId(widget.activeProfile),
          examService: widget.examService,
          examType: _contentExamType,
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
          examType: examTypeGrade,
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
