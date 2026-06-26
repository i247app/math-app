part of '../../../home_screen.dart';

class _ParentTaskTitle extends StatelessWidget {
  const _ParentTaskTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
  }
}
