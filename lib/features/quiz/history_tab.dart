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
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
import 'package:numi_flutter/shared/widgets/score_progress_ring.dart';
import 'package:google_fonts/google_fonts.dart';

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
      _loadHistory();
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
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

    setState(() {
      _isLoading = true;
      _assessmentErrorMessage = null;
      _homeworkErrorMessage = null;
    });

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

    try {
      final quizzes = await _quizService.listQuizzes(profileId: profileId);
      assessmentQuizzes =
          quizzes.where(_isAssessmentQuiz).toList(growable: false)
            ..sort(_compareQuizHistoryDescending);
    } on QuizException catch (error) {
      assessmentError = error.message;
    } catch (_) {
      assessmentError = historyLoadFailedMessage;
    }

    try {
      homeworkExercises = await _loadSubmittedHomework(profileId);
    } on ClassroomException catch (error) {
      homeworkError = error.message;
    } on ClassroomExerciseException catch (error) {
      homeworkError = error.message;
    } catch (_) {
      homeworkError = homeworkLoadFailedMessage;
    }

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

  Future<List<ClassroomExercise>> _loadSubmittedHomework(int profileId) async {
    final classrooms = await _classroomService.listMyJoinedClassrooms(
      profileId: profileId,
    );
    final exercises = <ClassroomExercise>[];
    for (final classroom in classrooms) {
      final classroomId = classroom.stableId;
      if (classroomId == null) {
        continue;
      }
      final classroomExercises = await _assignmentService.listExercises(
        classroomId: classroomId,
        profileId: profileId,
        visibility: 'PUBLIC',
        submissionStatus: 'SUBMITTED',
        purpose: classroomExercisePurposeHomework,
      );
      exercises.addAll(classroomExercises.where(_isSubmittedHomework));
    }

    final seenIds = <int>{};
    final deduped = exercises
        .where((exercise) {
          final id = exercise.stableId;
          if (id == null) {
            return true;
          }
          return seenIds.add(id);
        })
        .toList(growable: false);

    return deduped..sort(_compareHomeworkHistoryDescending);
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
                onRetry: _loadHistory,
                scale: scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.scale, required this.topInset});

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF2F2F2), width: 4 * scale),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.historyTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({required this.controller, required this.scale});

  final TextEditingController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30 * scale),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _deepInk,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: context.getText(AppKeys.searchHint),
          hintStyle: TextStyle(
            color: const Color(0xFFD8C5CC),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 14 * scale, right: 6 * scale),
            child: Icon(Icons.search_rounded, color: _navy, size: 22 * scale),
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(Icons.tune_rounded, color: _navy, size: 22 * scale),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 11 * scale,
            horizontal: 10 * scale,
          ),
        ),
      ),
    );
  }
}

enum _HistoryFilter {
  homework(AppKeys.studentHomework),
  assessment(AppKeys.assessmentTab);

  const _HistoryFilter(this.labelKey);

  final String labelKey;
}

class _HistoryTypeTabs extends StatelessWidget {
  const _HistoryTypeTabs({
    required this.selectedFilter,
    required this.onSelected,
    required this.scale,
  });

  final _HistoryFilter selectedFilter;
  final ValueChanged<_HistoryFilter> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36 * scale,
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E8EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final filter in _HistoryFilter.values)
            Expanded(
              child: _HistoryTypeTabButton(
                filter: filter,
                selected: selectedFilter == filter,
                onTap: () => onSelected(filter),
                scale: scale,
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryTypeTabButton extends StatelessWidget {
  const _HistoryTypeTabButton({
    required this.filter,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final _HistoryFilter filter;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _activeTab : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.getText(filter.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : _muted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.isLoading,
    required this.errorMessage,
    required this.selectedFilter,
    required this.selectedItemsCount,
    required this.quizzes,
    required this.homeworkExercises,
    required this.onRetry,
    required this.scale,
  });

  final bool isLoading;
  final String? errorMessage;
  final _HistoryFilter selectedFilter;
  final int selectedItemsCount;
  final List<GeneratedQuiz> quizzes;
  final List<ClassroomExercise> homeworkExercises;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isLoading && selectedItemsCount == 0) {
      return _HistoryLoadingState(scale: scale);
    }

    if (errorMessage != null && selectedItemsCount == 0) {
      return _HistoryMessageState(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.historyLoadErrorTitle),
        subtitle: errorMessage!,
        actionLabel: context.getText(AppKeys.retry).toUpperCase(),
        onAction: onRetry,
        scale: scale,
      );
    }

    if (selectedItemsCount == 0) {
      return _HistoryMessageState(
        icon: Icons.history_toggle_off_rounded,
        title: context.getText(AppKeys.noHistoryTitle),
        subtitle: context.getText(AppKeys.noHistoryMessage),
        scale: scale,
      );
    }

    return switch (selectedFilter) {
      _HistoryFilter.homework => Column(
        children: [
          for (final exercise in homeworkExercises) ...[
            _HistoryHomeworkCard(
              exercise: exercise,
              scale: scale,
              onTap: () => _openHomeworkResult(context, exercise),
            ),
            SizedBox(height: 14 * scale),
          ],
        ],
      ),
      _HistoryFilter.assessment => Column(
        children: [
          for (final quiz in quizzes) ...[
            _HistoryQuizCard(
              quiz: quiz,
              scale: scale,
              onTap: () => _openQuizReview(context, quiz),
            ),
            SizedBox(height: 14 * scale),
          ],
        ],
      ),
    };
  }
}

void _openQuizReview(BuildContext context, GeneratedQuiz quiz) {
  final quizId = quiz.quizId ?? quiz.id;
  if (quizId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.readText(AppKeys.missingQuizId))),
    );
    return;
  }

  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizReviewScreen(quizId: quizId, initialQuiz: quiz),
    ),
  );
}

void _openHomeworkResult(BuildContext context, ClassroomExercise exercise) {
  HapticFeedback.selectionClick();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StudentHomeworkResultScreen(
        summary: StudentHomeworkResultSummary(
          scoreText: _historyHomeworkScoreText(exercise),
          reviewText: context.getText(AppKeys.defaultAiReview),
        ),
      ),
    ),
  );
}

class _HistoryQuizCard extends StatelessWidget {
  const _HistoryQuizCard({
    required this.quiz,
    required this.scale,
    required this.onTap,
  });

  final GeneratedQuiz quiz;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grading = quiz.grading;
    final percent = grading?.scorePercentage;
    final scoreColors = _scoreColors(context, percent);
    final dateParts = _historyDateParts(quiz.createDt);

    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: BoxConstraints(minHeight: 116 * scale),
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            14 * scale,
            10 * scale,
            14 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: _cardBorder, width: 1.3 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (percent != null)
                _HistoryScoreBadge(
                  percentage: percent,
                  colors: scoreColors,
                  scale: scale,
                )
              else
                _HistoryIncompleteBadge(scale: scale),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryMetaRow(parts: dateParts, scale: scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      _quizTitle(context, quiz),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _deepInk,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                        letterSpacing: 0,
                      ),
                    ),
                    if (_quizShortText(quiz) case final shortText?) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: FontSize.small * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.22,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _navy, size: 26 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryHomeworkCard extends StatelessWidget {
  const _HistoryHomeworkCard({
    required this.exercise,
    required this.scale,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scorePercent = _historyHomeworkScorePercentage(exercise);
    final dateParts = _historyDateParts(_historyHomeworkDateText(exercise));
    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          constraints: BoxConstraints(minHeight: 116 * scale),
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            14 * scale,
            10 * scale,
            14 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(color: _cardBorder, width: 1.3 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (scorePercent != null)
                _HistoryScoreBadge(
                  percentage: scorePercent,
                  colors: _scoreColors(context, scorePercent),
                  scale: scale,
                )
              else
                _HistorySubmittedBadge(scale: scale),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HistoryMetaRow(parts: dateParts, scale: scale),
                    SizedBox(height: 7 * scale),
                    Text(
                      _historyHomeworkTitle(context, exercise),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _deepInk,
                        fontSize: FontSize.normal * scale,
                        fontWeight: FontWeight.w800,
                        height: 1.28,
                        letterSpacing: 0,
                      ),
                    ),
                    if (_historyHomeworkShortText(context, exercise)
                        case final shortText?) ...[
                      SizedBox(height: 4 * scale),
                      Text(
                        shortText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: FontSize.small * scale,
                          fontWeight: FontWeight.w500,
                          height: 1.22,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _navy, size: 26 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryMetaRow extends StatelessWidget {
  const _HistoryMetaRow({required this.parts, required this.scale});

  final _HistoryDateParts parts;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14 * scale,
      runSpacing: 5 * scale,
      children: [
        _HistoryMetaItem(
          icon: Icons.calendar_month_outlined,
          label: parts.date,
          scale: scale,
        ),
        _HistoryMetaItem(
          icon: Icons.schedule_rounded,
          label: parts.time,
          scale: scale,
        ),
      ],
    );
  }
}

class _HistoryMetaItem extends StatelessWidget {
  const _HistoryMetaItem({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _muted, size: 18 * scale),
        SizedBox(width: 5 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryScoreBadge extends StatelessWidget {
  const _HistoryScoreBadge({
    required this.percentage,
    required this.colors,
    required this.scale,
  });

  final int percentage;
  final _ScoreBadgeColors colors;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scoreOutOf10 = (percentage / 10).round();
    return SizedBox(
      width: 56 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreProgressRing(
            progress: percentage.clamp(0, 100) / 100,
            color: colors.foreground,
            size: 48 * scale,
            strokeWidth: 5 * scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$scoreOutOf10/10',
                maxLines: 1,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          SizedBox(height: 7 * scale),
          Text(
            colors.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.foreground,
              fontSize: FontSize.caption * 0.77 * scale,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryIncompleteBadge extends StatelessWidget {
  const _HistoryIncompleteBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: Text(
        context.getText(AppKeys.incomplete),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _orange,
          fontSize: FontSize.caption * 0.77 * scale,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HistorySubmittedBadge extends StatelessWidget {
  const _HistorySubmittedBadge({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFE1F8F4),
              shape: BoxShape.circle,
              border: Border.all(
                color: _teal.withValues(alpha: 0.26),
                width: 1.3 * scale,
              ),
            ),
            child: Icon(Icons.check_rounded, color: _teal, size: 26 * scale),
          ),
          SizedBox(height: 7 * scale),
          Text(
            context.getText(AppKeys.studentHomeworkSubmitted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _teal,
              fontSize: FontSize.caption * 0.77 * scale,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoadingState extends StatefulWidget {
  const _HistoryLoadingState({required this.scale});

  final double scale;

  @override
  State<_HistoryLoadingState> createState() => _HistoryLoadingStateState();
}

class _HistoryLoadingStateState extends State<_HistoryLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerWidth = bounds.width * 1.2;
            final start = -shimmerWidth;
            final end = bounds.width;
            final dx = start + (end - start) * _controller.value;
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.72),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0.28, 0.5, 0.72],
            ).createShader(Rect.fromLTWH(dx, 0, shimmerWidth, bounds.height));
          },
          child: child,
        );
      },
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            _HistorySkeletonCard(scale: widget.scale),
            if (index != 2) SizedBox(height: 14 * widget.scale),
          ],
        ],
      ),
    );
  }
}

class _HistorySkeletonCard extends StatelessWidget {
  const _HistorySkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116 * scale,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        14 * scale,
        16 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder, width: 1.3 * scale),
      ),
      child: Row(
        children: [
          _HistorySkeletonBlock(
            width: 54 * scale,
            height: 54 * scale,
            radius: 27 * scale,
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HistorySkeletonBlock(
                      width: 82 * scale,
                      height: 12 * scale,
                      radius: 6 * scale,
                    ),
                    SizedBox(width: 12 * scale),
                    _HistorySkeletonBlock(
                      width: 54 * scale,
                      height: 12 * scale,
                      radius: 6 * scale,
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                _HistorySkeletonBlock(
                  width: 150 * scale,
                  height: 17 * scale,
                  radius: 8 * scale,
                ),
                SizedBox(height: 8 * scale),
                _HistorySkeletonBlock(
                  width: 110 * scale,
                  height: 11 * scale,
                  radius: 6 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySkeletonBlock extends StatelessWidget {
  const _HistorySkeletonBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE3EAEC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _HistoryMessageState extends StatelessWidget {
  const _HistoryMessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.scale,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(26 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: _teal, size: 42 * scale),
          SizedBox(height: 14 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontSize: FontSize.large * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 18 * scale),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: _teal,
                  fontSize: FontSize.caption * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBadgeColors {
  const _ScoreBadgeColors({required this.foreground, required this.label});

  final Color foreground;
  final String label;
}

class _HistoryDateParts {
  const _HistoryDateParts({required this.date, required this.time});

  final String date;
  final String time;
}

String _quizTitle(BuildContext context, GeneratedQuiz quiz) {
  if (quiz.title != null && quiz.title!.trim().isNotEmpty) {
    return quiz.title!;
  }

  final grade = quiz.grading?.aiDetectGrade?.trim();
  final suffix = grade != null && grade.isNotEmpty ? ' $grade' : '';
  final type = _quizPurpose(quiz);

  if (type == 'ASSESSMENT') {
    return '${context.getText(AppKeys.mathAssessment)}$suffix';
  }
  if (type == 'PRACTICE') {
    return '${context.getText(AppKeys.mathPractice)}$suffix';
  }
  return '${context.getText(AppKeys.mathReview)}$suffix';
}

String? _quizShortText(GeneratedQuiz quiz) {
  final shortText = quiz.shortText?.trim();
  if (shortText == null || shortText.isEmpty) {
    return null;
  }
  return shortText;
}

String _historyHomeworkTitle(BuildContext context, ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  if (id != null) {
    return '${context.getText(AppKeys.studentHomework)} #$id';
  }
  return context.getText(AppKeys.studentHomework);
}

String? _historyHomeworkShortText(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final values = <String?>[
    exercise.shortText,
    exercise.description,
    exercise.lessonName,
    exercise.chapterName,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  final count = exercise.numQuestions ?? exercise.questions.length;
  if (count > 0) {
    return context.formatText(AppKeys.teacherAssignmentQuestionCountFormat, {
      'count': count,
    });
  }
  return null;
}

String _historyHomeworkDateText(ClassroomExercise exercise) {
  final values = <String?>[
    exercise.modifyDt,
    exercise.createDt,
    exercise.endDate,
    exercise.startDate,
  ];
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

String _historyHomeworkScoreText(ClassroomExercise exercise) {
  final scorePercent = _historyHomeworkScorePercentage(exercise);
  if (scorePercent != null) {
    final scoreOutOf10 = (scorePercent / 10).round().clamp(0, 10);
    return '$scoreOutOf10/10';
  }
  return '--/10';
}

int? _historyHomeworkScorePercentage(ClassroomExercise exercise) {
  final metadata = exercise.metadata;
  if (metadata == null) {
    return null;
  }

  final percentage = _metadataInt(metadata, const [
    'score_percentage',
    'score',
    'percentage',
  ]);
  if (percentage != null) {
    return percentage.clamp(0, 100);
  }

  final correct = _metadataInt(metadata, const [
    'correct_number',
    'correct_count',
    'correct_answers',
  ]);
  final total = _metadataInt(metadata, const [
    'total_questions',
    'question_count',
    'total',
  ]);
  if (correct != null && total != null && total > 0) {
    return (correct / total * 100).round().clamp(0, 100);
  }
  return null;
}

_ScoreBadgeColors _scoreColors(BuildContext context, int? percent) {
  if (percent == null) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFF0A8A4D),
      label: context.getText(AppKeys.excellent),
    );
  }

  final scoreOutOf10 = (percent / 10).round();

  if (scoreOutOf10 >= 9) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFF0A8A4D), // Green
      label: context.getText(AppKeys.excellent),
    );
  }
  if (scoreOutOf10 >= 7) {
    return _ScoreBadgeColors(
      foreground: const Color(0xFFF4B62D),
      label: context.getText(AppKeys.good),
    );
  }
  if (scoreOutOf10 >= 5) {
    return _ScoreBadgeColors(
      foreground: const Color.fromARGB(255, 244, 135, 45),
      label: context.getText(AppKeys.niceTry),
    );
  }
  return _ScoreBadgeColors(
    foreground: const Color(0xFFD71920),
    label: context.getText(AppKeys.failed),
  );
}

String _quizPurpose(GeneratedQuiz quiz) {
  final purpose = quiz.purpose?.trim();
  if (purpose != null && purpose.isNotEmpty) {
    return purpose.toUpperCase();
  }
  return (quiz.type ?? '').trim().toUpperCase();
}

bool _isAssessmentQuiz(GeneratedQuiz quiz) {
  return _quizPurpose(quiz) == 'ASSESSMENT';
}

bool _isSubmittedHomework(ClassroomExercise exercise) {
  final purpose = exercise.purpose?.trim().toUpperCase();
  final isHomework =
      purpose == null ||
      purpose.isEmpty ||
      purpose == classroomExercisePurposeHomework;
  return isHomework &&
      exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

int _compareQuizHistoryDescending(GeneratedQuiz first, GeneratedQuiz second) {
  final firstDate = _historyDateValue(first.createDt);
  final secondDate = _historyDateValue(second.createDt);
  return secondDate.compareTo(firstDate);
}

int _compareHomeworkHistoryDescending(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _historyDateValue(_historyHomeworkDateText(first));
  final secondDate = _historyDateValue(_historyHomeworkDateText(second));
  return secondDate.compareTo(firstDate);
}

DateTime _historyDateValue(String? value) {
  return DateTime.tryParse(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

int? _metadataInt(Map<String, dynamic> metadata, List<String> keys) {
  for (final key in keys) {
    final value = metadata[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

_HistoryDateParts _historyDateParts(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return const _HistoryDateParts(date: '--/--/----', time: '--:--');
  }

  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) {
    return _HistoryDateParts(date: isoDate, time: '--:--');
  }

  return _HistoryDateParts(
    date:
        '${_twoDigits(parsed.day)}/${_twoDigits(parsed.month)}/${parsed.year}',
    time: '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}',
  );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
