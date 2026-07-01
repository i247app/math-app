part of '../../presentation/grade_selection_screen.dart';

class _GradeHeader extends StatelessWidget {
  const _GradeHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          color: _gradeMint.withValues(alpha: 0.78),
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: _gradeTeal,
              size: 28 * scale,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(
              width: 42 * scale,
              height: 42 * scale,
            ),
            tooltip: context.getText(AppKeys.back),
          ),
        ),
      ),
    );
  }
}
