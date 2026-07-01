part of '../../presentation/assessment_screen.dart';

class _GeneratingQuestionLoader extends StatefulWidget {
  const _GeneratingQuestionLoader({
    super.key,
    required this.scale,
    this.message,
  });

  final double scale;
  final String? message;

  @override
  State<_GeneratingQuestionLoader> createState() =>
      _GeneratingQuestionLoaderState();
}
