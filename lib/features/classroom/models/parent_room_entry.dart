import 'package:numi/features/classroom/data/dto/classroom_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/data/dto/home_layout_models.dart';

class ParentRoomEntry {
  const ParentRoomEntry({required this.layoutClassroom, required this.child});

  final HomeLayoutClassroom layoutClassroom;
  final StudentProfile child;

  ClassroomModel get classroom => layoutClassroom.classroom;

  int? get classroomId => classroom.stableId;

  int? get memberProfileId =>
      layoutClassroom.memberProfileId ??
      ActiveProfileSession.profileStableId(child);
}
