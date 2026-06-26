part of '../../../home_screen.dart';

class _StudentInviteIconButton extends StatelessWidget {
  const _StudentInviteIconButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(999),
        child: Image.asset(asset, width: 25, height: 25),
      ),
    );
  }
}
