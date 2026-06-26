part of '../../../home_screen.dart';

class _ParentRoomSkeletonBlock extends StatelessWidget {
  const _ParentRoomSkeletonBlock({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EFEE),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
