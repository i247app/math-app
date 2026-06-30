part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkFilterTabs extends StatelessWidget {
  const _StudentHomeworkFilterTabs({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final _StudentHomeworkFilter activeFilter;
  final ValueChanged<_StudentHomeworkFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final filter in _StudentHomeworkFilter.values) ...[
            _StudentHomeworkFilterChip(
              label: context.getText(filter.labelKey),
              selected: filter == activeFilter,
              onTap: () => onFilterSelected(filter),
            ),
            if (filter != _StudentHomeworkFilter.values.last)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
