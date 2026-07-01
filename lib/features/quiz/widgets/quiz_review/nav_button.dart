part of '../../presentation/quiz_review_screen.dart';

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.onTap,
    this.iconAfter = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : _teal;
    final child = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!iconAfter) Icon(icon, color: foreground, size: 20),
          if (!iconAfter) const SizedBox(width: 2),
          _CenteredText(
            label,
            color: foreground,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            verticalOffset: 0.4,
          ),
          if (iconAfter) const SizedBox(width: 2),
          if (iconAfter) Icon(icon, color: foreground, size: 20),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: filled ? _teal : Colors.white,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _teal, width: 1.2),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.24),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
