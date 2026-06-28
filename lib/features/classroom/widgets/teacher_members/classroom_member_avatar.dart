part of '../../presentation/teacher_classroom_screens.dart';

class _ClassroomMemberAvatar extends StatelessWidget {
  const _ClassroomMemberAvatar({
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
