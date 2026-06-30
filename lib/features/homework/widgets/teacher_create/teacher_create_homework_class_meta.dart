part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _CreateHomeworkClassMeta extends StatelessWidget {
  const _CreateHomeworkClassMeta({
    required this.iconAsset,
    required this.label,
  });

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconAsset,
          width: 18,
          height: 18,
          opacity: const AlwaysStoppedAnimation<double>(0.7),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _teacherBlue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}
