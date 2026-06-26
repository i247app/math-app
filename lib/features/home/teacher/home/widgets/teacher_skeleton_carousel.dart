part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherSkeletonCarousel extends StatelessWidget {
  const _TeacherSkeletonCarousel({
    required this.scale,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemCount,
    required this.builder,
  });

  final double scale;
  final double itemWidth;
  final double itemHeight;
  final int itemCount;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          return SizedBox(
            width: itemWidth,
            child: builder(context),
          );
        },
      ),
    );
  }
}
