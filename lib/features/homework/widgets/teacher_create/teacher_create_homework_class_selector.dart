part of '../../../classroom/presentation/teacher_classroom_screens.dart';

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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE4E6), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _createHomeworkClassName(context, classroom),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _teacherTeal,
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
