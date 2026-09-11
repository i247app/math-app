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

  Future<void> _loadAssessments({bool forceRefresh = false, int? page}) async {
    final requestId = ++_loadRequestId;
    final targetPage = page ?? _pagination?.page ?? 1;
    final profileId = profileStableId(widget.activeProfile);
    final userId = widget.useActiveStudentProfileData ? null : widget.user?.id;
    final cachedAssessments = ExamCache.peekList(
      userId: userId,
      profileId: profileId,
    );
    if (!forceRefresh && targetPage == 1 && cachedAssessments != null) {
      _updateState(() => _applyCachedAssessments(cachedAssessments));
    }

    _updateState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final entries = <ParentAssessmentEntry>[];
    List<GeneratedExam>? loadedAllExams;
    List<ParentAssessmentEntry>? loadedAllEntries;
    ExamPagination? loadedPagination;
    var failed = false;

    if ((profileId != null && profileId > 0) ||
        (userId != null && userId > 0)) {
      try {
        final result = await loadCompletedParentAssessments(
          examService: widget.examService,
          profileId: profileId,
          userId: userId,
          page: targetPage,
          size: _ParentAssessmentTabState._pageSize,
          allowUserFallback: !widget.useActiveStudentProfileData,
        );
        loadedPagination = result.pagination;
        loadedAllExams = result.allExams;
        loadedAllEntries = result.allExams
            .map((exam) => ParentAssessmentEntry(exam: exam))
            .toList(growable: false);
        entries.addAll(
          result.exams.map((exam) => ParentAssessmentEntry(exam: exam)),
        );
      } catch (_) {
        failed = true;
      }
    }

    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    entries.sort((a, b) => examDate(b.exam).compareTo(examDate(a.exam)));
    final pageEntries = entries
        .take(_ParentAssessmentTabState._pageSize)
        .toList(growable: false);
    _updateState(() {
      if (!failed || entries.isNotEmpty || _entries.isEmpty) {
        _entries = pageEntries;
        _allEntries = loadedAllEntries ?? pageEntries;
        _pagination = loadedPagination;
      }
      _isLoading = false;
      _hasLoaded = true;
      _errorMessage = failed && _entries.isEmpty
          ? context.readText(AppKeys.parentExamLoadFailed)
          : null;
    });
    if (!failed && loadedAllExams != null) {
      ExamCache.seedList(
        exams: loadedAllExams,
        userId: userId,
        profileId: profileId,
      );
    }
  }

  void _applyCachedAssessments(List<GeneratedExam> exams) {
    final cachedEntries =
        exams
            .map((exam) => ParentAssessmentEntry(exam: exam))
            .toList(growable: false)
          ..sort((a, b) => examDate(b.exam).compareTo(examDate(a.exam)));
    final totalCount = cachedEntries.length;
    final totalPages = totalCount == 0
        ? 1
        : (totalCount + _ParentAssessmentTabState._pageSize - 1) ~/
              _ParentAssessmentTabState._pageSize;
    _entries = cachedEntries
        .take(_ParentAssessmentTabState._pageSize)
        .toList(growable: false);
    _allEntries = cachedEntries;
    _pagination = ExamPagination(
      page: 1,
      size: _ParentAssessmentTabState._pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNext: totalPages > 1,
      hasPrevious: false,
    );
    _isLoading = false;
    _hasLoaded = true;
    _errorMessage = null;
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
