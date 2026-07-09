part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkClassSelector extends StatelessWidget {
  const _CreateHomeworkClassSelector({
    required this.classroom,
    required this.isLoading,
    required this.onTap,
  });

  final ClassroomModel? classroom;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.inputSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
          decoration: BoxDecoration(
            color: colors.inputSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _createHomeworkClassName(context, classroom),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.brandStrong,
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/images/teacher_homework_dropdown.svg',
                  width: 12,
                  height: 8,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
