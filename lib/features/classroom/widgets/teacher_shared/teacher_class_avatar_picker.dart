part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassAvatarPicker extends StatelessWidget {
  const _TeacherClassAvatarPicker({
    required this.scale,
    required this.avatarPath,
    required this.onTap,
  });

  final double scale;
  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96 * scale,
                height: 96 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E3E6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF747781),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: avatarPath == null
                      ? null
                      : DecorationImage(
                          image: FileImage(File(avatarPath!)),
                          fit: BoxFit.cover,
                        ),
                ),
                child: avatarPath == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        color: const Color(0xFF747781),
                        size: 34 * scale,
                      )
                    : null,
              ),
              Positioned(
                right: -7 * scale,
                bottom: -7 * scale,
                child: Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: BoxDecoration(
                    color: teacherTeal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1A000000),
                        blurRadius: 15 * scale,
                        spreadRadius: -3 * scale,
                        offset: Offset(0, 10 * scale),
                      ),
                      BoxShadow(
                        color: const Color(0x1A000000),
                        blurRadius: 6 * scale,
                        spreadRadius: -4 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 15 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          context.getText(AppKeys.teacherClassImageLabel),
          style: GoogleFonts.andika(
            color: const Color(0xFF444650),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
