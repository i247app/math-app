import 'package:flutter/material.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_block.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_line.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_loader.dart';

class NewHomeSkeleton extends StatelessWidget {
  const NewHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AppSkeletonLoader(
        builder: (context, color) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: AppSkeletonBlock(
                width: 52,
                height: 48,
                radius: 8,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            AppSkeletonBlock(height: 40, radius: 20, color: color),
            const SizedBox(height: 18),
            AppSkeletonBlock(
              radius: 28,
              color: color,
              outlined: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppSkeletonLine(width: 100, height: 30, color: color),
                        const Spacer(),
                        AppSkeletonLine(width: 80, height: 30, color: color),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          AppSkeletonBlock(
                            width: 79,
                            height: 72,
                            radius: 8,
                            color: color,
                          ),
                          const SizedBox(width: 36),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                for (var i = 0; i < 6; i++)
                                  AppSkeletonBlock(
                                    height: 8,
                                    radius: 4,
                                    color: color,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AppSkeletonBlock(
                      height:
                          126 +
                          (MediaQuery.textScalerOf(context).scale(18) / 18 - 1)
                                  .clamp(0, double.infinity) *
                              48,
                      radius: 18,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
