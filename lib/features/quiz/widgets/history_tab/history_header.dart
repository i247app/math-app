part of '../../history_tab.dart';

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.scale, required this.topInset});

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        border: Border(
          bottom: BorderSide(color: colors.border, width: 4 * scale),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.historyTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: colors.brandStrong,
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
