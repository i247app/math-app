import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/network/quiz_models.dart';
import '../../data/quiz_api.dart';

const _reviewBackground = Color(0xFFEEF9FB);
const _navy = Color(0xFF063A7B);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFF04D4D);
const _orange = Color(0xFFFF8A3D);
const _muted = Color(0xFF6F7785);
const _deepInk = Color(0xFF1F2B2B);
const _cardBorder = Color(0xFFE0D8DB);
const _useFakeQuizApi = bool.fromEnvironment('USE_FAKE_QUIZ_API');

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen({
    super.key,
    required this.quizId,
    this.initialQuiz,
  });

  final String quizId;
  final GeneratedQuiz? initialQuiz;

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  late final QuizService _quizService =
      _useFakeQuizApi ? const FakeQuizApi() : QuizApi();

  GeneratedQuiz? _quiz;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;
  bool _showAnswer = false;
  final Map<int, String> _selectedAnswers = <int, String>{};

  @override
  void initState() {
    super.initState();
    _quiz = widget.initialQuiz;
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
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    HapticFeedback.selectionClick();
    setState(() => _showAnswer = !_showAnswer);
  }

  void _selectAnswer(int questionNumber, String label) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAnswers[questionNumber] = label.trim().toUpperCase();
    });
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
                  ? _ReviewStatePanel(
                      isLoading: _isLoading,
                      message: _errorMessage,
                      onRetry: _loadQuizDetail,
                    )
                  : _ReviewContent(
                      quiz: quiz,
                      selectedIndex: _selectedIndex,
                      showAnswer: _showAnswer,
                      isLoading: _isLoading,
                      errorMessage: _errorMessage,
                      onRetry: _loadQuizDetail,
                      onQuestionSelected: _selectQuestion,
                      selectedAnswers: _selectedAnswers,
                      onAnswerSelected: _selectAnswer,
                      onToggleAnswer: _toggleAnswer,
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
    return SizedBox(
      height: 70,
      child: CustomPaint(
        painter: const _ReviewHeaderPainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: _navy,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  context.getText(AppKeys.quizDetailTitle),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _navy,
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewHeaderPainter extends CustomPainter {
  const _ReviewHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = _reviewBackground;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = _orange.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final path = Path()
      ..moveTo(0, size.height - 6)
      ..quadraticBezierTo(
          size.width * 0.5, size.height + 6, size.width, size.height - 6);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ReviewHeaderPainter oldDelegate) => false;
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({
    required this.quiz,
    required this.selectedIndex,
    required this.showAnswer,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onQuestionSelected,
    required this.selectedAnswers,
    required this.onAnswerSelected,
    required this.onToggleAnswer,
  });

  final GeneratedQuiz quiz;
  final int selectedIndex;
  final bool showAnswer;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<int> onQuestionSelected;
  final Map<int, String> selectedAnswers;
  final void Function(int questionNumber, String label) onAnswerSelected;
  final VoidCallback onToggleAnswer;

  @override
  Widget build(BuildContext context) {
    final questions = quiz.questions;
    final safeIndex =
        questions.isEmpty ? 0 : selectedIndex.clamp(0, questions.length - 1);
    final question = questions.isEmpty ? null : questions[safeIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) const LinearProgressIndicator(color: _navy),
          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
            _InlineError(message: errorMessage!, onRetry: onRetry),
            const SizedBox(height: 10),
          ],
          _StatsCard(quiz: quiz),
          const SizedBox(height: 12),
          _QuestionSelector(
            questions: questions,
            selectedIndex: safeIndex,
            onSelected: onQuestionSelected,
          ),
          const SizedBox(height: 14),
          if (question == null)
            _ReviewStatePanel(
              isLoading: false,
              message: context.getText(AppKeys.emptyQuizQuestions),
              onRetry: onRetry,
            )
          else ...[
            _QuestionCard(question: question),
            const SizedBox(height: 14),
            _AnswerList(
              question: question,
              selectedLabel: selectedAnswers[question.questionNumber],
              onSelected: (label) {
                onAnswerSelected(question.questionNumber, label);
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: _AnswerToggleButton(
                showAnswer: showAnswer,
                onTap: onToggleAnswer,
              ),
            ),
            if (showAnswer) ...[
              const SizedBox(height: 20),
              _AnswerRevealPanel(question: question),
            ],
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF4E86FF),
            iconBackground: const Color(0xFFEAF1FF),
            value: '$total',
            label: context.getText(AppKeys.totalQuestions),
          ),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: _green,
            iconBackground: const Color(0xFFE8FFF1),
            value: '$correct',
            label: context.getText(AppKeys.correct),
          ),
          _StatItem(
            icon: Icons.cancel_outlined,
            iconColor: _red,
            iconBackground: const Color(0xFFFFECEC),
            value: '$wrong',
            label: context.getText(AppKeys.incorrect),
          ),
          _StatItem(
            icon: Icons.schedule_rounded,
            iconColor: _orange,
            iconBackground: const Color(0xFFFFF3EA),
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
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _navy,
              fontFamily: 'Nunito',
              fontSize: 14,
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
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 11,
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
    return _ReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(questions.length, (index) {
            final selected = index == selectedIndex;
            return Padding(
              padding: EdgeInsets.only(
                  right: index == questions.length - 1 ? 0 : 10),
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: selected ? _navy : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: _navy, width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: selected ? Colors.white : _navy,
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              context.formatText(
                AppKeys.questionNumber,
                {'number': question.questionNumber},
              ),
              style: const TextStyle(
                color: _navy,
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              question.questionName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _navy,
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.05,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerList extends StatelessWidget {
  const _AnswerList({
    required this.question,
    required this.selectedLabel,
    required this.onSelected,
  });

  final QuizQuestion question;
  final String? selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final correctLabel = question.rightAnswer?.trim().toUpperCase();

    return Column(
      children: [
        for (final answer in question.answers) ...[
          _AnswerTile(
            answer: answer,
            selectedLabel: selectedLabel,
            correctLabel: correctLabel,
            onTap: () => onSelected(answer.label),
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
    required this.onTap,
  });

  final QuizAnswer answer;
  final String? selectedLabel;
  final String? correctLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = answer.label.trim().toUpperCase();
    final isSelected = selectedLabel == label;
    final isCorrect = correctLabel == label;
    final hasSelection = selectedLabel != null;
    final isWrongSelected = hasSelection && isSelected && !isCorrect;
    final isRevealedCorrect = hasSelection && isCorrect;
    final borderColor = isWrongSelected
        ? _red
        : isRevealedCorrect
            ? _green
            : _cardBorder;
    final background = isWrongSelected
        ? const Color(0xFFFFF1F1)
        : isRevealedCorrect
            ? const Color(0xFFEFFFF5)
            : Colors.white;
    final foreground = isWrongSelected || isRevealedCorrect
        ? (isWrongSelected ? _red : const Color(0xFF0C9C55))
        : _deepInk;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 47),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: borderColor, width: hasSelection ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 27,
                height: 27,
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
                        : _deepInk,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isWrongSelected || isRevealedCorrect
                          ? Colors.white
                          : _deepInk,
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
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
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: isWrongSelected || isRevealedCorrect
                        ? FontWeight.w900
                        : FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (isWrongSelected || isRevealedCorrect)
                Icon(
                  isWrongSelected ? Icons.close_rounded : Icons.check_rounded,
                  color: isWrongSelected ? _red : _green,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerToggleButton extends StatelessWidget {
  const _AnswerToggleButton({
    required this.showAnswer,
    required this.onTap,
  });

  final bool showAnswer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF58AEE),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Text(
            showAnswer
                ? context.getText(AppKeys.hideAnswerUpper)
                : context.getText(AppKeys.showAnswerUpper),
            style: const TextStyle(
              color: _navy,
              fontFamily: 'Nunito',
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

class _AnswerRevealPanel extends StatelessWidget {
  const _AnswerRevealPanel({required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final answer = question.rightAnswer?.trim().toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        answer == null || answer.isEmpty
            ? context.getText(AppKeys.noAnswer)
            : context.formatText(AppKeys.answer, {'answer': answer}),
        style: const TextStyle(
          color: Color(0xFFD71970),
          fontFamily: 'Nunito',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.onRetry,
  });

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
              style: const TextStyle(
                color: _red,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
              ),
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
                    fontFamily: 'Nunito',
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

int _computedCorrectCount(GeneratedQuiz quiz) {
  var count = 0;
  for (final question in quiz.questions) {
    final selected = _selectedAnswerLabel(quiz, question.questionNumber);
    final correct = question.rightAnswer?.trim().toUpperCase();
    if (selected != null && selected == correct) {
      count++;
    }
  }
  return count;
}

String _timeLabel(GeneratedQuiz quiz) {
  final parsed =
      DateTime.tryParse(quiz.modifyDt ?? quiz.createDt ?? '')?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${_twoDigits(parsed.hour)}:${_twoDigits(parsed.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
