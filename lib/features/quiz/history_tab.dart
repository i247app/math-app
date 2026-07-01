import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_result_screen.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/quiz/cache/quiz_cache.dart';
import 'package:numi_flutter/features/quiz/cache/quiz_history_homework_cache.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/shared/widgets/score_progress_ring.dart';
import 'package:google_fonts/google_fonts.dart';

part 'widgets/history_tab/history_header.dart';
part 'widgets/history_tab/history_search_field.dart';
part 'widgets/history_tab/history_filter.dart';
part 'widgets/history_tab/history_type_tabs.dart';
part 'widgets/history_tab/history_type_tab_button.dart';
part 'widgets/history_tab/history_body.dart';
part 'widgets/history_tab/open_quiz_review.dart';
part 'widgets/history_tab/open_homework_result.dart';
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
part 'widgets/history_tab/score_badge_colors.dart';
part 'widgets/history_tab/history_date_parts.dart';
part 'widgets/history_tab/quiz_title.dart';
part 'widgets/history_tab/quiz_short_text.dart';
part 'widgets/history_tab/history_homework_title.dart';
part 'widgets/history_tab/history_homework_short_text.dart';
part 'widgets/history_tab/history_homework_date_text.dart';
part 'widgets/history_tab/history_homework_score_text.dart';
part 'widgets/history_tab/history_homework_score_percentage.dart';
part 'widgets/history_tab/score_colors.dart';
part 'widgets/history_tab/quiz_purpose.dart';
part 'widgets/history_tab/is_assessment_quiz.dart';
part 'widgets/history_tab/is_submitted_homework.dart';
part 'widgets/history_tab/compare_quiz_history_descending.dart';
part 'widgets/history_tab/compare_homework_history_descending.dart';
part 'widgets/history_tab/history_date_value.dart';
part 'widgets/history_tab/metadata_int.dart';
part 'widgets/history_tab/history_date_parts_2.dart';
part 'widgets/history_tab/two_digits.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF5D4A54);
const _deepInk = Color(0xFF1F2B2B);
const _navy = Color(0xFF083B78);
const _orange = Color(0xFFDE8C4B);
const _historyBackground = Color(0xFFEEF9FB);
const _cardBorder = Color(0xFFE3DDDF);
const _activeTab = Color(0xFFFF704D);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

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
  late final QuizService _quizService =
      widget.quizService ?? (_useFakeQuizApi ? const FakeQuizApi() : QuizApi());
  late final ClassroomService _classroomService = widget.classroomService;
  late final ClassroomExerciseService _assignmentService =
      widget.assignmentService;
  final TextEditingController _searchController = TextEditingController();

  List<GeneratedQuiz> _assessmentQuizzes = const <GeneratedQuiz>[];
  List<ClassroomExercise> _homeworkExercises = const <ClassroomExercise>[];
  bool _isLoading = true;
  String? _assessmentErrorMessage;
  String? _homeworkErrorMessage;
  int _loadRequestId = 0;
  _HistoryFilter _selectedFilter = _HistoryFilter.homework;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  Future<void> _loadHistory({bool forceRefresh = false}) async {
    final requestId = ++_loadRequestId;
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (profileId == null) {
      setState(() {
        _isLoading = false;
        _assessmentErrorMessage = context.readText(AppKeys.noAccountForHistory);
        _homeworkErrorMessage = _assessmentErrorMessage;
        _assessmentQuizzes = const <GeneratedQuiz>[];
        _homeworkExercises = const <ClassroomExercise>[];
      });
      return;
    }

    final cachedQuizzes = QuizCache.peekList(profileId: profileId);
    final cachedHomework = QuizHistoryHomeworkCache.peekSubmittedHomework(
      profileId,
    );
    final hasCachedData = cachedQuizzes != null || cachedHomework != null;
    if (hasCachedData) {
      setState(() {
        if (cachedQuizzes != null) {
          _assessmentQuizzes =
              cachedQuizzes.where(_isAssessmentQuiz).toList(growable: false)
                ..sort(_compareQuizHistoryDescending);
          _assessmentErrorMessage = null;
        }
        if (cachedHomework != null) {
          _homeworkExercises =
              cachedHomework.where(_isSubmittedHomework).toList(growable: false)
                ..sort(_compareHomeworkHistoryDescending);
          _homeworkErrorMessage = null;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
        _assessmentErrorMessage = null;
        _homeworkErrorMessage = null;
      });
    }

    final shouldRefresh =
        forceRefresh ||
        !QuizCache.isListFresh(profileId: profileId) ||
        !QuizHistoryHomeworkCache.isFresh(profileId);
    if (!shouldRefresh) {
      return;
    }

    final historyLoadFailedMessage = context.readText(
      AppKeys.historyLoadFailed,
    );
    final homeworkLoadFailedMessage = context.readText(
      AppKeys.studentHomeworkLoadFailed,
    );
    var assessmentQuizzes = const <GeneratedQuiz>[];
    var homeworkExercises = const <ClassroomExercise>[];
    String? assessmentError;
    String? homeworkError;

    await Future.wait<void>([
      QuizCache.loadList(
            service: _quizService,
            profileId: profileId,
            forceRefresh: forceRefresh || cachedQuizzes != null,
          )
          .then((quizzes) {
            assessmentQuizzes =
                quizzes.where(_isAssessmentQuiz).toList(growable: false)
                  ..sort(_compareQuizHistoryDescending);
          })
          .catchError((Object error) {
            assessmentError = _assessmentHistoryErrorMessage(
              error,
              historyLoadFailedMessage,
            );
          }),
      _loadSubmittedHomework(
            profileId,
            forceRefresh: forceRefresh || cachedHomework != null,
          )
          .then((exercises) {
            homeworkExercises = exercises;
          })
          .catchError((Object error) {
            homeworkError = _homeworkHistoryErrorMessage(
              error,
              homeworkLoadFailedMessage,
            );
          }),
    ]);

    if (!mounted || requestId != _loadRequestId) {
      return;
    }
    setState(() {
      _assessmentQuizzes = assessmentQuizzes;
      _homeworkExercises = homeworkExercises;
      _assessmentErrorMessage = assessmentError;
      _homeworkErrorMessage = homeworkError;
      _isLoading = false;
    });
  }

  Future<List<ClassroomExercise>> _loadSubmittedHomework(
    int profileId, {
    bool forceRefresh = false,
  }) async {
    final exercises = await QuizHistoryHomeworkCache.loadSubmittedHomework(
      classroomService: _classroomService,
      assignmentService: _assignmentService,
      profileId: profileId,
      forceRefresh: forceRefresh,
    );
    return exercises.where(_isSubmittedHomework).toList(growable: false)
      ..sort(_compareHomeworkHistoryDescending);
  }

  String _assessmentHistoryErrorMessage(Object error, String fallbackMessage) {
    return error is QuizException ? error.message : fallbackMessage;
  }

  String _homeworkHistoryErrorMessage(Object error, String fallbackMessage) {
    if (error is ClassroomException) {
      return error.message;
    }
    if (error is ClassroomExerciseException) {
      return error.message;
    }
    return fallbackMessage;
  }

  void _refreshSearch() {
    setState(() {});
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    return _assessmentQuizzes.where((quiz) {
      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        _quizTitle(context, quiz),
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
    return _homeworkExercises.where((exercise) {
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
    final quizzes = _filteredQuizzes;
    final homeworkExercises = _filteredHomeworkExercises;
    final selectedItemsCount = _selectedFilter == _HistoryFilter.homework
        ? homeworkExercises.length
        : quizzes.length;
    final selectedErrorMessage = _selectedFilter == _HistoryFilter.homework
        ? _homeworkErrorMessage
        : _assessmentErrorMessage;

    return ColoredBox(
      color: _historyBackground,
      child: SingleChildScrollView(
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
                isLoading: _isLoading,
                errorMessage: selectedErrorMessage,
                selectedFilter: _selectedFilter,
                selectedItemsCount: selectedItemsCount,
                quizzes: quizzes,
                homeworkExercises: homeworkExercises,
                onRetry: () => _loadHistory(forceRefresh: true),
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
