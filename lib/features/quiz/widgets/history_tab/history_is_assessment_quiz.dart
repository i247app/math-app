part of '../../history_tab.dart';

bool _historyIsAssessmentQuiz(GeneratedQuiz quiz) {
  return _historyQuizPurpose(quiz) == 'ASSESSMENT';
}
