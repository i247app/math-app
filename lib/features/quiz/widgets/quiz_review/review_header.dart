part of '../../presentation/quiz_review_screen.dart';

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
