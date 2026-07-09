import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/home/student/home/models/student_home_panel.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_home_tab_button.dart';
import 'package:numi_flutter/features/home/widgets/home_visual_constants.dart';

// ignore: unused_element
class StudentHomeTabs extends StatelessWidget {
  const StudentHomeTabs({
    super.key,
    required this.activePanel,
    required this.scale,
    required this.onChanged,
  });

  final StudentHomePanel activePanel;
  final double scale;
  final ValueChanged<StudentHomePanel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <(StudentHomePanel, String)>[
      (StudentHomePanel.homework, context.getText(AppKeys.studentHomework)),
      (StudentHomePanel.classroom, context.getText(AppKeys.studentClassroom)),
      (StudentHomePanel.achievement, context.getText(AppKeys.yourAchievement)),
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
                        child: StudentHomeTabButton(
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
