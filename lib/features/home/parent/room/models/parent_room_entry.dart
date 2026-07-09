import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/home/home_api.dart';

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