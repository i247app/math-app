import 'package:numi/features/quiz/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/profile/helpers/profile_identity_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/screens/grade_selection_screen.dart';
import 'package:numi/features/quiz/screens/learning_progress_screen.dart';
import 'package:numi/features/quiz/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_progress_chart.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_search_field.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_empty_poster.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/quiz/widgets/parent_assessment/parent_assessment_tab_banner.dart';

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
    required this.quizService,
    required this.bottomPadding,
    this.useActiveStudentProfileData = false,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final QuizService quizService;
  final double bottomPadding;
  final bool useActiveStudentProfileData;

  @override
  State<ParentAssessmentTab> createState() => _ParentAssessmentTabState();
}

class _ParentAssessmentTabState extends State<ParentAssessmentTab> {
  static const _pageSize = 5;

  final TextEditingController _searchController = TextEditingController();

  List<ParentAssessmentEntry> _entries = const <ParentAssessmentEntry>[];
  List<ParentAssessmentEntry> _allEntries = const <ParentAssessmentEntry>[];
  QuizPagination? _pagination;
  bool _isLoading = true;
  bool _hasLoaded = false;
  bool _hasPlayedInitialEntrance = false;
  String? _errorMessage;
  int _loadRequestId = 0;
  bool _isActivationLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    if (widget.isActive) {
      _scheduleActivationLoad();
    }
  }

  @override
  void didUpdateWidget(covariant ParentAssessmentTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      // A tab activation is an explicit refresh boundary. Load immediately so
      // every navigation into Assess issues a fresh /quizzes/list request,
      // even when this tab's widget and its previously rendered data are kept
      // alive by the dashboard tab host.
      _loadAssessments(forceRefresh: true, page: 1);
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
      _hasLoaded = false;
      _errorMessage = null;
      _loadAssessments(page: 1);
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadAssessments(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final entries = _filteredEntries;
    final shouldShowFullSkeleton = _isLoading && !_hasLoaded;
    final hasNoAssessments =
        _hasLoaded && _errorMessage == null && _entries.isEmpty;

    final colors = context.themeColors;
    return ColoredBox(
      color: colors.pageBackground,
      child: RefreshIndicator(
        color: colors.brandStrong,
        onRefresh: () => _loadAssessments(forceRefresh: true),
        child: CustomScrollView(
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
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                widget.bottomPadding + 20,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildAssessmentChildren(
                    entries: entries,
                    hasNoAssessments: hasNoAssessments,
                    shouldShowFullSkeleton: shouldShowFullSkeleton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
