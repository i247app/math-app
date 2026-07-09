part of '../../presentation/teacher_classroom_screens.dart';

class TeacherAvatar extends StatelessWidget {
  const TeacherAvatar({super.key, required this.profile, required this.size});

  final StudentProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: profile?.avatarKey,
      avatarUrl: profile?.avatarUrl,
      borderColor: AppColors.navy900.withValues(alpha: 0.10),
      borderWidth: 2,
    );
  }
}
