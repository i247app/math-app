part of '../../history_tab.dart';

class _HistoryTypeTabButton extends StatelessWidget {
  const _HistoryTypeTabButton({
    required this.filter,
    required this.selected,
    required this.onTap,
    required this.scale,
  });

  final _HistoryFilter filter;
  final bool selected;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? historyActiveTab : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            context.getText(filter.labelKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : historyMuted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
