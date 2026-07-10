import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/otp_auth_api.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/homework/presentation/homework_review_screen.dart';
import 'package:numi/features/profile/active_profile_session.dart';
import 'package:numi/features/quiz/controllers/history_controller.dart';
import 'package:numi/features/quiz/quiz_api.dart';
import 'package:numi/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_date_text.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_metadata_int.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_purpose.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';
import 'package:google_fonts/google_fonts.dart';

part 'widgets/history_tab/history_header.dart';
part 'widgets/history_tab/history_search_field.dart';
part 'widgets/history_tab/history_filter.dart';
part 'widgets/history_tab/history_type_tabs.dart';
part 'widgets/history_tab/history_type_tab_button.dart';
part 'widgets/history_tab/history_body.dart';
part 'widgets/history_detail/history_open_quiz_review.dart';
part 'widgets/history_detail/history_open_homework_result.dart';
part 'widgets/history_tab/history_quiz_card.dart';
part 'widgets/history_tab/history_homework_card.dart';
part 'widgets/history_tab/history_meta_row.dart';
part 'widgets/history_tab/history_meta_item.dart';
part 'widgets/history_tab/history_score_badge.dart';
part 'widgets/history_tab/history_incomplete_badge.dart';
part 'widgets/history_tab/history_submitted_badge.dart';
part 'widgets/history_tab/history_loading_state.dart';
part 'widgets/history_tab/history_loading_state_state.dart';
part 'widgets/history_tab/history_skeleton_card.dart';
part 'widgets/history_tab/history_skeleton_block.dart';
part 'widgets/history_tab/history_message_state.dart';
part 'widgets/history_tab/history_score_badge_colors.dart';
part 'widgets/history_tab/history_date_parts.dart';
part 'widgets/history_tab/history_quiz_title.dart';
part 'widgets/history_tab/history_quiz_short_text.dart';
part 'widgets/history_tab/history_homework_title.dart';
part 'widgets/history_tab/history_homework_short_text.dart';
part 'widgets/history_tab/history_homework_score_text.dart';
part 'widgets/history_tab/history_homework_score_percentage.dart';
part 'widgets/history_tab/history_score_colors.dart';
part 'widgets/history_tab/history_date_parts_from_iso.dart';
part 'widgets/history_tab/history_two_digits.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    required this.classroomService,
    required this.assignmentService,
    this.quizService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final ClassroomService classroomService;
  final ClassroomExerciseService assignmentService;
  final QuizService? quizService;
  final int activeRefreshTick;
  final bool isActive;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late final HistoryController _controller;
  final TextEditingController _searchController = TextEditingController();

  _HistoryFilter _selectedFilter = _HistoryFilter.homework;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController(
      quizService: widget.quizService ?? QuizApi(),
      classroomService: widget.classroomService,
      assignmentService: widget.assignmentService,
    );
    _searchController.addListener(_refreshSearch);
    if (widget.isActive) {
      _loadHistory();
    }
  }

  @override
  void didUpdateWidget(covariant HistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadHistory();
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
    if (oldWidget.user?.id != widget.user?.id || oldProfileId != profileId) {
      _loadHistory();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadHistory(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory({bool forceRefresh = false}) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    return _controller.loadHistory(
      profileId: profileId,
      forceRefresh: forceRefresh,
    );
  }

  void _refreshSearch() {
    setState(() {});
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    return _controller.assessmentQuizzes.where((quiz) {
      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        _historyQuizTitle(context, quiz),
        quiz.shortText ?? '',
        quiz.purpose ?? '',
        quiz.typeOfQuiz ?? '',
        quiz.type ?? '',
        quiz.quizStatus ?? '',
        quiz.grading?.aiDetectGrade ?? '',
        ...quiz.questions.map((question) => question.questionName),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  List<ClassroomExercise> get _filteredHomeworkExercises {
    final query = _searchController.text.trim().toLowerCase();
    return _controller.homeworkExercises.where((exercise) {
      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        _historyHomeworkTitle(context, exercise),
        _historyHomeworkShortText(context, exercise) ?? '',
        exercise.chapterName ?? '',
        exercise.lessonName ?? '',
        exercise.purpose ?? '',
        exercise.status ?? '',
        exercise.submissionStatus ?? '',
        ...exercise.questions.map((question) => question.displayPrompt ?? ''),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  void _selectFilter(_HistoryFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: context.themeColors.pageBackground,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final quizzes = _filteredQuizzes;
          final homeworkExercises = _filteredHomeworkExercises;
          final selectedItemsCount = _selectedFilter == _HistoryFilter.homework
              ? homeworkExercises.length
              : quizzes.length;
          final selectedErrorMessage =
              _selectedFilter == _HistoryFilter.homework
              ? _controller.homeworkErrorMessage
              : _controller.assessmentErrorMessage;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: widget.bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HistoryHeader(scale: scale, topInset: topInset),
                SizedBox(height: 12 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: _HistorySearchField(
                    controller: _searchController,
                    scale: scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: _HistoryTypeTabs(
                    selectedFilter: _selectedFilter,
                    onSelected: _selectFilter,
                    scale: scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: _HistoryBody(
                    isLoading: _selectedFilter == _HistoryFilter.homework
                        ? _controller.isLoadingHomework
                        : _controller.isLoadingAssessments,
                    errorMessage: selectedErrorMessage,
                    selectedFilter: _selectedFilter,
                    selectedItemsCount: selectedItemsCount,
                    quizzes: quizzes,
                    homeworkExercises: homeworkExercises,
                    profileId: ActiveProfileSession.profileStableId(
                      widget.activeProfile,
                    ),
                    exerciseService: widget.assignmentService,
                    onRetry: () => _loadHistory(forceRefresh: true),
                    scale: scale,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
