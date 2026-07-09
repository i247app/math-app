part of '../../../home_screen.dart';

class _ParentAssessmentFullSkeleton extends StatelessWidget {
  const _ParentAssessmentFullSkeleton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _ParentAssessmentSkeletonPulse(
      builder: (context, color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ParentSkeletonBlock(
            height: 111 * scale,
            radius: 10 * scale,
            color: color,
          ),
          SizedBox(height: 13 * scale),
          _ParentSkeletonBlock(
            height: 44 * scale,
            radius: 22 * scale,
            color: color,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * scale),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _ParentSkeletonLine(
                  width: 150 * scale,
                  height: 10 * scale,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          _ParentSkeletonLine(
            width: 178 * scale,
            height: 18 * scale,
            color: color,
          ),
          SizedBox(height: 8 * scale),
          _ParentSkeletonBlock(
            height: 124 * scale,
            radius: 10 * scale,
            color: color,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                20 * scale,
                16 * scale,
                14 * scale,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var index = 0; index < 5; index++) ...[
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _ParentSkeletonBlock(
                          width: 28 * scale,
                          height: (34 + index * 13) * scale,
                          radius: 14 * scale,
                          color: color,
                        ),
                      ),
                    ),
                    if (index < 4) SizedBox(width: 10 * scale),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          _ParentAssessmentListSkeleton(scale: scale),
        ],
      ),
    );
  }
}
