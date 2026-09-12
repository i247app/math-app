part of '../parent_assessment_tab.dart';

extension _ParentAssessmentDataActions on _ParentAssessmentTabState {
  String _profileSourceKey(
    LoginUser? user,
    StudentProfile? activeProfile,
    bool useActiveStudentProfileData,
  ) {
    return '${user?.id}|'
        '${profileStableId(activeProfile)}|'
        '$useActiveStudentProfileData';
  }

  Future<void> _loadAssessments({int? page}) async {
    final requestId = ++_loadRequestId;
    final targetPage = page ?? _pagination?.page ?? 1;
    final profileId = profileStableId(widget.activeProfile);

    _updateState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var loadedAllEntries = const <ParentAssessmentEntry>[];
    var failed = false;

    if (profileId != null && profileId > 0) {
      try {
        final stats = await widget.examService.getExamStats(
          profileId: profileId,
          examType: examTypeAssessment,
        );
        loadedAllEntries =
            stats
                .where(_isCompletedAssessmentStats)
                .map(_assessmentEntryFromStats)
                .toList(growable: false)
              ..sort((a, b) => examDate(b.exam).compareTo(examDate(a.exam)));
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    final totalCount = loadedAllEntries.length;
    final totalPages = totalCount == 0
        ? 1
        : (totalCount + _ParentAssessmentTabState._pageSize - 1) ~/
              _ParentAssessmentTabState._pageSize;
    final currentPage = targetPage.clamp(1, totalPages);
    final start = (currentPage - 1) * _ParentAssessmentTabState._pageSize;
    final pageEntries = loadedAllEntries
        .skip(start)
        .take(_ParentAssessmentTabState._pageSize)
        .toList(growable: false);
    _updateState(() {
      if (!failed || _entries.isEmpty) {
        _entries = pageEntries;
        _allEntries = loadedAllEntries;
        _pagination = ExamPagination(
          page: currentPage,
          size: _ParentAssessmentTabState._pageSize,
          totalCount: totalCount,
          totalPages: totalPages,
          hasNext: currentPage < totalPages,
          hasPrevious: currentPage > 1,
        );
      }
      _isLoading = false;
      _hasLoaded = true;
      _errorMessage = failed && _entries.isEmpty
          ? context.readText(AppKeys.parentExamLoadFailed)
          : null;
    });
  }

  bool _isCompletedAssessmentStats(ExamStats stats) {
    final status = stats.status?.trim().toUpperCase();
    return status == null ||
        status.isEmpty ||
        status == 'COMPLETE' ||
        status == 'COMPLETED' ||
        status == 'SUBMITTED';
  }

  ParentAssessmentEntry _assessmentEntryFromStats(ExamStats stats) {
    final submittedAt = stats.lastSubmittedDt?.toIso8601String();
    final detectedGrade = stats.grade == null ? null : 'Lớp ${stats.grade}';
    return ParentAssessmentEntry(
      exam: GeneratedExam(
        userExamId: stats.userExamId,
        profileId: profileStableId(widget.activeProfile),
        examStatus: stats.status,
        examType: stats.examType ?? examTypeAssessment,
        grade: stats.grade,
        level: stats.level,
        createDt: submittedAt,
        modifyDt: submittedAt,
        shortText: stats.review,
        grading: ExamGrading(
          aiDetectGrade: detectedGrade,
          aiReview: stats.review,
          correctNumber: stats.correctNumber,
          scorePercentage: stats.scorePercentage.round(),
          totalQuestions: stats.totalQuestions,
        ),
        questions: const <ExamQuestion>[],
      ),
    );
  }

  void _selectPage(int page) {
    final totalPages = _pagination?.totalPages ?? 1;
    final currentPage = _pagination?.page ?? 1;
    if (_isLoading || page == currentPage || page < 1 || page > totalPages) {
      return;
    }
    final start = (page - 1) * _ParentAssessmentTabState._pageSize;
    final pageEntries = _allEntries
        .skip(start)
        .take(_ParentAssessmentTabState._pageSize)
        .toList(growable: false);
    _updateState(() {
      _entries = pageEntries;
      _pagination = ExamPagination(
        page: page,
        size: _ParentAssessmentTabState._pageSize,
        totalCount: _allEntries.length,
        totalPages: totalPages,
        hasNext: page < totalPages,
        hasPrevious: page > 1,
      );
    });
  }

  Widget? _buildPagination({double topPadding = 0}) {
    final pagination = _pagination;
    if (pagination == null ||
        _searchController.text.trim().isNotEmpty ||
        (pagination.totalCount ?? 0) <= 0) {
      return null;
    }

    final currentPage = pagination.page ?? 1;
    final reportedTotalPages = pagination.totalPages ?? 1;
    final totalPages = reportedTotalPages < 1 ? 1 : reportedTotalPages;
    final paginationControl = ParentAssessmentPagination(
      currentPage: currentPage,
      totalPages: totalPages,
      hasPrevious: pagination.hasPrevious ?? currentPage > 1,
      hasNext: pagination.hasNext ?? currentPage < totalPages,
      isLoading: _isLoading,
      onPageSelected: _selectPage,
    );
    return topPadding == 0
        ? paginationControl
        : Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: paginationControl,
          );
  }
}
