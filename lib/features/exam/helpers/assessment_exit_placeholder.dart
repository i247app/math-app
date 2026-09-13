const int assessmentExitPlaceholderQuestionNumber = 1;
const String assessmentExitPlaceholderAnswerLabel = 'A';

bool isAssessmentExitPlaceholderAnswer({
  required int answerCount,
  required int? questionNumber,
  required String? answerLabel,
}) {
  return answerCount == 1 &&
      questionNumber == assessmentExitPlaceholderQuestionNumber &&
      answerLabel?.trim().toUpperCase() == assessmentExitPlaceholderAnswerLabel;
}
