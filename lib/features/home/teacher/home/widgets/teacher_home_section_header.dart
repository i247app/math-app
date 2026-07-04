part of '../teacher_home_tab.dart';

class _TeacherHomeSectionHeader extends StatelessWidget {
  const _TeacherHomeSectionHeader({
    required this.scale,
    required this.title,
    this.onViewAll,
  });

  final double scale;
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: Colors.black,
              fontSize: FontSize.large * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onViewAll,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4 * scale,
              vertical: 4 * scale,
            ),
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
        ),
      ],
    );
  }
}
