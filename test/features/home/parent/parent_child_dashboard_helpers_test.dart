import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/home/helpers/parent/parent_child_dashboard_helpers.dart';

void main() {
  test('keeps every classroom joined by the same child', () {
    const child = StudentProfile(id: 10, name: 'An');
    const firstClass = ClassroomModel(
      classroomId: 101,
      name: '2A5',
      teacherName: 'Thầy An',
    );
    const secondClass = ClassroomModel(
      classroomId: 102,
      name: '3B1',
      teacherName: 'Cô Ngân',
    );
    const parent = ParentHomeLayout(
      children: [child],
      classrooms: [
        HomeLayoutClassroom(classroom: firstClass, memberProfileId: 10),
        HomeLayoutClassroom(classroom: secondClass, memberProfileId: 10),
      ],
    );

    final summaries = summariesFromLayout(parent);

    expect(summaries, hasLength(1));
    expect(summaries.single.classroom, same(firstClass));
    expect(summaries.single.classrooms, [firstClass, secondClass]);
  });
}
