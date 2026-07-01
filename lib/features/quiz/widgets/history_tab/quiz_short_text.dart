part of '../../history_tab.dart';

String? _quizShortText(GeneratedQuiz quiz) {
  final shortText = quiz.shortText?.trim();
  if (shortText == null || shortText.isEmpty) {
    return null;
  }
  return shortText;
}
