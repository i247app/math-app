import 'package:flutter/material.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_loading_content.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class ParentRoomLoading extends StatelessWidget {
  const ParentRoomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, color) => ParentRoomLoadingContent(color: color),
    );
  }
}
