part of '../../history_tab.dart';

class _HistoryMetaRow extends StatelessWidget {
  const _HistoryMetaRow({required this.parts, required this.scale});

  final _HistoryDateParts parts;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14 * scale,
      runSpacing: 5 * scale,
      children: [
        _HistoryMetaItem(
          icon: Icons.calendar_month_outlined,
          label: parts.date,
          scale: scale,
        ),
        _HistoryMetaItem(
          icon: Icons.schedule_rounded,
          label: parts.time,
          scale: scale,
        ),
      ],
    );
  }
}
