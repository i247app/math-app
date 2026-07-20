import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/home/student/home/models/student_home_panel.dart';
import 'package:numi/features/home/student/home/widgets/student_home_tab_button.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

// ignore: unused_element
class StudentHomeTabs extends StatelessWidget {
  const StudentHomeTabs({
    super.key,
    required this.activePanel,
    required this.onChanged,
  });

  final StudentHomePanel activePanel;
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
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.14),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;

          return SizedBox(
            height: 42,
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
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: homeTeal.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
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
