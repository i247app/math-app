import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';

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
