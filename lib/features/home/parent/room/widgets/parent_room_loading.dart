part of '../../../home_screen.dart';

class _ParentRoomLoading extends StatefulWidget {
  const _ParentRoomLoading({super.key});

  @override
  State<_ParentRoomLoading> createState() => _ParentRoomLoadingState();
}

class _ParentRoomLoadingState extends State<_ParentRoomLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return _ParentSkeletonShimmer(
          progress: _controller.value,
          child: const _ParentRoomLoadingContent(),
        );
      },
    );
  }
}
