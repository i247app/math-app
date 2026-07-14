part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherClassroomSkeletonCard extends StatelessWidget {
  const _TeacherClassroomSkeletonCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return TeacherSkeletonCard(
      scale: scale,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeacherSkeletonBlock(
                width: 76 * scale,
                height: 76 * scale,
                radius: 16 * scale,
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeacherSkeletonBlock(
                        width: 128 * scale,
                        height: 21 * scale,
                        radius: 10.5 * scale,
                      ),
                      SizedBox(height: 16 * scale),
                      TeacherSkeletonBlock(
                        width: 142 * scale,
                        height: 18 * scale,
                        radius: 9 * scale,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          TeacherSkeletonBlock(
            width: 132 * scale,
            height: 18 * scale,
            radius: 9 * scale,
          ),
        ],
      ),
    );
  }
}
