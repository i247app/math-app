part of '../student_class_search_content.dart';

extension _StudentClassSearchActions on _StudentClassSearchContentState {
  void _resetForProfileChange() {
    _debounce?.cancel();
    _searchRequestId++;
    _filterRequestId++;
    _searchController.clear();
    _updateState(() {
      _results = const <ClassroomModel>[];
      _grades = const <GradeModel>[];
      _schools = const <SchoolModel>[];
      _selectedGradeIds.clear();
      _selectedSchoolIds.clear();
      _isSearching = false;
      _hasSearched = false;
      _isLoadingFilters = true;
      _hasLoadedFilters = false;
      _lastSearch = null;
      _lastGradeIds = const <int>{};
      _lastSchoolIds = const <int>{};
      _error = null;
      _filterError = null;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search();
    });
  }

  Future<void> _search([String? rawValue, bool force = false]) async {
    final search = (rawValue ?? _searchController.text).trim();
    final gradeIds = Set<int>.from(_selectedGradeIds);
    final schoolIds = Set<int>.from(_selectedSchoolIds);
    final requestId = ++_searchRequestId;
    if (search.isEmpty && gradeIds.isEmpty && schoolIds.isEmpty) {
      _updateState(() {
        _results = const <ClassroomModel>[];
        _isSearching = false;
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    if (!force &&
        _hasSearched &&
        !_isSearching &&
        _error == null &&
        _lastSearch == search &&
        intSetEquals(_lastGradeIds, gradeIds) &&
        intSetEquals(_lastSchoolIds, schoolIds)) {
      return;
    }

    _lastSearch = search;
    _lastGradeIds = Set<int>.unmodifiable(gradeIds);
    _lastSchoolIds = Set<int>.unmodifiable(schoolIds);

    _updateState(() {
      _isSearching = true;
      _hasSearched = true;
      _error = null;
    });

    try {
      final results = await _classroomService
          .searchClassrooms(
            profileId: widget.profileId,
            search: search.isEmpty ? null : search,
            gradeIds: gradeIds.toList(growable: false),
            schoolIds: schoolIds.toList(growable: false),
          )
          .timeout(_StudentClassSearchContentState._requestTimeout);
      if (!mounted ||
          requestId != _searchRequestId ||
          _searchController.text.trim() != search ||
          !intSetEquals(_selectedGradeIds, gradeIds) ||
          !intSetEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      _updateState(() => _results = results);
    } catch (error) {
      if (!mounted ||
          requestId != _searchRequestId ||
          _searchController.text.trim() != search ||
          !intSetEquals(_selectedGradeIds, gradeIds) ||
          !intSetEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      _updateState(() {
        _error = error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentClassSearchFailed);
      });
    } finally {
      if (mounted &&
          requestId == _searchRequestId &&
          _searchController.text.trim() == search &&
          intSetEquals(_selectedGradeIds, gradeIds) &&
          intSetEquals(_selectedSchoolIds, schoolIds)) {
        _updateState(() => _isSearching = false);
      }
    }
  }
}
