import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';

const _reviewBackground = Color(0xFFEEF9FB);
const _teal = Color(0xFF007A78);
const _tealSoft = Color(0xFFC8FBF1);
const _tealLight = Color(0xFFEFFFFC);
const _navy = Color(0xFF063A7B);
const _green = Color(0xFF12B8A7);
const _red = Color(0xFFD71920);
const _redSoft = Color(0xFFFFF5F6);
const _orange = Color(0xFFFF6A1A);
const _deepInk = Color(0xFF1F2B2B);
const _cardBorder = Color(0xFFDCE8EA);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

enum _ReviewMode { retry, result }

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({super.key, required this.quizId, this.initialQuiz});

  final int quizId;
  final GeneratedQuiz? initialQuiz;

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  late final QuizService _quizService = _useFakeQuizApi
      ? const FakeQuizApi()
      : QuizApi();

  GeneratedQuiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  _ReviewMode _mode = _ReviewMode.retry;
  final Map<int, String> _selectedAnswers = <int, String>{};

  @override
  void initState() {
    super.initState();
    _quiz = widget.initialQuiz;
    _seedSelectedAnswers(widget.initialQuiz);
    _loadQuizDetail();
  }

  Future<void> _loadQuizDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quiz = await _quizService.getQuizDetail(widget.quizId);
      if (!mounted) {
        return;
      }

      setState(() {
        _quiz = quiz;
        _seedSelectedAnswers(quiz);
        _isLoading = false;
        if (_selectedIndex >= quiz.questions.length) {
          _selectedIndex = 0;
        }
      });
    } on QuizException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = AppStrings.current(AppKeys.quizDetailLoadFailed);
        _isLoading = false;
      });
    }
  }

  void _selectQuestion(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _selectMode(_ReviewMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _mode = mode);
  }

  void _selectAnswer(int questionNumber, String label) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswers[questionNumber] = label.trim().toUpperCase();
    });
  }

  void _goToPreviousQuestion() {
    if (_selectedIndex <= 0) {
      return;
    }
    _selectQuestion(_selectedIndex - 1);
  }

  void _goToNextQuestion() {
    final lastIndex = (_quiz?.questions.length ?? 0) - 1;
    if (_selectedIndex >= lastIndex) {
      return;
    }
    _selectQuestion(_selectedIndex + 1);
  }

  void _seedSelectedAnswers(GeneratedQuiz? quiz) {
    if (quiz == null) {
      return;
    }
    _selectedAnswers.clear();
    if (quiz.answers.isEmpty) {
      return;
    }
    for (final answer in quiz.answers) {
      final label = answer.label.trim().toUpperCase();
      if (label.isNotEmpty) {
        _selectedAnswers[answer.questionNumber] = label;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;

    return Scaffold(
      backgroundColor: _reviewBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ReviewHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: quiz == null
                  ? _isLoading
                        ? const _ReviewLoadingContent(showHeaderSkeleton: false)
                        : _ReviewStatePanel(
                            isLoading: false,
                            message: _errorMessage,
                            onRetry: _loadQuizDetail,
                          )
                  : _ReviewContent(
                      quiz: quiz,
                      selectedIndex: _selectedIndex,
                      mode: _mode,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      onRetry: _loadQuizDetail,
                      onModeSelected: _selectMode,
                      onQuestionSelected: _selectQuestion,
                      selectedAnswers: _selectedAnswers,
                      onAnswerSelected: _selectAnswer,
                      onPrevious: _goToPreviousQuestion,
                      onNext: _goToNextQuestion,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF2F2F2), width: 4)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF339395),
                size: 28,
              ),
              tooltip: context.getText(AppKeys.back),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              context.getText(AppKeys.quizDetailTitle),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
    required this.quiz,
    required this.selectedIndex,
    required this.mode,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onModeSelected,
    required this.onQuestionSelected,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final GeneratedQuiz quiz;
  final int selectedIndex;
  final _ReviewMode mode;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<_ReviewMode> onModeSelected;
  final ValueChanged<int> onQuestionSelected;
  final Map<int, String> selectedAnswers;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final questions = quiz.questions;
    final safeIndex = questions.isEmpty
        ? 0
        : selectedIndex.clamp(0, questions.length - 1);
    final question = questions.isEmpty ? null : questions[safeIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) const LinearProgressIndicator(color: _navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            _InlineError(message: errorMessage!, onRetry: onRetry),
            const SizedBox(height: 10),
          ],
          _ModeTabs(selectedMode: mode, onSelected: onModeSelected),
          const SizedBox(height: 12),
          _StatsCard(quiz: quiz),
          const SizedBox(height: 11),
          if (isLoading && question == null)
            const _ReviewQuestionLoadingSection()
          else if (question == null)
            _ReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyQuizQuestions),
              onRetry: onRetry,
            )
          else if (mode == _ReviewMode.result)
            _ResultQuestionList(quiz: quiz, selectedAnswers: selectedAnswers)
          else
            _RetryQuestionView(
              questions: questions,
              selectedIndex: safeIndex,
              question: question,
              selectedAnswers: selectedAnswers,
              onQuestionSelected: onQuestionSelected,
              onAnswerSelected: onAnswerSelected,
              onPrevious: onPrevious,
              onNext: onNext,
            ),
        ],
      ),
    );
  }
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selectedMode, required this.onSelected});

  final _ReviewMode selectedMode;
  final ValueChanged<_ReviewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTabButton(
              label: context.getText(AppKeys.testAgain),
              selected: selectedMode == _ReviewMode.retry,
              onTap: () => onSelected(_ReviewMode.retry),
            ),
          ),
          Expanded(
            child: _ModeTabButton(
              label: context.getText(AppKeys.viewResult),
              selected: selectedMode == _ReviewMode.result,
              onTap: () => onSelected(_ReviewMode.result),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabButton extends StatelessWidget {
  const _ModeTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? _teal : _deepInk,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.quiz});

  final GeneratedQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final total = quiz.grading?.totalQuestions ?? quiz.questions.length;
    final correct = quiz.grading?.correctNumber ?? _computedCorrectCount(quiz);
    final wrong = total > correct ? total - correct : 0;
    final time = _timeLabel(quiz);

    return _ReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            icon: Icons.quiz_outlined,
            iconColor: _teal,
            iconBackground: const Color(0xFFDDF1FF),
            valueColor: _teal,
            value: '$total',
            label: context.getText(AppKeys.totalQuestions),
          ),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: _teal,
            iconBackground: _tealSoft,
            valueColor: _teal,
            value: '$correct',
            label: context.getText(AppKeys.correct),
          ),
          _StatItem(
            icon: Icons.cancel_outlined,
            iconColor: _red,
            iconBackground: const Color(0xFFFFDCDD),
            valueColor: _red,
            value: '$wrong',
            label: context.getText(AppKeys.incorrect),
          ),
          _StatItem(
            icon: Icons.schedule_rounded,
            iconColor: _orange,
            iconBackground: const Color(0xFFFFEAD6),
            valueColor: _orange,
            value: time,
            label: context.getText(AppKeys.time),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.valueColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color valueColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _deepInk,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionSelector extends StatelessWidget {
  const _QuestionSelector({
    required this.questions,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(questions.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(
                right: index == questions.length - 1 ? 0 : 11,
              ),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? _teal : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _teal, width: 1.2),
                  ),
                  child: _CenteredText(
                    '${index + 1}',
                    color: selected ? Colors.white : _teal,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CenteredText extends StatelessWidget {
  const _CenteredText(
    this.text, {
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.verticalOffset = 0,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          strutStyle: StrutStyle(
            fontSize: fontSize,
            height: 1,
            forceStrutHeight: true,
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: _QuestionBadge(
              number: question.questionNumber,
              color: _tealSoft,
              textColor: _teal,
            ),
          ),
          Center(
            child: Text(
              question.questionName,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: const Color(0xFF3C4B4C),
                fontSize: _questionFontSize(question.questionName),
                fontWeight: FontWeight.w900,
                height: 1.08,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryQuestionView extends StatelessWidget {
  const _RetryQuestionView({
    required this.questions,
    required this.selectedIndex,
    required this.question,
    required this.selectedAnswers,
    required this.onQuestionSelected,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final List<QuizQuestion> questions;
  final int selectedIndex;
  final QuizQuestion question;
  final Map<int, String> selectedAnswers;
  final ValueChanged<int> onQuestionSelected;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionSelector(
          questions: questions,
          selectedIndex: selectedIndex,
          onSelected: onQuestionSelected,
        ),
        const SizedBox(height: 20),
        _QuestionCard(question: question),
        const SizedBox(height: 23),
        _AnswerList(
          question: question,
          selectedLabel: selectedAnswers[question.questionNumber],
          onSelected: (label) =>
              onAnswerSelected(question.questionNumber, label),
        ),
        const SizedBox(height: 13),
        _QuestionNavigationBar(
          canGoPrevious: selectedIndex > 0,
          canGoNext: selectedIndex < questions.length - 1,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ],
    );
  }
}

class _ResultQuestionList extends StatelessWidget {
  const _ResultQuestionList({
    required this.quiz,
    required this.selectedAnswers,
  });

  final GeneratedQuiz quiz;
  final Map<int, String> selectedAnswers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < quiz.questions.length; index++) ...[
          _ResultQuestionCard(
            question: quiz.questions[index],
            selectedLabel:
                selectedAnswers[quiz.questions[index].questionNumber],
          ),
          if (index != quiz.questions.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ResultQuestionCard extends StatelessWidget {
  const _ResultQuestionCard({
    required this.question,
    required this.selectedLabel,
  });

  final QuizQuestion question;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    final correctLabel = _correctAnswerLabel(question);
    final isCorrect = selectedLabel != null && selectedLabel == correctLabel;
    final accent = isCorrect ? _teal : _red;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _QuestionBadge(
                          number: question.questionNumber,
                          color: isCorrect
                              ? _tealSoft
                              : const Color(0xFFFFD9DC),
                          textColor: isCorrect ? _teal : _red,
                        ),
                        const Spacer(),
                        _QuestionStatus(isCorrect: isCorrect),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      question.questionName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _deepInk,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _AnswerList(
                      question: question,
                      selectedLabel: selectedLabel,
                      showCorrectAnswer: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge({
    required this.number,
    required this.color,
    required this.textColor,
  });

  final int number;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.formatText(AppKeys.questionNumber, {'number': number}),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _QuestionStatus extends StatelessWidget {
  const _QuestionStatus({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? _teal : _red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCorrect ? Icons.verified_outlined : Icons.error_outline_rounded,
          color: color,
          size: 17,
        ),
        const SizedBox(width: 4),
        Text(
          context
              .getText(
                isCorrect ? AppKeys.correctStatus : AppKeys.incorrectStatus,
              )
              .toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _QuestionNavigationBar extends StatelessWidget {
  const _QuestionNavigationBar({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              label: context.getText(AppKeys.previous),
              icon: Icons.chevron_left_rounded,
              filled: false,
              enabled: canGoPrevious,
              onTap: onPrevious,
            ),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: _NavButton(
              label: context.getText(AppKeys.next),
              icon: Icons.chevron_right_rounded,
              filled: true,
              enabled: canGoNext,
              onTap: onNext,
              iconAfter: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.onTap,
    this.iconAfter = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : _teal;
    final child = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!iconAfter) Icon(icon, color: foreground, size: 20),
          if (!iconAfter) const SizedBox(width: 2),
          _CenteredText(
            label,
            color: foreground,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            verticalOffset: 0.4,
          ),
          if (iconAfter) const SizedBox(width: 2),
          if (iconAfter) Icon(icon, color: foreground, size: 20),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: filled ? _teal : Colors.white,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _teal, width: 1.2),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _AnswerList extends StatelessWidget {
  const _AnswerList({
    required this.question,
    required this.selectedLabel,
    this.onSelected,
    this.showCorrectAnswer = false,
  });

  final QuizQuestion question;
  final String? selectedLabel;
  final ValueChanged<String>? onSelected;
  final bool showCorrectAnswer;

  @override
  Widget build(BuildContext context) {
    final correctLabel = _correctAnswerLabel(question);

    return Column(
      children: [
        for (final answer in question.answers) ...[
          _AnswerTile(
            answer: answer,
            selectedLabel: selectedLabel,
            correctLabel: correctLabel,
            showCorrectAnswer: showCorrectAnswer,
            onTap: onSelected == null ? null : () => onSelected!(answer.label),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({
    required this.answer,
    required this.selectedLabel,
    required this.correctLabel,
    required this.showCorrectAnswer,
    this.onTap,
  });

  final QuizAnswer answer;
  final String? selectedLabel;
  final String? correctLabel;
  final bool showCorrectAnswer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = answer.label.trim().toUpperCase();
    final isSelected = selectedLabel == label;
    final isCorrect = correctLabel == label;
    final hasSelection = selectedLabel != null;
    final isWrongSelected = hasSelection && isSelected && !isCorrect;
    final isRevealedCorrect = isCorrect && (isSelected || showCorrectAnswer);
    final borderColor = isWrongSelected
        ? _red
        : isRevealedCorrect
        ? _teal
        : _cardBorder;
    final background = isWrongSelected
        ? _redSoft
        : isRevealedCorrect
        ? _tealLight
        : Colors.white;
    final foreground = isWrongSelected || isRevealedCorrect
        ? (isWrongSelected ? _red : _teal)
        : _deepInk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 59),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isWrongSelected
                      ? _red
                      : isRevealedCorrect
                      ? _green
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isWrongSelected || isRevealedCorrect
                        ? Colors.transparent
                        : const Color(0xFF9BB0B3),
                  ),
                ),
                child: _CenteredText(
                  label,
                  color: isWrongSelected || isRevealedCorrect
                      ? Colors.white
                      : _deepInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  verticalOffset: 1.2,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  answer.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: isWrongSelected || isRevealedCorrect
                        ? FontWeight.w900
                        : FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (isWrongSelected || isRevealedCorrect)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isWrongSelected ? _red : _teal,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWrongSelected ? Icons.close_rounded : Icons.check_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReviewLoadingContent extends StatefulWidget {
  const _ReviewLoadingContent({this.showHeaderSkeleton = true});

  final bool showHeaderSkeleton;

  @override
  State<_ReviewLoadingContent> createState() => _ReviewLoadingContentState();
}

class _ReviewLoadingContentState extends State<_ReviewLoadingContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

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
        final progress = _controller.value;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showHeaderSkeleton) ...[
                _SkeletonBlock(
                  progress: progress,
                  height: 44,
                  borderRadius: 12,
                ),
                const SizedBox(height: 12),
                _SkeletonBlock(
                  progress: progress,
                  height: 94,
                  borderRadius: 14,
                ),
                const SizedBox(height: 24),
              ],
              _ReviewQuestionLoadingSection(progress: progress),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewQuestionLoadingSection extends StatefulWidget {
  const _ReviewQuestionLoadingSection({this.progress});

  final double? progress;

  @override
  State<_ReviewQuestionLoadingSection> createState() =>
      _ReviewQuestionLoadingSectionState();
}

class _ReviewQuestionLoadingSectionState
    extends State<_ReviewQuestionLoadingSection>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.progress == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return _ReviewQuestionSkeleton(progress: widget.progress ?? 0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return _ReviewQuestionSkeleton(progress: controller.value);
      },
    );
  }
}

class _ReviewQuestionSkeleton extends StatelessWidget {
  const _ReviewQuestionSkeleton({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SkeletonBlock(progress: progress, height: 146, borderRadius: 14),
        const SizedBox(height: 23),
        for (var index = 0; index < 4; index++) ...[
          _SkeletonBlock(progress: progress, height: 59, borderRadius: 12),
          if (index != 3) const SizedBox(height: 10),
        ],
        const SizedBox(height: 13),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _SkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _SkeletonBlock(
                  progress: progress,
                  height: 40,
                  borderRadius: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.progress,
    required this.height,
    required this.borderRadius,
  });

  final double progress;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final highlightPosition = -1.4 + progress * 2.8;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(highlightPosition - 1, 0),
          end: Alignment(highlightPosition + 1, 0),
          colors: const [
            Color(0xFFE5F3F5),
            Color(0xFFF8FEFF),
            Color(0xFFE5F3F5),
          ],
          stops: const [0.22, 0.5, 0.78],
        ).createShader(bounds);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5F3F5),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _red, fontWeight: FontWeight.w800),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}

class _ReviewStatePanel extends StatelessWidget {
  const _ReviewStatePanel({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _ReviewCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const CircularProgressIndicator(color: _navy)
              else ...[
                const Icon(Icons.quiz_outlined, color: _navy, size: 42),
                const SizedBox(height: 14),
                Text(
                  message ?? context.getText(AppKeys.quizDetailErrorTitle),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _deepInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: Text(context.getText(AppKeys.retry)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String? _selectedAnswerLabel(GeneratedQuiz quiz, int questionNumber) {
  for (final answer in quiz.answers) {
    if (answer.questionNumber == questionNumber) {
      return answer.label.trim().toUpperCase();
    }
  }
  return null;
}

String? _correctAnswerLabel(QuizQuestion question) {
  final rightAnswer = question.rightAnswer?.trim();
  if (rightAnswer != null && rightAnswer.isNotEmpty) {
    return rightAnswer.toUpperCase();
  }

  final correctAnswer = question.correctAnswer?.trim();
  if (correctAnswer != null && correctAnswer.isNotEmpty) {
    return correctAnswer.toUpperCase();
  }

  return null;
}

int _computedCorrectCount(GeneratedQuiz quiz) {
  var count = 0;
  for (final question in quiz.questions) {
    final selected = _selectedAnswerLabel(quiz, question.questionNumber);
    final correct = _correctAnswerLabel(question);
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}

String _timeLabel(GeneratedQuiz quiz) {
  final parsed = DateTime.tryParse(
    quiz.modifyDt ?? quiz.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
}

double _questionFontSize(String text) {
  final length = text.trim().length;
  if (length <= 16) {
    return 40;
  }
  if (length <= 28) {
    return 31;
  }
  return 24;
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
