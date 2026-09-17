part of '../games_tab.dart';

class _GamesGradeSelection extends StatelessWidget {
  const _GamesGradeSelection({
    super.key,
    required this.grades,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onSelected,
  });

  final List<GradeModel> grades;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<GradeModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final visibleGrades =
        grades.where((grade) => grade.label?.trim().isNotEmpty == true).toList()
          ..sort(
            (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
          );
    final kindergartenGrade = visibleGrades
        .where((grade) => _isKindergartenLabel(grade.label))
        .firstOrNull;
    final pathGrades = <GradeModel>[
      kindergartenGrade ?? _kindergartenGrade,
      ...visibleGrades.where((grade) => !_isKindergartenLabel(grade.label)),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: ColoredBox(
        color: colors.pageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const sourceSize = Size(853, 1844);
            final fittedSizes = applyBoxFit(
              BoxFit.cover,
              sourceSize,
              constraints.biggest,
            );
            final imageScale =
                fittedSizes.destination.width / fittedSizes.source.width;
            final renderedImageWidth = sourceSize.width * imageScale;
            final imageOffsetX =
                (constraints.maxWidth - renderedImageWidth) / 2;

            return ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/game-grade-selection-road-map.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  if (isLoading)
                    Positioned(
                      top: 350 * imageScale,
                      left: 0,
                      right: 0,
                      child: const Center(child: _GradePathLoading()),
                    )
                  else if (errorMessage != null)
                    Positioned(
                      top: 240 * imageScale,
                      left: 24,
                      right: 24,
                      child: AppStaggeredEntrance(
                        order: 0,
                        child: _GamesMessageCard(
                          icon: Icons.cloud_off_rounded,
                          message: errorMessage!,
                          actionLabel: context.getText(AppKeys.retryUpper),
                          onAction: onRetry,
                        ),
                      ),
                    )
                  else if (visibleGrades.isEmpty)
                    Positioned(
                      top: 240 * imageScale,
                      left: 24,
                      right: 24,
                      child: AppStaggeredEntrance(
                        order: 0,
                        child: _GamesMessageCard(
                          icon: Icons.school_outlined,
                          message: context.getText(AppKeys.noGrades),
                          actionLabel: context.getText(AppKeys.retryUpper),
                          onAction: onRetry,
                        ),
                      ),
                    )
                  else
                    for (
                      var index = 0;
                      index <
                          math.min(pathGrades.length, _gradePathStops.length);
                      index++
                    )
                      _GradePathPositionedButton(
                        stop: _gradePathStops[index],
                        scale: imageScale,
                        offsetX: imageOffsetX,
                        order: index,
                        child: _GamesGradeCard(
                          grade: pathGrades[index],
                          index: index,
                          onTap: () => onSelected(pathGrades[index]),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

bool _isKindergartenLabel(String? label) {
  final normalized = label?.trim().toLowerCase() ?? '';
  return normalized.contains('mẫu giáo') || normalized.contains('kindergarten');
}

const _kindergartenGrade = GradeModel(
  label: 'Mẫu giáo',
  description: 'Mẫu giáo',
  displayOrder: 0,
);

const _gradePathStops = <_GradePathStop>[
  // Measured from the six inner cream circles in the 853 x 1844 artwork.
  // Stops run from the bottom pedestal (kindergarten) to grade 5 at the top.
  _GradePathStop(x: 440, y: 1512, width: 151, height: 142),
  _GradePathStop(x: 412, y: 1241, width: 149, height: 137),
  _GradePathStop(x: 450, y: 970, width: 143, height: 131),
  _GradePathStop(x: 423, y: 728, width: 144, height: 127),
  _GradePathStop(x: 454, y: 486, width: 138, height: 120),
  _GradePathStop(x: 416, y: 258, width: 137, height: 120),
];

class _GradePathStop {
  const _GradePathStop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
}

class _GradePathPositionedButton extends StatelessWidget {
  const _GradePathPositionedButton({
    required this.stop,
    required this.scale,
    required this.offsetX,
    required this.order,
    required this.child,
  });

  final _GradePathStop stop;
  final double scale;
  final double offsetX;
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = stop.width * scale;
    final height = stop.height * scale;
    return Positioned(
      left: offsetX + (stop.x * scale) - (width / 2),
      top: (stop.y * scale) - (height / 2),
      width: width,
      height: height,
      child: AppStaggeredEntrance(order: order, child: child),
    );
  }
}

class _GradePathLoading extends StatelessWidget {
  const _GradePathLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D155A54),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircularProgressIndicator(
        color: colors.brandStrong,
        strokeWidth: 3,
      ),
    );
  }
}
