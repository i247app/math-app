part of '../../../home_screen.dart';

// ignore: unused_element
class _StudentHomeTabs extends StatelessWidget {
  const _StudentHomeTabs({
    required this.activePanel,
    required this.scale,
    required this.onChanged,
  });

  final _StudentHomePanel activePanel;
  final double scale;
  final ValueChanged<_StudentHomePanel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <(_StudentHomePanel, String)>[
      (_StudentHomePanel.homework, context.getText(AppKeys.studentHomework)),
      (_StudentHomePanel.classroom, context.getText(AppKeys.studentClassroom)),
      (_StudentHomePanel.achievement, context.getText(AppKeys.yourAchievement)),
    ];
    final activeIndex = tabs.indexWhere((tab) => tab.$1 == activePanel);

    return Container(
      padding: EdgeInsets.all(5 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;

          return SizedBox(
            height: 42 * scale,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: tabWidth * activeIndex,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: homeTeal,
                      borderRadius: BorderRadius.circular(20 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: homeTeal.withValues(alpha: 0.18),
                          blurRadius: 12 * scale,
                          offset: Offset(0, 6 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final tab in tabs)
                      Expanded(
                        child: _StudentHomeTabButton(
                          label: tab.$2,
                          selected: tab.$1 == activePanel,
                          scale: scale,
                          onTap: () => onChanged(tab.$1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
