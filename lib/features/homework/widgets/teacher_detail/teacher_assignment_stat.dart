part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherAssignmentStat extends StatelessWidget {
  const _TeacherAssignmentStat({
    required this.label,
    required this.iconAsset,
    required this.value,
    required this.valueFontSize,
  });

  final String label;
  final String iconAsset;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: const Color(0xFF444650),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SvgPicture.asset(iconAsset, width: 15, height: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _teacherInk,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w400,
                  height: 24 / valueFontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
