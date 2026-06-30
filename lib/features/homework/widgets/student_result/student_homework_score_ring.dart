part of '../../presentation/student_homework_result_screen.dart';

class _StudentHomeworkScoreRing extends StatelessWidget {
  const _StudentHomeworkScoreRing({
    required this.scale,
    required this.scoreText,
  });

  final double scale;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final slashIndex = scoreText.indexOf('/');
    final scoreValue = slashIndex == -1
        ? scoreText
        : scoreText.substring(0, slashIndex);
    final scoreTotal = slashIndex == -1
        ? '/10'
        : scoreText.substring(slashIndex);

    return Center(
      child: SizedBox(
        width: 192 * scale,
        height: 168 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 192 * scale,
                height: 160 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0F7).withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE6F0F7).withValues(alpha: 0.70),
                      blurRadius: 32 * scale,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 150 * scale,
              height: 150 * scale,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _homeworkResultTeal,
                  width: 9 * scale,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: scoreValue,
                          style: GoogleFonts.andika(
                            color: _homeworkResultScoreGreen,
                            fontSize: 48 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 48,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                        TextSpan(
                          text: scoreTotal,
                          style: GoogleFonts.andika(
                            color: Colors.black,
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.w800,
                            height: 40 / 36,
                            letterSpacing: -0.9 * scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    context.getText(AppKeys.scoreUpper),
                    style: GoogleFonts.andika(
                      color: _homeworkResultMuted,
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w800,
                      height: 15 / 10,
                      letterSpacing: 1 * scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
