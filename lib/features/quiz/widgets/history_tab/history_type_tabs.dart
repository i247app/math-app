import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/history_tab/history_filter.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_type_tab_button.dart';

class HistoryTypeTabs extends StatelessWidget {
  const HistoryTypeTabs({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final HistoryFilter selectedFilter;
  final ValueChanged<HistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E8EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final filter in HistoryFilter.values)
            Expanded(
              child: HistoryTypeTabButton(
                filter: filter,
                selected: selectedFilter == filter,
                onTap: () => onSelected(filter),
              ),
            ),
        ],
      ),
    );
  }
}
