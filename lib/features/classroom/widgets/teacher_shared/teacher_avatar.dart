part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherAvatar extends StatelessWidget {
  const _TeacherAvatar({
    required this.profile,
    required this.size,
  });

  final StudentProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: profile?.avatarKey,
      avatarUrl: profile?.avatarUrl,
      borderColor: _teacherBlue.withValues(alpha: 0.10),
      borderWidth: 2,
    );
  }
}
