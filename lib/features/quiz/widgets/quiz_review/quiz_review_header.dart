part of '../../presentation/quiz_review_screen.dart';

class _QuizReviewHeader extends StatelessWidget {
  const _QuizReviewHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border(bottom: BorderSide(color: colors.border, width: 4)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              context.getText(AppKeys.quizDetailTitle),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: colors.brandStrong,
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
