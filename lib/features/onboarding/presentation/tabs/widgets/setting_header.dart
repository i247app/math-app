part of '../setting_tab.dart';

class _SettingHeader extends StatelessWidget {
  const _SettingHeader({
    required this.title,
    required this.canGoBack,
    required this.onBack,
    required this.backgroundColor,
    required this.scale,
  });

  final String title;
  final bool canGoBack;
  final VoidCallback onBack;
  final Color backgroundColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124 * scale,
      child: CustomPaint(
        painter: _SettingHeaderCurvePainter(
          backgroundColor: backgroundColor,
          scale: scale,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            30 * scale,
            28 * scale,
            30 * scale,
            24 * scale,
          ),
          child: Row(
            children: [
              if (canGoBack)
                _SettingHeaderButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  outlined: false,
                  onTap: onBack,
                  scale: scale,
                )
              else
                SizedBox(width: 60 * scale),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF063A7B),
                    fontFamily: 'Nunito',
                    fontSize: 26 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              _SettingHeaderButton(
                icon: Icons.notifications_none_rounded,
                outlined: true,
                onTap: HapticFeedback.selectionClick,
                scale: scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingHeaderButton extends StatelessWidget {
  const _SettingHeaderButton({
    required this.icon,
    required this.outlined,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 60 * scale;
    final radius = BorderRadius.circular(outlined ? 22 * scale : size / 2);

    return Material(
      color: Colors.white,
      elevation: outlined ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: outlined
                ? Border.all(
                    color: _deepInk.withValues(alpha: 0.72),
                    width: 1.5 * scale,
                  )
                : null,
            boxShadow: outlined
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: _navy, size: 29 * scale),
        ),
      ),
    );
  }
}

class _SettingHeaderCurvePainter extends CustomPainter {
  const _SettingHeaderCurvePainter({
    required this.backgroundColor,
    required this.scale,
  });

  final Color backgroundColor;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = _orange.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;
    final path = Path()
      ..moveTo(0, size.height - 17 * scale)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height + 2 * scale,
        size.width,
        size.height - 17 * scale,
      );
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _SettingHeaderCurvePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.scale != scale;
  }
}
