import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/home/models/home_layout.dart';

class ParentRoomEntry {
  const ParentRoomEntry({required this.layoutClassroom, required this.child});

  final HomeLayoutClassroom layoutClassroom;
  final StudentProfile child;

  ClassroomModel get classroom => layoutClassroom.classroom;

  int? get classroomId => classroom.stableId;

  int? get memberProfileId =>
      layoutClassroom.memberProfileId ?? profileStableId(child);
}
