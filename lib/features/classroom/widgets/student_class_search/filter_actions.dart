part of '../student_class_search_content.dart';

extension _StudentClassFilterActions on _StudentClassSearchContentState {
  Future<void> _loadFilterOptions({bool forceRefresh = false}) async {
    final requestId = ++_filterRequestId;
    final userId = widget.userId;
    if (userId != null && userId > 0) {
      final cachedOptions = StudentClassSearchFilterCache.shared.get(userId);
      if (!forceRefresh && cachedOptions != null) {
        _updateState(() {
          _applyFilterOptions(cachedOptions);
          _hasLoadedFilters = true;
          _filterError = null;
          _isLoadingFilters = false;
        });
        unawaited(_loadFilterOptions(forceRefresh: true));
        return;
      }
    }

    _updateState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });

    final results = await _loadFilterOptionsResult(userId);
    if (!mounted || requestId != _filterRequestId) {
      return;
    }

    _updateState(() {
      if (results != null) {
        _applyFilterOptions(results);
      }
      _hasLoadedFilters = results != null;
      _filterError = _hasLoadedFilters
          ? null
          : context.readText(AppKeys.studentClassFilterLoadFailed);
      _isLoadingFilters = false;
    });
  }

  Future<StudentClassSearchFilterOptions?> _loadFilterOptionsResult(
    int? userId,
  ) async {
    if (userId == null || userId <= 0) {
      return const StudentClassSearchFilterOptions(
        userId: 0,
        grades: <GradeModel>[],
        schools: <SchoolModel>[],
      );
    }
    try {
      return await StudentClassSearchFilterCache.shared
          .load(
            userId: userId,
            gradeService: _gradeService,
            schoolService: _schoolService,
            forceRefresh: true,
          )
          .timeout(_StudentClassSearchContentState._requestTimeout);
    } catch (_) {
      return null;
    }
  }

  void _applyFilterOptions(StudentClassSearchFilterOptions options) {
    _grades = options.grades
        .where((grade) => gradeStableId(grade) != null)
        .toList(growable: false);
    _schools = options.schools
        .where((school) => schoolStableId(school) != null)
        .toList(growable: false);
  }

  void _selectGrade(GradeModel grade) {
    final gradeId = gradeStableId(grade);
    if (gradeId == null) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      if (!_selectedGradeIds.add(gradeId)) {
        _selectedGradeIds.remove(gradeId);
      }
    });
    _search();
  }

  void _removeGrade(int gradeId) {
    if (!_selectedGradeIds.contains(gradeId)) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() => _selectedGradeIds.remove(gradeId));
    _search();
  }

  Future<void> _openSchoolPicker() async {
    if (_schools.isEmpty) {
      HapticFeedback.selectionClick();
      return;
    }
    final selectedSchoolIds = await showModalBottomSheet<Set<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.themeColors.elevatedSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StudentJoinSchoolFilterBottomSheet(
          schools: _schools,
          selectedSchoolIds: _selectedSchoolIds,
        );
      },
    );
    if (!mounted || selectedSchoolIds == null) {
      return;
    }
    if (intSetEquals(_selectedSchoolIds, selectedSchoolIds)) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() {
      _selectedSchoolIds
        ..clear()
        ..addAll(selectedSchoolIds);
    });
    _search();
  }

  void _removeSchool(int schoolId) {
    if (!_selectedSchoolIds.contains(schoolId)) {
      return;
    }
    HapticFeedback.selectionClick();
    _updateState(() => _selectedSchoolIds.remove(schoolId));
    _search();
  }
}
