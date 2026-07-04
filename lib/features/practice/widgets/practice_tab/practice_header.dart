part of '../../practice_tab.dart';

class PracticeTabHeader extends StatelessWidget {
  const PracticeTabHeader({
    super.key,
    required this.scale,
    required this.topInset,
  });

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFF2F2F2), width: 4 * scale),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.reviewTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: FontSize.xxxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
