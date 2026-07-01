part of '../../presentation/assessment_result_screen.dart';

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.scale, required this.onBack});

  final double scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.only(left: 20 * scale, right: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _HeaderIconButton(
              icon: Icons.arrow_back_rounded,
              scale: scale,
              onTap: onBack,
            ),
          ),
          Text(
            context.getText(AppKeys.assessmentResultTitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _resultHeaderTeal,
              fontSize: 25 * scale,
              fontWeight: FontWeight.w800,
              height: 34 / 25,
              letterSpacing: -0.2 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
