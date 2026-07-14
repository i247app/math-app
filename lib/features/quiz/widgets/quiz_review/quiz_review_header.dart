part of 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

class _QuizReviewHeader extends StatelessWidget {
  const _QuizReviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return PageHeader(
      title: context.getText(AppKeys.quizDetailTitle),
      scale: 1,
      topInset: 0,
      actionWidth: 52,
      horizontalPadding: 12,
      titleFontSize: 24,
      leading: IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onBack();
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: colors.brandStrong,
          size: 28,
        ),
        tooltip: context.getText(AppKeys.back),
      ),
    );
  }
}
