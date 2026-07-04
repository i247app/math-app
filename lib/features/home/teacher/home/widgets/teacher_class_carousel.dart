part of '../teacher_home_tab.dart';

class _TeacherClassCarousel extends StatelessWidget {
  const _TeacherClassCarousel({
    required this.scale,
    required this.classrooms,
    required this.onOpen,
  });

  final double scale;
  final List<ClassroomModel> classrooms;
  final ValueChanged<ClassroomModel> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176 * scale,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: classrooms.length,
        separatorBuilder: (_, _) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final classroom = classrooms[index];
          return SizedBox(
            width: 166 * scale,
            child: _TeacherClassCard(
              scale: scale,
              classroom: classroom,
              onTap: () => onOpen(classroom),
            ),
          );
        },
      ),
    );
  }
}
