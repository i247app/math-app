import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';

/// Adapts a submitted classroom exercise to the shared quiz review UI.
class HomeworkQuizReviewService {
  HomeworkQuizReviewService({
    required this.profileId,
    required ClassroomExerciseService exerciseService,
  }) : _exerciseService = exerciseService;

  final int profileId;
  final ClassroomExerciseService _exerciseService;

  Future<GeneratedQuiz> getQuizDetail(int quizId) async {
    final exercise = await _exerciseService.getExerciseDetail(
      exerciseId: quizId,
      profileId: profileId,
    );
    if (exercise == null) {
      throw const ClassroomExerciseException('');
    }
    return toGeneratedQuiz(exercise);
  }

  static GeneratedQuiz toGeneratedQuiz(ClassroomExercise exercise) {
    final metadata = exercise.metadata ?? const <String, dynamic>{};
    final selectedAnswers = _submittedAnswers(metadata);
    final questions = <QuizQuestion>[
      for (var index = 0; index < exercise.questions.length; index++)
        _toQuizQuestion(exercise.questions[index], index),
    ];

    return GeneratedQuiz(
      // Keep homework out of the quiz-detail cache namespace. The screen
      // already receives its exercise id separately for loading.
      id: null,
      quizId: null,
      profileId: exercise.profileId,
      purpose: exercise.purpose,
      title: exercise.title,
      shortText: exercise.shortText ?? exercise.description,
      createDt: exercise.createDt,
      modifyDt: exercise.modifyDt,
      grading: QuizGrading(
        correctNumber: _metadataInt(metadata, const [
          'correct_number',
          'correct_count',
          'correct_answers',
        ]),
        scorePercentage: _metadataInt(metadata, const [
          'score_percentage',
          'score',
          'percentage',
        ]),
        totalQuestions: _metadataInt(metadata, const [
          'total_questions',
          'question_count',
          'total',
        ]),
      ),
      answers: selectedAnswers,
      questions: questions,
    );
  }

  static QuizQuestion _toQuizQuestion(
    ClassroomExerciseQuestion question,
    int index,
  ) {
    final answers = <QuizAnswer>[
      for (
        var answerIndex = 0;
        answerIndex < question.answers.length;
        answerIndex++
      )
        QuizAnswer(
          label: _answerLabel(answerIndex),
          content: question.answers[answerIndex],
        ),
    ];
    final correctLabel = _answerLabelForValue(question.correctAnswer, answers);
    return QuizQuestion(
      questionName: question.displayPrompt ?? '',
      questionNumber: question.questionNumber ?? index + 1,
      answers: answers,
      correctAnswer: correctLabel,
    );
  }

  static List<SubmitQuizAnswer> _submittedAnswers(
    Map<String, dynamic> metadata,
  ) {
    final rawAnswers = metadata['submitted_answers'] ?? metadata['answers'];
    if (rawAnswers is! List) {
      return const <SubmitQuizAnswer>[];
    }

    return rawAnswers
        .whereType<Map>()
        .map(_submittedAnswerFromMap)
        .whereType<SubmitQuizAnswer>()
        .toList(growable: false);
  }

  static SubmitQuizAnswer? _submittedAnswerFromMap(
    Map<dynamic, dynamic> value,
  ) {
    final number = _asInt(value['question_number'] ?? value['number']);
    final label = (value['label'] ?? value['answer_label'])?.toString().trim();
    if (number == null || label == null || label.isEmpty) {
      return null;
    }
    return SubmitQuizAnswer(questionNumber: number, label: label);
  }

  static String? _answerLabelForValue(String? value, List<QuizAnswer> answers) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    final upper = normalized.toUpperCase();
    for (final answer in answers) {
      if (answer.label == upper ||
          answer.content.trim().toUpperCase() == upper) {
        return answer.label;
      }
    }
    return upper;
  }

  static int? _metadataInt(Map<String, dynamic> metadata, List<String> keys) {
    for (final key in keys) {
      final value = _asInt(metadata[key]);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static String _answerLabel(int index) => index >= 0 && index < 26
      ? String.fromCharCode(65 + index)
      : '${index + 1}';
}
