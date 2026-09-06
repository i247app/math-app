import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class ParentAssessmentSkeletonPulse extends StatelessWidget {
  const ParentAssessmentSkeletonPulse({super.key, required this.builder});

  final Widget Function(BuildContext context, Color color) builder;

  @override
  Widget build(BuildContext context) => AppSkeletonLoader(builder: builder);
}
