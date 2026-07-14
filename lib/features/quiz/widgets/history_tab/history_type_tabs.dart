part of 'package:numi/features/quiz/presentation/tabs/history_tab.dart';

class _HistoryTypeTabs extends StatelessWidget {
  const _HistoryTypeTabs({
    required this.selectedFilter,
    required this.onSelected,
    required this.scale,
  });

  final _HistoryFilter selectedFilter;
  final ValueChanged<_HistoryFilter> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36 * scale,
      padding: EdgeInsets.all(3 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E8EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final filter in _HistoryFilter.values)
            Expanded(
              child: _HistoryTypeTabButton(
                filter: filter,
                selected: selectedFilter == filter,
                onTap: () => onSelected(filter),
                scale: scale,
              ),
            ),
        ],
      ),
    );
  }
}
