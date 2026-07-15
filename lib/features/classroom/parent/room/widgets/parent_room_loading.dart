import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';
import 'package:numi/features/classroom/parent/room/widgets/parent_room_loading_content.dart';

class ParentRoomLoading extends StatefulWidget {
  const ParentRoomLoading({super.key});

  @override
  State<ParentRoomLoading> createState() => _ParentRoomLoadingState();
}

class _ParentRoomLoadingState extends State<ParentRoomLoading>
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
    return AppSkeletonShimmer(
      controller: _controller,
      child: const ParentRoomLoadingContent(),
    );
  }
}
