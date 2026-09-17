import 'package:numi/features/exam/models/exam.dart';

String formatExamPracticeTopics(
  Iterable<ExamPracticeTopic> topics, {
  required String conjunction,
}) {
  final topicNames = topics
      .map((topic) => topic.topic.trim())
      .where((topic) => topic.isNotEmpty)
      .toSet()
      .toList(growable: false);
  if (topicNames.isEmpty) {
    return '';
  }
  if (topicNames.length == 1) {
    return topicNames.single;
  }

  final normalizedConjunction = conjunction.trim();
  final finalSeparator = normalizedConjunction.isEmpty
      ? ', '
      : ' $normalizedConjunction ';
  if (topicNames.length == 2) {
    return '${topicNames.first}$finalSeparator${topicNames.last}';
  }

  return '${topicNames.take(topicNames.length - 1).join(', ')}'
      '$finalSeparator${topicNames.last}';
}
