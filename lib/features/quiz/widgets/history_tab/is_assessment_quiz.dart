part of '../../history_tab.dart';

bool _isAssessmentQuiz(GeneratedQuiz quiz) {
  return _quizPurpose(quiz) == 'ASSESSMENT';
}
