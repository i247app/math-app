part of '../../../home_screen.dart';

class _ParentShimmerTransform extends GradientTransform {
  const _ParentShimmerTransform(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0, 0);
  }
}
