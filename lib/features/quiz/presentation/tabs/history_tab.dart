import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/quiz/application/history_controller.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_body.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_filter.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_header.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_short_text.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_title.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_title.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_search_field.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_type_tabs.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.classroomService,
    required this.assignmentService,
    this.quizService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
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

  HistoryFilter _selectedFilter = HistoryFilter.homework;

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
        historyQuizTitle(context, quiz),
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
        historyHomeworkTitle(context, exercise),
        historyHomeworkShortText(context, exercise) ?? '',
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

  void _selectFilter(HistoryFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: context.themeColors.pageBackground,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final quizzes = _filteredQuizzes;
          final homeworkExercises = _filteredHomeworkExercises;
          final selectedItemsCount = _selectedFilter == HistoryFilter.homework
              ? homeworkExercises.length
              : quizzes.length;
          final selectedErrorMessage = _selectedFilter == HistoryFilter.homework
              ? _controller.homeworkErrorMessage
              : _controller.assessmentErrorMessage;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: widget.bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                HistoryHeader(topInset: topInset),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HistorySearchField(controller: _searchController),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HistoryTypeTabs(
                    selectedFilter: _selectedFilter,
                    onSelected: _selectFilter,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HistoryBody(
                    isLoading: _selectedFilter == HistoryFilter.homework
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
