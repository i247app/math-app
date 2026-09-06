import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/quiz/helpers/history_quiz_purpose.dart';

bool historyIsAssessmentQuiz(GeneratedQuiz quiz) {
  return historyQuizPurpose(quiz) == 'ASSESSMENT';
}
