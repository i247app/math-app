part of '../../../home_screen.dart';

class _ParentTaskDateLabel extends StatelessWidget {
  const _ParentTaskDateLabel({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.alarm_rounded,
          color: Colors.black87,
          size: FontSize.xxs,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: FontSize.xxs,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
