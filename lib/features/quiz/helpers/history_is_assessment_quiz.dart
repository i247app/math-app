import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/helpers/history_quiz_purpose.dart';

bool historyIsAssessmentQuiz(GeneratedQuiz quiz) {
  return historyQuizPurpose(quiz) == 'ASSESSMENT';
}
