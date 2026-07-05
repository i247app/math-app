part of '../../../home_screen.dart';

class _ParentPracticeTabBanner extends StatelessWidget {
  const _ParentPracticeTabBanner({required this.onTap, required this.scale});

  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10 * scale);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 3.21,
          child: Image.asset(
            'assets/images/review_tab_banner.jpg',
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                return child;
              }
              if (frame == null) {
                return _ParentAssessmentSkeletonPulse(
                  builder: (context, color) =>
                      _ParentSkeletonBlock(radius: 10 * scale, color: color),
                );
              }
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: homeFadeInDuration,
                curve: Curves.easeOut,
                builder: (context, value, animatedChild) =>
                    Opacity(opacity: value, child: animatedChild),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}
