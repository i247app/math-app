import 'package:numi/features/quiz/data/dto/quiz_models.dart';

String historyQuizPurpose(GeneratedQuiz quiz) {
  final purpose = quiz.purpose?.trim();
  if (purpose != null && purpose.isNotEmpty) {
    return purpose.toUpperCase();
  }
  return (quiz.type ?? '').trim().toUpperCase();
}
