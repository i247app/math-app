part of '../../presentation/teacher_homework_screen.dart';

class _TeacherQuestionCard extends StatelessWidget {
  const _TeacherQuestionCard({required this.questionNumber, this.question});

  final int questionNumber;
  final ClassroomExerciseQuestion? question;

  @override
  Widget build(BuildContext context) {
    final prompt =
        question?.displayPrompt ??
        context.getText(AppKeys.teacherAssignmentEquationPrompt);
    final answers = question?.answers ?? const <String>[];
    final colors = context.themeColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(21, 6, 21, 21),
          decoration: BoxDecoration(
            color: colors.elevatedSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.formatText(AppKeys.teacherAssignmentQuestionNumber, {
                  'number': questionNumber,
                }),
                style: GoogleFonts.andika(
                  color: colors.brandStrong,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 24 / 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prompt,
                style: GoogleFonts.andika(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < answers.length; index++) ...[
                _TeacherAnswerOption(
                  letter: _answerLetter(index),
                  text: answers[index],
                  selected: _isCorrectAnswer(question, answers[index], index),
                ),
                if (index != answers.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
