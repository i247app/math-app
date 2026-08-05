import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/home/parent/data/cache/parent_home_snapshot.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_entry_screen.dart';
import 'package:numi/features/settings/application/setting_tab.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';
import 'package:numi/features/home/data/home_layout_mappers.dart';
import 'package:numi/features/classroom/helpers/parent_room_helpers.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/presentation/screens/parent_room_detail_screen.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_loading.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_select_student_card.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_state_card.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_completed_task_list_item.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_empty_task_line.dart';
import 'package:numi/features/classroom/widgets/parent_tasks/parent_pending_task_list_item.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/shared/widgets/app_content_section.dart';
import 'package:numi/shared/widgets/app_responsive_card_group.dart';
import 'package:numi/shared/widgets/app_summary_card.dart';

class ParentRoomTab extends StatefulWidget {
  const ParentRoomTab({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.isActive,
    required this.activeRefreshTick,
    required this.assignmentService,
    required this.onRefreshProfiles,
    required this.onActivateProfile,
    required this.onProfileSaved,
    required this.onOpenClassroomTab,
    required this.onOpenProfileMenu,
    required this.bottomPadding,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final bool isActive;
  final int activeRefreshTick;
  final ClassroomExerciseService assignmentService;
  final Future<void> Function() onRefreshProfiles;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final VoidCallback onProfileSaved;
  final VoidCallback onOpenClassroomTab;
  final VoidCallback onOpenProfileMenu;
  final double bottomPadding;

  @override
  State<ParentRoomTab> createState() => _ParentRoomTabState();
}

class _ParentRoomTabState extends State<ParentRoomTab> {
  late final HomeLayoutService _homeLayoutService = HomeLayoutApi();

  HomeLayout? _layout;
  bool _isLoading = true;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _requestId = 0;
  bool _hasPlayedRoomEntrance = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadLayout();
    }
  }

  @override
  void didUpdateWidget(covariant ParentRoomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadLayout();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (oldProfileId != profileId ||
        oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _resetRoomEntrance();
      _loadLayout(forceRefresh: true);
    }
  }

  void _resetRoomEntrance() {
    _hasPlayedRoomEntrance = false;
  }

  Widget _roomFadeIn({
    required Widget child,
    int order = 0,
    bool markOnEnd = false,
  }) {
    if (_hasPlayedRoomEntrance) {
      return child;
    }

    return AppStaggeredEntrance(
      order: order,
      onFinished: markOnEnd ? _markRoomEntrancePlayed : null,
      child: child,
    );
  }

  void _markRoomEntrancePlayed() {
    if (!mounted || _hasPlayedRoomEntrance) {
      return;
    }
    setState(() => _hasPlayedRoomEntrance = true);
  }

  Future<void> _loadLayout({bool forceRefresh = false}) async {
    final requestId = ++_requestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null || profileId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _layout = null;
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = null;
      });
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getParent(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      setState(() => _applySnapshot(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent = _hasLoaded;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _homeLayoutService.getLayout(profileId: profileId),
      );
      if (!mounted || requestId != _requestId) {
        return;
      }
      setState(() {
        _layout = layout;
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = null;
      });
      cache.putParent(
        ParentHomeSnapshot(
          profileId: profileId,
          homeLayout: layout,
          completedAssessments: quizzesFromLayoutQuizzes(layout.quizzes),
          cachedAt: DateTime.now(),
        ),
      );
    } on HomeLayoutException catch (error) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (hadRenderableContent) {
        setState(() {
          _isLoading = false;
          _errorMessage = context.readText(
            AppKeys.parentChildDashboardLoadFailed,
          );
        });
        return;
      }
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = context.readText(
          AppKeys.parentChildDashboardLoadFailed,
        );
      });
    }
  }

  void _applySnapshot(ParentHomeSnapshot snapshot) {
    _layout = snapshot.homeLayout;
    _isLoading = false;
    _hasLoaded = true;
    _errorMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final parent = _layout?.parent;
    final entries = roomEntries(parent);
    final pendingExercises =
        parent?.pendingExercises ?? const <HomeLayoutPendingExercise>[];
    final expiredExercises =
        parent?.expiredExercises ?? const <HomeLayoutPendingExercise>[];
    final completions =
        parent?.recentCompletions ?? const <HomeLayoutRecentCompletion>[];
    final isEmptyRoomState =
        !_isLoading && _errorMessage == null && entries.isEmpty;

    final colors = context.themeColors;
    return ColoredBox(
      color: isEmptyRoomState ? colors.surface : colors.pageBackground,
      child: RefreshIndicator(
        color: colors.brandStrong,
        onRefresh: () => _loadLayout(forceRefresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentPadding = isEmptyRoomState
                ? EdgeInsets.only(bottom: widget.bottomPadding)
                : EdgeInsets.fromLTRB(14, 24, 14, widget.bottomPadding + 24);
            final minHeight = isEmptyRoomState
                ? math.max(
                    0.0,
                    constraints.maxHeight -
                        topInset -
                        60 -
                        widget.bottomPadding,
                  )
                : 0.0;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: context.getText(AppKeys.parentRoomTitle),
                    topInset: topInset,
                  ),
                  Padding(
                    padding: contentPadding,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _roomContent(
                          context,
                          entries: entries,
                          pendingExercises: pendingExercises,
                          expiredExercises: expiredExercises,
                          completions: completions,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roomContent(
    BuildContext context, {
    required List<ParentRoomEntry> entries,
    required List<HomeLayoutPendingExercise> pendingExercises,
    required List<HomeLayoutPendingExercise> expiredExercises,
    required List<HomeLayoutRecentCompletion> completions,
  }) {
    final colors = context.themeColors;
    if (_isLoading && !_hasLoaded) {
      return const ParentRoomLoading(key: ValueKey('room-loading'));
    }

    if (_errorMessage != null && entries.isEmpty) {
      return _roomFadeIn(
        markOnEnd: true,
        child: ParentRoomStateCard(
          key: const ValueKey('room-error'),
          icon: Icons.cloud_off_rounded,
          title: context.getText(AppKeys.historyLoadErrorTitle),
          message: _errorMessage!,
          onTap: () => _loadLayout(forceRefresh: true),
        ),
      );
    }

    if (entries.isEmpty) {
      return ParentRoomSelectStudentCard(
        key: const ValueKey('room-empty'),
        onChooseProfile: widget.onOpenProfileMenu,
        onCreateProfile: _openCreateStudentProfile,
      );
    }

    return Column(
      key: const ValueKey('room-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _roomFadeIn(
          order: 0,
          child: AppResponsiveCardGroup(
            children: [
              for (final entry in entries)
                AppSummaryCard(
                  label: profileDisplayName(context, entry.child),
                  title: roomClassName(context, entry.classroom),
                  description: roomTeacherName(context, entry),
                  onTap: () => _openRoomDetail(entry),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: _roomFadeIn(
            order: 1,
            child: AppContentSection(
              title: context.formatText(AppKeys.parentTasksCountTitle, {
                'count': pendingExercises.length + expiredExercises.length,
              }),
              onViewAll: widget.onOpenClassroomTab,
              child: pendingExercises.isEmpty && expiredExercises.isEmpty
                  ? ParentEmptyTaskLine(
                      icon: Icons.assignment_turned_in_outlined,
                      text: context.getText(AppKeys.studentNoHomeworkTitle),
                    )
                  : Column(
                      children: [
                        for (final pending in pendingExercises.take(3)) ...[
                          ParentPendingTaskListItem(pending: pending),
                          if (pending != pendingExercises.take(3).last ||
                              expiredExercises.isNotEmpty)
                            Divider(
                              height: 24,
                              indent: 62,
                              color: colors.border,
                            ),
                        ],
                        for (final expired in expiredExercises.take(3)) ...[
                          ParentPendingTaskListItem(
                            pending: expired,
                            isExpired: true,
                            onTap: () => showExpiredExerciseMessage(context),
                          ),
                          if (expired != expiredExercises.take(3).last)
                            Divider(
                              height: 24,
                              indent: 62,
                              color: colors.border,
                            ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: _roomFadeIn(
            order: 2,
            markOnEnd: true,
            child: AppContentSection(
              title: context.getText(AppKeys.assessmentResultTitle),
              onViewAll: widget.onOpenClassroomTab,
              child: completions.isEmpty
                  ? ParentEmptyTaskLine(
                      icon: Icons.fact_check_outlined,
                      text: context.getText(AppKeys.noCompletedHomeworkTitle),
                    )
                  : Column(
                      children: [
                        for (final completion in completions.take(5)) ...[
                          ParentCompletedTaskListItem(
                            completion: completion,
                            onTap: () => _openCompletionResult(completion),
                          ),
                          if (completion != completions.take(5).last)
                            Divider(
                              height: 24,
                              indent: 62,
                              color: colors.border,
                            ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCompletionResult(HomeLayoutRecentCompletion completion) {
    final quiz = quizFromRecentCompletion(completion);
    final quizId = quiz.quizId ?? quiz.id;
    if (quizId == null || quizId <= 0) {
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
      ),
    );
  }

  void _openRoomDetail(ParentRoomEntry entry) {
    HapticFeedback.selectionClick();
    final parent = _layout?.parent;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParentRoomDetailScreen(
          entry: entry,
          pendingExercises: pendingForRoomEntry(parent, entry),
          expiredExercises: expiredForRoomEntry(parent, entry),
          completions: completionsForRoomEntry(parent, entry),
          exerciseService: widget.assignmentService,
          onRefreshLayout: _loadLayout,
        ),
      ),
    );
  }

  Future<void> _openCreateStudentProfile() async {
    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Material(
          color: context.themeColors.pageBackground,
          child: SafeArea(
            child: SettingTab.page(
              user: widget.user,
              profiles: widget.profiles,
              activeProfile: widget.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.onActivateProfile,
              onRefreshProfiles: widget.onRefreshProfiles,
              onProfileSaved: widget.onProfileSaved,
              bottomPadding: 0,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.onRefreshProfiles();
    if (mounted) {
      await _loadLayout(forceRefresh: true);
    }
  }
}
