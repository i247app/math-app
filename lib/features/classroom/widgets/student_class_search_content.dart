import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/data/cache/student_class_search_filter_cache.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';
import 'package:numi/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_class_card.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_filter_panel.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_retry_banner.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_search_field.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_school_filter_bottom_sheet.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_state_card.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/school_api.dart';

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
  }) : _classroomService = classroomService,
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
      widget._classroomService ?? context.read<ClassroomService>();
  late final GradeService _gradeService =
      widget._gradeService ?? context.read<GradeService>();
  late final SchoolService _schoolService =
      widget._schoolService ?? context.read<SchoolService>();
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
  String? _lastSearch;
  Set<int> _lastGradeIds = const <int>{};
  Set<int> _lastSchoolIds = const <int>{};
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
      setState(() {
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

  Future<void> _loadFilterOptions({bool forceRefresh = false}) async {
    final requestId = ++_filterRequestId;
    final userId = widget.userId;
    if (userId != null && userId > 0) {
      final cachedOptions = StudentClassSearchFilterCache.shared.get(userId);
      if (!forceRefresh && cachedOptions != null) {
        setState(() {
          _applyFilterOptions(cachedOptions);
          _hasLoadedFilters = true;
          _filterError = null;
          _isLoadingFilters = false;
        });
        unawaited(_loadFilterOptions(forceRefresh: true));
        return;
      }
    }

    setState(() {
      _isLoadingFilters = true;
      _filterError = null;
    });

    final results = await _loadFilterOptionsResult(userId);
    if (!mounted || requestId != _filterRequestId) {
      return;
    }

    setState(() {
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
          .timeout(_requestTimeout);
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
      context.showInfoDialog(
        relationship == ClassroomRelationship.member
            ? context.readText(AppKeys.studentAlreadyJoinedClass)
            : context.readText(AppKeys.studentClassJoinRequestPending),
      );
      return;
    }

    final code = classroomCode(classroom);
    if (code == null) {
      context.showErrorDialog(
        context.readText(AppKeys.studentClassMissingCode),
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
      widget.onJoinRequested?.call();
      context.read<ClassroomCubit>().invalidateJoined(widget.profileId);
      await _search(null, true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(
        error is ClassroomException
            ? error.message
            : context.readText(AppKeys.studentJoinClassFailed),
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
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: StudentJoinFilterPanel(
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
        ),
        Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Text(
            context.getText(AppKeys.studentSearchResults),
            style: const TextStyle(
              color: AppColors.textTeal,
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 2,
              letterSpacing: 0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildResults(),
        ),
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
        titleColor: AppColors.black87,
        messageKey: AppKeys.studentEnterClassCodeMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(
              minHeight: 3,
              color: AppColors.teal520,
              backgroundColor: Color(0xFFDDEDEA),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StudentJoinRetryBanner(message: _error!, onRetry: _search),
          ),
        Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final classroom in _results)
              StudentJoinClassCard(
                classroom: classroom,
                isJoining: _joiningClassroomId == (classroom.stableId ?? -1),
                onJoin: () => _joinClassroom(classroom),
              ),
          ],
        ),
      ],
    );
  }
}
