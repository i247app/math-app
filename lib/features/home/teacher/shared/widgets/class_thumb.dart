part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _ClassThumb extends StatelessWidget {
  const _ClassThumb({
    required this.classroom,
    required this.scale,
  });

  final ClassroomModel classroom;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        classroom.imageUrl ?? classroom.avatarUrl ?? classroom.fileUrl;
    return Container(
      width: 84 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl?.trim().isNotEmpty == true
          ? Image.network(
              imageUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ClassDefaultImage(scale: scale),
            )
          : _ClassDefaultImage(scale: scale),
    );
  }
}
