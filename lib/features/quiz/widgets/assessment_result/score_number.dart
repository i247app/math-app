part of '../../presentation/assessment_result_screen.dart';

double _scoreNumber(String value) {
  return double.tryParse(value.trim()) ?? 0;
}
