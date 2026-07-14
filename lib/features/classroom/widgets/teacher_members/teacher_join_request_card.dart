part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherJoinRequestCard extends StatelessWidget {
  const _TeacherJoinRequestCard({
    required this.scale,
    required this.requests,
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final List<ClassroomStudent> requests;
  final Set<int> processingProfileIds;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _TeacherEmptyMemberText(
        scale: scale,
        text: context.getText(AppKeys.teacherNoJoinRequests),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25 * scale,
        vertical: 16 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < requests.length; index++) ...[
            if (index > 0)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * scale),
                child: const Divider(height: 1, color: Color(0xFFF9FAFB)),
              ),
            _TeacherJoinRequestRow(
              scale: scale,
              request: requests[index],
              isProcessing: processingProfileIds.contains(
                requests[index].profileId,
              ),
              onApprove: () => onApprove(requests[index]),
              onReject: () => onReject(requests[index]),
            ),
            if (index != requests.length - 1) SizedBox(height: 16 * scale),
          ],
        ],
      ),
    );
  }
}
