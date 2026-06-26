part of '../../../home_screen.dart';

class _ParentModeThreeMessages extends StatelessWidget {
  const _ParentModeThreeMessages({required this.summaries});

  final List<_ParentChildSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final visibleSummaries = summaries.take(2).toList(growable: false);
    if (visibleSummaries.isEmpty) {
      return _ParentRoomEmptyLine(
        icon: Icons.mail_outline_rounded,
        text: context.getText(AppKeys.homeMessageBodyOne),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < visibleSummaries.length; index++) ...[
          _ParentModeThreeMessageItem(
            summary: visibleSummaries[index],
            index: index,
          ),
          if (index != visibleSummaries.length - 1)
            const Divider(height: 24, color: Color(0xFFE9EEF2)),
        ],
      ],
    );
  }
}
