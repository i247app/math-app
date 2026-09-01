import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class ParentHomeLoadingCard extends StatelessWidget {
  const ParentHomeLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonLoader(
      builder: (context, color) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeletonBlock(
            height: 225,
            radius: 30,
            color: color,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonLine(width: 148, height: 30, color: color),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: AppSkeletonLine(
                      width: 210,
                      height: 34,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  AppSkeletonLine(width: 132, height: 14, color: color),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppSkeletonBlock(
                      width: 150,
                      height: 44,
                      radius: 22,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: AppSkeletonBlock(
                    height: 160,
                    radius: 18,
                    color: color,
                  ),
                ),
                Expanded(
                  child: AppSkeletonBlock(
                    height: 160,
                    radius: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppSkeletonBlock(
              height: 178,
              radius: 17,
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 14,
                  children: List.generate(
                    3,
                    (index) => Row(
                      spacing: 12,
                      children: [
                        AppSkeletonBlock(
                          width: 32,
                          height: 32,
                          radius: 10,
                          color: color,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 7,
                            children: [
                              AppSkeletonLine(
                                width: index == 0 ? 120 : 150,
                                height: 14,
                                color: color,
                              ),
                              AppSkeletonLine(
                                width: double.infinity,
                                height: 10,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
