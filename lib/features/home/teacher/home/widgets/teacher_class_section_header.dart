part of '../teacher_home_tab.dart';

class _TeacherClassSectionHeader extends StatelessWidget {
  const _TeacherClassSectionHeader({
    required this.scale,
    required this.hasClasses,
    required this.onAdd,
    this.onViewAll,
  });

  final double scale;
  final bool hasClasses;
  final VoidCallback onAdd;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.getText(AppKeys.teacherYourClasses),
                style: GoogleFonts.andika(
                  color: Colors.black,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                context.getText(AppKeys.viewAllUpper),
                style: GoogleFonts.andika(
                  color: teacherInk,
                  fontSize: FontSize.small * scale,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        if (hasClasses) ...[
          SizedBox(height: 8 * scale),
          TeacherSmallCoralAddButton(scale: scale, onTap: onAdd),
        ],
      ],
    );
  }
}
