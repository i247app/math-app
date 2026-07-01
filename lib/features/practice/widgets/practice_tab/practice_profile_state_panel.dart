part of '../../practice_tab.dart';

class _PracticeProfileStatePanel extends StatelessWidget {
  const _PracticeProfileStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 78 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 28 * scale,
        vertical: 54 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(
          color: const Color(0xFFE3DDDF).withValues(alpha: 0.70),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E7775).withValues(alpha: 0.06),
            blurRadius: 22 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00776F), size: 58 * scale),
          SizedBox(height: 40 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF253228),
              fontSize: FontSize.xxxl * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF515F54),
              fontSize: FontSize.large * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 34 * scale),
          Material(
            color: _headerNavy,
            shadowColor: _headerNavy.withValues(alpha: 0.20),
            elevation: 4,
            borderRadius: BorderRadius.circular(22 * scale),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(22 * scale),
              child: Container(
                constraints: BoxConstraints(minWidth: 154 * scale),
                padding: EdgeInsets.symmetric(
                  horizontal: 28 * scale,
                  vertical: 15 * scale,
                ),
                child: Text(
                  buttonLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
