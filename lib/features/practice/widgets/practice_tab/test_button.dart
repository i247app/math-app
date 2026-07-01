part of '../../practice_tab.dart';

class _TestButton extends StatelessWidget {
  const _TestButton({
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16 * scale),
          child: _DepthButtonSurface(
            radius: 16 * scale,
            depth: 8 * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 17 * scale,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFF3B0031),
                  size: 25 * scale,
                ),
                SizedBox(width: 14 * scale),
                Flexible(
                  child: Text(
                    context.getText(AppKeys.test),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF3B0031),
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
