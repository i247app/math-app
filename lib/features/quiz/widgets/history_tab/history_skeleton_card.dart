part of '../../history_tab.dart';

class _HistorySkeletonCard extends StatelessWidget {
  const _HistorySkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 116 * scale,
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        14 * scale,
        16 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: colors.border, width: 1.3 * scale),
      ),
      child: Row(
        children: [
          _HistorySkeletonBlock(
            width: 54 * scale,
            height: 54 * scale,
            radius: 27 * scale,
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _HistorySkeletonBlock(
                      width: 82 * scale,
                      height: 12 * scale,
                      radius: 6 * scale,
                    ),
                    SizedBox(width: 12 * scale),
                    _HistorySkeletonBlock(
                      width: 54 * scale,
                      height: 12 * scale,
                      radius: 6 * scale,
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                _HistorySkeletonBlock(
                  width: 150 * scale,
                  height: 17 * scale,
                  radius: 8 * scale,
                ),
                SizedBox(height: 8 * scale),
                _HistorySkeletonBlock(
                  width: 110 * scale,
                  height: 11 * scale,
                  radius: 6 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
