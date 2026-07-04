part of '../../presentation/teacher_classroom_screens.dart';

class TeacherScreenAppBar extends StatelessWidget {
  const TeacherScreenAppBar({
    super.key,
    required this.title,
    required this.scale,
    required this.onBack,
    this.action,
  });

  final String title;
  final double scale;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                onBack();
              },
              icon: SvgPicture.asset(
                'assets/images/teacher_class_back.svg',
                width: 16 * scale,
                height: 16 * scale,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: teacherTeal,
              fontSize: FontSize.xxxl * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          if (action != null)
            Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }
}
