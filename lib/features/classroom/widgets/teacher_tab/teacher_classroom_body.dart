part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomBody extends StatelessWidget {
  const _TeacherClassroomBody({
    required this.scale,
    required this.error,
    required this.classrooms,
    required this.displayedClassrooms,
    required this.searchController,
    required this.entranceBuilder,
    required this.onCreateClass,
    required this.onOpenClassDetail,
  });

  final double scale;
  final String? error;
  final List<ClassroomModel> classrooms;
  final List<ClassroomModel> displayedClassrooms;
  final TextEditingController searchController;
  final Widget Function(int order, Widget child, bool markOnEnd)
  entranceBuilder;
  final VoidCallback onCreateClass;
  final ValueChanged<ClassroomModel> onOpenClassDetail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        entranceBuilder(
          0,
          _TeacherClassroomAddButton(scale: scale, onTap: onCreateClass),
          false,
        ),
        SizedBox(height: 16 * scale),
        entranceBuilder(
          1,
          _TeacherClassroomSearchField(
            scale: scale,
            controller: searchController,
          ),
          false,
        ),
        SizedBox(height: 24 * scale),
        if (error != null && classrooms.isEmpty)
          entranceBuilder(
            2,
            _TeacherClassroomEmptyState(scale: scale, message: error!),
            true,
          )
        else if (classrooms.isEmpty)
          entranceBuilder(
            2,
            _TeacherClassroomEmptyState(
              scale: scale,
              message: context.getText(AppKeys.teacherEmptyClassroomList),
            ),
            true,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: displayedClassrooms.length,
            separatorBuilder: (_, _) => SizedBox(height: 16 * scale),
            itemBuilder: (context, index) {
              final classroom = displayedClassrooms[index];
              return entranceBuilder(
                2 + index,
                _TeacherClassroomListCard(
                  scale: scale,
                  classroom: classroom,
                  onTap: () => onOpenClassDetail(classroom),
                ),
                index == displayedClassrooms.length - 1,
              );
            },
          ),
      ],
    );
  }
}
