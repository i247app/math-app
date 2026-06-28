import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_class_search_style.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_class_card.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_filter_panel.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_retry_banner.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_search_field.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_school_filter_bottom_sheet.dart';
import 'package:numi_flutter/features/classroom/widgets/student_search/student_join_state_card.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/profile/school_api.dart';

class StudentClassSearchContent extends StatefulWidget {
  const StudentClassSearchContent({
    super.key,
    required this.profileId,
    this.userId,
    this.onJoinRequested,
    this.activeRefreshTick = 0,
    ClassroomService? classroomService,
    GradeService? gradeService,
    SchoolService? schoolService,
  })  : _classroomService = classroomService,
        _gradeService = gradeService,
        _schoolService = schoolService;

  final int profileId;
  final int? userId;
  final VoidCallback? onJoinRequested;
  final int activeRefreshTick;
  final ClassroomService? _classroomService;
  final GradeService? _gradeService;
  final SchoolService? _schoolService;

  @override
  State<StudentClassSearchContent> createState() =>
      _StudentClassSearchContentState();
}

class _StudentClassSearchContentState extends State<StudentClassSearchContent> {
  static const _requestTimeout = Duration(seconds: 12);

  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final SchoolService _schoolService =
      widget._schoolService ?? SchoolApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<ClassroomModel> _results = const <ClassroomModel>[];
  List<GradeModel> _grades = const <GradeModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingFilters = true;
  bool _hasLoadedFilters = false;
  int _searchRequestId = 0;
  int _filterRequestId = 0;
  int? _joiningClassroomId;
  final Set<int> _selectedGradeIds = <int>{};
  final Set<int> _selectedSchoolIds = <int>{};
  String? _error;
  String? _filterError;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  @override
  void didUpdateWidget(covariant StudentClassSearchContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.userId != widget.userId) {
      _resetForProfileChange();
      _loadFilterOptions();
      return;
    }

    if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      if (!_hasLoadedFilters || _filterError != null) {
        _loadFilterOptions();
      }
      if (_error != null && _hasSearchCriteria) {
        _search();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasSearchCriteria =>
      _searchController.text.trim().isNotEmpty ||
      _selectedGradeIds.isNotEmpty ||
      _selectedSchoolIds.isNotEmpty;

  void _resetForProfileChange() {
    _debounce?.cancel();
    _searchRequestId++;
    _filterRequestId++;
    _searchController.clear();
    setState(() {
      _results = const <ClassroomModel>[];
      _grades = const <GradeModel>[];
      _schools = const <SchoolModel>[];
      _selectedGradeIds.clear();
      _selectedSchoolIds.clear();
      _isSearching = false;
      _hasSearched = false;
      _isLoadingFilters = true;
      _hasLoadedFilters = false;
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

  Future<void> _search([String? rawValue]) async {
    final search = (rawValue ?? _searchController.text).trim();
    final gradeIds = Set<int>.from(_selectedGradeIds);
    final schoolIds = Set<int>.from(_selectedSchoolIds);
    final requestId = ++_searchRequestId;
    if (search.isEmpty && gradeIds.isEmpty && schoolIds.isEmpty) {
      setState(() {
        _results = const <ClassroomModel>[];
        _isSearching = false;
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
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
          .timeout(_requestTimeout);
      if (!mounted ||
          requestId != _searchRequestId ||
          _searchController.text.trim() != search ||
          !intSetEquals(_selectedGradeIds, gradeIds) ||
          !intSetEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      setState(() => _results = results);
    } catch (error) {
      if (!mounted ||
          requestId != _searchRequestId ||
          _searchController.text.trim() != search ||
          !intSetEquals(_selectedGradeIds, gradeIds) ||
          !intSetEquals(_selectedSchoolIds, schoolIds)) {
        return;
      }
      setState(() {
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
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _loadFilterOptions() async {
    final requestId = ++_filterRequestId;
    final userId = widget.userId;
    setState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });

    final results = await Future.wait<Object?>([
      _loadGrades(userId),
      _loadSchools(),
    ]);
    if (!mounted || requestId != _filterRequestId) {
      return;
    }

    final grades = results[0] as List<GradeModel>?;
    final schools = results[1] as List<SchoolModel>?;
    setState(() {
      if (grades != null) {
        _grades = grades
            .where((grade) => gradeStableId(grade) != null)
            .toList(growable: false);
      }
      if (schools != null) {
        _schools = schools
            .where((school) => schoolStableId(school) != null)
            .toList(growable: false);
      }
      _hasLoadedFilters = grades != null && schools != null;
      _filterError = _hasLoadedFilters
          ? null
          : context.readText(AppKeys.studentClassFilterLoadFailed);
      _isLoadingFilters = false;
    });
  }

  Future<List<GradeModel>?> _loadGrades(int? userId) async {
    if (userId == null || userId <= 0) {
      return const <GradeModel>[];
    }
    try {
      return await _gradeService
          .listGrades(userId: userId)
          .timeout(_requestTimeout);
    } catch (_) {
      return null;
    }
  }

  Future<List<SchoolModel>?> _loadSchools() async {
    try {
      return await _schoolService.listSchools().timeout(_requestTimeout);
    } catch (_) {
      return null;
    }
  }

  void _selectGrade(GradeModel grade) {
    final gradeId = gradeStableId(grade);
    if (gradeId == null) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
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
    setState(() => _selectedGradeIds.remove(gradeId));
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
      backgroundColor: Colors.white,
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
    setState(() {
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
    setState(() => _selectedSchoolIds.remove(schoolId));
    _search();
  }

  Future<void> _joinClassroom(ClassroomModel classroom) async {
    final relationship = classroom.relationshipStatus;
    if (relationship != ClassroomRelationship.none) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            relationship == ClassroomRelationship.member
                ? context.readText(AppKeys.studentAlreadyJoinedClass)
                : context.readText(AppKeys.studentClassJoinRequestPending),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final code = classroomCode(classroom);
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentClassMissingCode)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _joiningClassroomId = classroom.stableId ?? -1);
    try {
      await _classroomService.joinClassroomByCode(
        profileId: widget.profileId,
        classroomCode: code,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.readText(AppKeys.studentJoinClassSuccess)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onJoinRequested?.call();
      await _search();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ClassroomException
                ? error.message
                : context.readText(AppKeys.studentJoinClassFailed),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _joiningClassroomId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudentJoinSearchField(
          controller: _searchController,
          isSearching: _isSearching,
          onChanged: _onSearchChanged,
          onSubmitted: _search,
        ),
        const SizedBox(height: 14),
        StudentJoinFilterPanel(
          grades: _grades,
          schools: _schools,
          selectedGradeIds: _selectedGradeIds,
          selectedSchoolIds: _selectedSchoolIds,
          isLoading: _isLoadingFilters,
          error: _filterError,
          onRetry: _loadFilterOptions,
          onGradeTap: _selectGrade,
          onGradeRemove: _removeGrade,
          onSchoolTap: _openSchoolPicker,
          onSchoolRemove: _removeSchool,
        ),
        const SizedBox(height: 17),
        Text(
          context.getText(AppKeys.studentSearchResults),
          style: const TextStyle(
            color: studentJoinBlue,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        _buildResults(),
      ],
    );
  }

  Widget _buildResults() {
    if (_isSearching && _results.isEmpty) {
      return const StudentJoinStateCard(
        assetPath: studentJoinSearchIcon,
        titleKey: AppKeys.loading,
        messageKey: AppKeys.studentClassSearchLoading,
      );
    }

    if (_error != null && _results.isEmpty) {
      return StudentJoinStateCard(
        assetPath: studentJoinSearchIcon,
        title: _error!,
        messageKey: AppKeys.studentClassSearchRetry,
        actionLabelKey: AppKeys.studentRetry,
        onAction: _search,
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return const StudentJoinStateCard(
        assetPath: studentJoinBookIcon,
        isSvg: true,
        titleKey: AppKeys.studentNoClassSearchResults,
        messageKey: AppKeys.studentNoClassSearchResultsMessage,
      );
    }

    if (!_hasSearched) {
      return const StudentJoinStateCard(
        assetPath: studentJoinSearchIcon,
        titleKey: AppKeys.studentEnterClassCodeTitle,
        messageKey: AppKeys.studentEnterClassCodeMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isSearching) ...[
          const LinearProgressIndicator(
            minHeight: 3,
            color: studentJoinTeal,
            backgroundColor: Color(0xFFDDEDEA),
          ),
          const SizedBox(height: 10),
        ],
        if (_error != null) ...[
          StudentJoinRetryBanner(
            message: _error!,
            onRetry: _search,
          ),
          const SizedBox(height: 10),
        ],
        for (var index = 0; index < _results.length; index++) ...[
          StudentJoinClassCard(
            classroom: _results[index],
            isJoining: _joiningClassroomId == (_results[index].stableId ?? -1),
            onJoin: () => _joinClassroom(_results[index]),
          ),
          if (index != _results.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
