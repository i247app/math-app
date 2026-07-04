part of '../teacher_home_tab.dart';

class TeacherHeroCard extends StatelessWidget {
  const TeacherHeroCard({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92 * scale,
      padding: EdgeInsets.fromLTRB(
        14 * scale,
        12 * scale,
        112 * scale,
        18 * scale,
      ),
      decoration: BoxDecoration(
        color: teacherHero,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A002B6A),
            blurRadius: 20 * scale,
            spreadRadius: -4 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -112 * scale,
            bottom: -27 * scale,
            child: Opacity(
              opacity: 0.90,
              child: Image.asset(
                'assets/images/numi-mascot.png',
                width: 118 * scale,
                height: 118 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(AppKeys.teacherHeroTitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 3 * scale),
              Text(
                context.getText(AppKeys.teacherHeroSubtitle),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: Colors.white,
                  fontSize: FontSize.small * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
