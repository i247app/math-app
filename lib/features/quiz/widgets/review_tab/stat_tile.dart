part of '../../review_tab.dart';

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.scale,
  });

  final String icon;
  final String value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46 * scale,
            height: 46 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(fontSize: FontSize.xxxl * scale, height: 1),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewInk,
                    fontSize: FontSize.xxxl * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewMuted,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
