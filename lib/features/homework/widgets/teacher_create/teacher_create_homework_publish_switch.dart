part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkPublishSwitch extends StatelessWidget {
  const _CreateHomeworkPublishSwitch({
    required this.isPublished,
    required this.onChanged,
  });

  final bool isPublished;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.getText(AppKeys.teacherAssignmentPublishLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: AppColors.textInkDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 18 / 14,
            ),
          ),
        ),
        Text(
          context.getText(
            isPublished
                ? AppKeys.teacherAssignmentVisibilityPublic
                : AppKeys.teacherAssignmentVisibilityPrivate,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: AppColors.textInkDark.withValues(alpha: 0.65),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: isPublished,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.teal520,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFC4C6D2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
