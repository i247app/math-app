import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_filter.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_filter_chip.dart';

class StudentHomeworkFilterTabs extends StatelessWidget {
  const StudentHomeworkFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final StudentHomeworkFilter activeFilter;
  final ValueChanged<StudentHomeworkFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final filter in StudentHomeworkFilter.values) ...[
            StudentHomeworkFilterChip(
              label: context.getText(filter.labelKey),
              selected: filter == activeFilter,
              onTap: () => onFilterSelected(filter),
            ),
            if (filter != StudentHomeworkFilter.values.last)
              const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
