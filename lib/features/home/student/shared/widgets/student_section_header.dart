part of '../../../home_screen.dart';

class _StudentSectionHeader extends StatelessWidget {
  const _StudentSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final action = Text(
      actionLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFBC3B14),
        fontSize: FontSize.small,
        fontWeight: FontWeight.w900,
        decoration: TextDecoration.underline,
        height: 1.2,
        letterSpacing: 0,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF001741),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w900,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (onAction == null)
          action
        else
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onAction!();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: action,
            ),
          ),
      ],
    );
  }
}
