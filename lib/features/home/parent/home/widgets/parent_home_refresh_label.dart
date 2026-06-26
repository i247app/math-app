part of '../../../home_screen.dart';

class _ParentHomeRefreshLabel extends StatelessWidget {
  const _ParentHomeRefreshLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.getText(AppKeys.loading),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF6D5C5C),
        fontSize: FontSize.caption,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
