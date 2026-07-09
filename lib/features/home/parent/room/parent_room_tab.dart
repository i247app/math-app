import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/home/cache/home_profile_cache.dart';
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/parent/cache/parent_home_snapshot.dart';
import 'package:numi_flutter/features/home/widgets/home_dashboard_args.dart';
import 'package:numi_flutter/features/home/widgets/home_tab_header.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/features/settings/setting_tab.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_home_entrance.dart';
import 'package:numi_flutter/features/home/parent/home/helpers/parent_child_dashboard_helpers.dart';
import 'package:numi_flutter/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi_flutter/features/home/parent/room/models/parent_room_entry.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_class_grid.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_detail_screen.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_list_section.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_loading.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_select_student_card.dart';
import 'package:numi_flutter/features/home/parent/room/widgets/parent_room_state_card.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_completed_task_list_item.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_empty_task_line.dart';
import 'package:numi_flutter/features/home/parent/shared/widgets/parent_pending_task_list_item.dart';

class ParentRoomTab extends StatefulWidget {
  const ParentRoomTab({super.key, required this.args});

  final HomeDashboardArgs args;

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
    if (widget.args.isActive) {
      _loadLayout();
    }
  }

  @override
  void didUpdateWidget(covariant ParentRoomTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.args.isActive && widget.args.isActive) {
      _loadLayout(forceRefresh: true);
      return;
    }
    if (!widget.args.isActive) {
      return;
    }
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.args.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.args.activeProfile,
    );
    if (oldProfileId != profileId ||
        oldWidget.args.activeRefreshTick != widget.args.activeRefreshTick) {
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

    return ParentHomeEntrance(
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
      widget.args.activeProfile,
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
      final layout = await _homeLayoutService.getLayout(profileId: profileId);
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
    final scale = widget.args.scale;
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
      child: Column(
        children: [
          HomeTabHeader(
            title: context.getText(AppKeys.navRoom),
            topInset: topInset,
            scale: scale,
          ),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF339395),
              onRefresh: () => _loadLayout(forceRefresh: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentPadding = isEmptyRoomState
                      ? EdgeInsets.only(bottom: widget.args.bottomPadding)
                      : EdgeInsets.fromLTRB(
                          14 * scale,
                          24 * scale,
                          14 * scale,
                          widget.args.bottomPadding + 24 * scale,
                        );
                  final minHeight = isEmptyRoomState
                      ? math.max(
                          0.0,
                          constraints.maxHeight - widget.args.bottomPadding,
                        )
                      : 0.0;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
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
                  );
                },
              ),
            ),
          ),
        ],
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
      return _roomFadeIn(
        markOnEnd: true,
        child: ParentRoomSelectStudentCard(
          onChooseProfile: widget.args.onOpenProfileMenu,
          onCreateProfile: _openCreateStudentProfile,
        ),
      );
    }

    return Column(
      key: const ValueKey('room-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _roomFadeIn(
          order: 0,
          child: ParentRoomClassGrid(entries: entries, onTap: _openRoomDetail),
        ),
        const SizedBox(height: 18),
        _roomFadeIn(
          order: 1,
          child: ParentRoomListSection(
            title: context.formatText(AppKeys.parentTasksCountTitle, {
              'count': pendingExercises.length + expiredExercises.length,
            }),
            onViewAll: widget.args.onOpenClassroomTab,
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
                          const Divider(
                            height: 24,
                            indent: 62,
                            color: Color(0xFFE9EEF2),
                          ),
                      ],
                      for (final expired in expiredExercises.take(3)) ...[
                        ParentPendingTaskListItem(
                          pending: expired,
                          isExpired: true,
                          onTap: () => showExpiredExerciseMessage(context),
                        ),
                        if (expired != expiredExercises.take(3).last)
                          const Divider(
                            height: 24,
                            indent: 62,
                            color: Color(0xFFE9EEF2),
                          ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 14),
        _roomFadeIn(
          order: 2,
          markOnEnd: true,
          child: ParentRoomListSection(
            title: context.getText(AppKeys.assessmentResultTitle),
            onViewAll: widget.args.onOpenClassroomTab,
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
                          const Divider(
                            height: 24,
                            indent: 62,
                            color: Color(0xFFE9EEF2),
                          ),
                      ],
                    ],
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
          exerciseService: widget.args.assignmentService,
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
              user: widget.args.user,
              profiles: widget.args.profiles,
              activeProfile: widget.args.activeProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: widget.args.onActivateProfile,
              onRefreshProfiles: widget.args.onRefreshProfiles,
              onProfileSaved: widget.args.onProfileSaved,
              bottomPadding: 0,
              scale: widget.args.scale,
              initialView: SettingPageView.profile,
              isPushedPage: true,
              openAddProfileOnStart: true,
            ),
          ),
        ),
      ),
    );
    await widget.args.onRefreshProfiles();
    if (mounted) {
      await _loadLayout(forceRefresh: true);
    }
  }
}
