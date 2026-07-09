import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_purpose.dart';

bool historyIsAssessmentQuiz(GeneratedQuiz quiz) {
  return historyQuizPurpose(quiz) == 'ASSESSMENT';
}
