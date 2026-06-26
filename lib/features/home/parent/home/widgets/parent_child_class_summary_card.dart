part of '../../../home_screen.dart';

class _ParentChildClassSummaryCard extends StatelessWidget {
  const _ParentChildClassSummaryCard({required this.summary});

  final _ParentChildSummary? summary;

  @override
  Widget build(BuildContext context) {
    final className = summary == null
        ? context.getText(AppKeys.parentNoClassroom)
        : _parentClassroomName(context, summary!);
    final teacherName = summary?.classroom?.teacherName?.trim();

    return Container(
      // height: 120,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBE6E4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            summary == null
                ? context.getText(AppKeys.parentNoStudentTitle)
                : homeProfileDisplayName(context, summary!.profile),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.xxl,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            teacherName?.isNotEmpty == true
                ? teacherName!
                : context.getText(AppKeys.parentNoTeacher),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: FontSize.large,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
