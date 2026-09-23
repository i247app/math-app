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

  Future<void> _loadAssessments({
    int? page,
    bool openExamWhenEmpty = false,
    bool openGradeRoadmapWhenAvailable = false,
  }) async {
    final requestId = ++_loadRequestId;
    final targetPage = page ?? _pagination?.page ?? 1;
    final profileId = profileStableId(widget.activeProfile);

    _updateState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    var loadedAllEntries = const <ParentAssessmentEntry>[];
    ParentAssessmentEntry? loadedActiveEntry;
    var failed = false;
    var loadedStats = false;

    if (profileId != null && profileId > 0) {
      try {
        final stats = await widget.examService.getExamStats(
          profileId: profileId,
          examType: _contentExamType,
        );
        loadedStats = true;
        final activeEntries =
            stats
                .where(_isActiveAssessmentStats)
                .map(_assessmentEntryFromStats)
                .toList(growable: false)
              ..sort((a, b) => examDate(b.exam).compareTo(examDate(a.exam)));
        loadedActiveEntry = activeEntries.isEmpty ? null : activeEntries.first;
        loadedAllEntries =
            stats
                .where(isCompletedAssessmentStats)
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
      if (!failed || (_entries.isEmpty && _activeEntry == null)) {
        _entries = pageEntries;
        _allEntries = loadedAllEntries;
        _activeEntry = loadedActiveEntry;
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

    final hasNoVisibleExam =
        loadedAllEntries.isEmpty && loadedActiveEntry == null;
    if (openExamWhenEmpty && loadedStats && !failed) {
      if (_contentExamType == examTypeGrade) {
        if (hasNoVisibleExam) {
          await _openAssessmentWithGradeSelection();
        } else {
          await _openGradeRoadmap();
        }
      } else if (hasNoVisibleExam) {
        await _openAssessmentDirectly();
      }
    }
    if (openGradeRoadmapWhenAvailable &&
        loadedStats &&
        !failed &&
        _contentExamType == examTypeGrade &&
        !hasNoVisibleExam) {
      await _openGradeRoadmap();
    }
  }

  bool _isActiveAssessmentStats(ExamStats stats) {
    return activeInProgressAssessmentExam(stats) != null;
  }

  ParentAssessmentEntry _assessmentEntryFromStats(ExamStats stats) {
    final inProgressExam = activeInProgressAssessmentExam(stats);
    if (inProgressExam != null) {
      return ParentAssessmentEntry(exam: inProgressExam);
    }
    return ParentAssessmentEntry(
      exam: completedAssessmentFromStats(
        stats,
        profileId: profileStableId(widget.activeProfile)!,
        fallbackExamType: _contentExamType,
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
