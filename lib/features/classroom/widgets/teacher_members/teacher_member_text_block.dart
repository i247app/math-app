part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherMemberTextBlock extends StatelessWidget {
  const _TeacherMemberTextBlock({
    required this.name,
    required this.status,
    required this.nameFontSize,
    required this.statusFontSize,
    required this.nameColor,
    required this.statusColor,
    this.letterSpacing = 0,
  });

  final String name;
  final String status;
  final double nameFontSize;
  final double statusFontSize;
  final Color nameColor;
  final Color statusColor;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: nameColor,
            fontSize: nameFontSize,
            fontWeight: FontWeight.w700,
            height: 1.35,
            letterSpacing: letterSpacing,
          ),
        ),
        Text(
          status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: statusColor,
            fontSize: statusFontSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
