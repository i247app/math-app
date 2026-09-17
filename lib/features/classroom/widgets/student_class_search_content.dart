import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/data/student_class_search_filter_cache.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_class_card.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_filter_panel.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_retry_banner.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_search_field.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_school_filter_bottom_sheet.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_state_card.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/school_service.dart';

part 'student_class_search/search_actions.dart';
part 'student_class_search/filter_actions.dart';
part 'student_class_search/join_actions.dart';

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

  void _updateState(VoidCallback update) => setState(update);
}
