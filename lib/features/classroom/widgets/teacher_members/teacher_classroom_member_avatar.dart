part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherClassroomMemberAvatar extends StatelessWidget {
  const _TeacherClassroomMemberAvatar({
    required this.member,
    required this.size,
  });

  final ClassroomStudent member;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: member.avatarKey,
      avatarUrl: member.avatarUrl,
    );
  }
}
