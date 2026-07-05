import 'package:numi_flutter/core/network/quiz_models.dart';
import 'package:numi_flutter/features/quiz/widgets/history_tab/history_quiz_purpose.dart';

bool historyIsAssessmentQuiz(GeneratedQuiz quiz) {
  return historyQuizPurpose(quiz) == 'ASSESSMENT';
}
