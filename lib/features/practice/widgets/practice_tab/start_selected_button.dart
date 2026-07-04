part of '../../practice_tab.dart';

class PracticeStartSelectedButton extends StatelessWidget {
  const PracticeStartSelectedButton({
    super.key,
    required this.count,
    required this.scale,
    required this.onTap,
  });

  final int count;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: PracticeDepthButtonSurface(
          radius: 18 * scale,
          depth: 8 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 18 * scale,
            vertical: 18 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: const Color(0xFF3B0031),
                size: 24 * scale,
              ),
              SizedBox(width: 10 * scale),
              Flexible(
                child: Text(
                  context.formatText(AppKeys.startTest, {'count': count}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF3B0031),
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
