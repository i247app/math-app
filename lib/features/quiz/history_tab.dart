import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/quiz_review_screen.dart';
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
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late final QuizService _quizService =
      _useFakeQuizApi ? const FakeQuizApi() : QuizApi();
  final TextEditingController _searchController = TextEditingController();

  List<GeneratedQuiz> _quizzes = const <GeneratedQuiz>[];
  bool _isLoading = true;
  String? _errorMessage;
  int _loadRequestId = 0;
  _HistoryQuizFilter _selectedFilter = _HistoryQuizFilter.assessment;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant HistoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (oldWidget.user?.id != widget.user?.id || oldProfileId != profileId) {
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
        _errorMessage = context.readText(AppKeys.noAccountForHistory);
        _quizzes = const <GeneratedQuiz>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quizzes = await _quizService.listQuizzes(profileId: profileId);
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } on QuizException catch (error) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }
      setState(() {
        _errorMessage = context.readText(AppKeys.historyLoadFailed);
        _isLoading = false;
      });
    }
  }

  void _refreshSearch() {
    setState(() {});
  }

  List<GeneratedQuiz> get _filteredQuizzes {
    final query = _searchController.text.trim().toLowerCase();
    return _quizzes.where((quiz) {
      if (_quizPurpose(quiz) != _selectedFilter.apiType) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        _quizTitle(context, quiz),
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

  void _selectFilter(_HistoryQuizFilter filter) {
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
                errorMessage: _errorMessage,
                quizzes: quizzes,
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
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.historyTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.title,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.scale,
  });

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
            child: Icon(
              Icons.search_rounded,
              color: _navy,
              size: 22 * scale,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: HapticFeedback.selectionClick,
            icon: Icon(
              Icons.tune_rounded,
              color: _navy,
              size: 22 * scale,
            ),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: 11 * scale, horizontal: 10 * scale),
        ),
      ),
    );
  }
}

enum _HistoryQuizFilter {
  assessment('ASSESSMENT', AppKeys.assessmentTab),
  practice('PRACTICE', AppKeys.practiceTab);

  const _HistoryQuizFilter(this.apiType, this.labelKey);

  final String apiType;
  final String labelKey;
}

class _HistoryTypeTabs extends StatelessWidget {
  const _HistoryTypeTabs({
    required this.selectedFilter,
    required this.onSelected,
    required this.scale,
  });

  final _HistoryQuizFilter selectedFilter;
  final ValueChanged<_HistoryQuizFilter> onSelected;
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
          for (final filter in _HistoryQuizFilter.values)
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

  final _HistoryQuizFilter filter;
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
    required this.quizzes,
    required this.onRetry,
    required this.scale,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<GeneratedQuiz> quizzes;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _HistoryLoadingState(scale: scale);
    }

    if (errorMessage != null) {
      return _HistoryMessageState(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.historyLoadErrorTitle),
        subtitle: errorMessage!,
        actionLabel: context.getText(AppKeys.retry).toUpperCase(),
        onAction: onRetry,
        scale: scale,
      );
    }

    if (quizzes.isEmpty) {
      return _HistoryMessageState(
        icon: Icons.history_toggle_off_rounded,
        title: context.getText(AppKeys.noHistoryTitle),
        subtitle: context.getText(AppKeys.noHistoryMessage),
        scale: scale,
      );
    }

    return Column(
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
    );
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
      builder: (_) => QuizReviewScreen(
        quizId: quizId,
        initialQuiz: quiz,
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
          constraints: BoxConstraints(minHeight: 100 * scale),
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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _quizTitle(context, quiz),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _deepInk,
                          fontSize: FontSize.small * scale,
                          fontWeight: FontWeight.w900,
                          height: 1.28,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _navy,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryMetaRow extends StatelessWidget {
  const _HistoryMetaRow({
    required this.parts,
    required this.scale,
  });

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
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: colors.foreground,
                width: 5 * scale,
              ),
            ),
            child: Center(
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

class _HistoryLoadingState extends StatelessWidget {
  const _HistoryLoadingState({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: _cardBorder),
      ),
      child: Center(
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: const CircularProgressIndicator(
            color: _teal,
            strokeWidth: 3,
          ),
        ),
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
  const _ScoreBadgeColors({
    required this.foreground,
    required this.label,
  });

  final Color foreground;
  final String label;
}

class _HistoryDateParts {
  const _HistoryDateParts({
    required this.date,
    required this.time,
  });

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
