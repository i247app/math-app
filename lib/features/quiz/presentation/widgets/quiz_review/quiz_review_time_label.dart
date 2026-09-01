import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/read_models/two_digits.dart';

String quizReviewTimeLabel(GeneratedQuiz quiz) {
  final parsed = DateTime.tryParse(
    quiz.modifyDt ?? quiz.createDt ?? '',
  )?.toLocal();
  if (parsed == null) {
    return '--:--';
  }
  return '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}';
}
