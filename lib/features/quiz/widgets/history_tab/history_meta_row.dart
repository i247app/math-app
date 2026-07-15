import 'package:flutter/material.dart';

import 'package:numi/features/quiz/widgets/history_tab/history_date_parts.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_meta_item.dart';

class HistoryMetaRow extends StatelessWidget {
  const HistoryMetaRow({super.key, required this.parts, required this.scale});

  final HistoryDateParts parts;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14 * scale,
      runSpacing: 5 * scale,
      children: [
        HistoryMetaItem(
          icon: Icons.calendar_month_outlined,
          label: parts.date,
          scale: scale,
        ),
        HistoryMetaItem(
          icon: Icons.schedule_rounded,
          label: parts.time,
          scale: scale,
        ),
      ],
    );
  }
}
