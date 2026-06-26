part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _ClassDefaultImage extends StatelessWidget {
  const _ClassDefaultImage({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8 * scale),
      child: Image.asset('assets/images/numi-mascot.png', fit: BoxFit.contain),
    );
  }
}
