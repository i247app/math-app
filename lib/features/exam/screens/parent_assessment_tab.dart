import 'dart:async';

import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/exam_attempt_screen.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/screens/learning_progress_screen.dart';
import 'package:numi/features/exam/screens/exam_review_screen.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/exam/models/parent_assessment_entry.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_progress_chart.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_banner.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_active_card.dart';

part 'parent_assessment/data_actions.dart';
part 'parent_assessment/navigation_actions.dart';
part 'parent_assessment/content_builder.dart';

class ParentAssessmentTab extends StatefulWidget {
  const ParentAssessmentTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.initialGrades,
    required this.gradeService,
    required this.examService,
    required this.bottomPadding,
    this.useActiveStudentProfileData = false,
  });

  final LoginUser? user;
  final UserProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final ExamService examService;
  final double bottomPadding;
  final bool useActiveStudentProfileData;

  @override
  State<ParentAssessmentTab> createState() => _ParentAssessmentTabState();
}

class _ParentAssessmentTabState extends State<ParentAssessmentTab> {
  static const _pageSize = 5;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ParentAssessmentEntry> _entries = const <ParentAssessmentEntry>[];
  List<ParentAssessmentEntry> _allEntries = const <ParentAssessmentEntry>[];
  ParentAssessmentEntry? _activeEntry;
  ExamPagination? _pagination;
  bool _isLoading = false;
  bool _hasLoaded = false;
  bool _hasPlayedInitialEntrance = false;
  String? _errorMessage;
  int _loadRequestId = 0;
  String _contentExamType = examTypeAssessment;
  bool _isOpeningActiveAssessment = false;
  bool _isOpeningGradeRoadmap = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _isLoading = widget.isActive;
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_loadAssessments(page: 1));
      });
    }
  }

  @override
  void didUpdateWidget(covariant ParentAssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _resetAssessmentScrollAfterBuild();
      unawaited(_loadAssessments(page: 1));
      return;
    }
    if (!widget.isActive) {
      return;
    }
    if (_profileSourceKey(
          oldWidget.user,
          oldWidget.activeProfile,
          oldWidget.useActiveStudentProfileData,
        ) !=
        _profileSourceKey(
          widget.user,
          widget.activeProfile,
          widget.useActiveStudentProfileData,
        )) {
      _entries = const <ParentAssessmentEntry>[];
      _pagination = null;
      _allEntries = const <ParentAssessmentEntry>[];
      _activeEntry = null;
      _hasLoaded = false;
      _errorMessage = null;
      _contentExamType = examTypeAssessment;
      _isLoading = false;
      _loadRequestId++;
      _resetAssessmentScrollAfterBuild();
      unawaited(_loadAssessments(page: 1));
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _resetAssessmentScrollAfterBuild();
      unawaited(_loadAssessments(page: 1));
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final entries = _filteredEntries;
    final shouldShowFullSkeleton = _isLoading && !_hasLoaded;
    final assessmentChildren = _buildAssessmentChildren(
      entries: entries,
      shouldShowFullSkeleton: shouldShowFullSkeleton,
    );

    final colors = context.themeColors;
    final scrollView = CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            title: context.getText(AppKeys.parentAssessmentTabTitle),
            topInset: topInset,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, widget.bottomPadding + 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: assessmentChildren,
            ),
          ),
        ),
      ],
    );

    return Material(
      color: colors.pageBackground,
      child: RefreshIndicator(
        color: colors.brandStrong,
        onRefresh: _loadAssessments,
        child: scrollView,
      ),
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
