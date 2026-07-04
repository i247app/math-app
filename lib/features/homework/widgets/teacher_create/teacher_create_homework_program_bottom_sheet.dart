part of '../../presentation/teacher_homework_screen.dart';

class _CreateHomeworkProgramBottomSheet extends StatelessWidget {
  const _CreateHomeworkProgramBottomSheet({
    required this.options,
    required this.selectedProgramId,
    required this.bottomInset,
  });

  final List<_ClassroomProgramOption> options;
  final int? selectedProgramId;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E9EC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              context.getText(AppKeys.teacherAssignmentProgramLabel),
              style: GoogleFonts.andika(
                color: teacherTeal,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Color(0xFFEFF4F5)),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.id == selectedProgramId;
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: teacherInk,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: teacherTeal,
                              size: 22,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
