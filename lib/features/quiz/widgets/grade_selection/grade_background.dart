part of '../../presentation/grade_selection_screen.dart';

class _GradeBackground extends StatelessWidget {
  const _GradeBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_gradeMint, Color(0xFFD8EBD8), _gradeMint],
          stops: [0, 0.80, 1],
        ),
      ),
    );
  }
}
