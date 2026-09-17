import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';

/// Adapts a submitted classroom exercise to the shared exam review UI.
class ClassroomExerciseExamReviewService {
  ClassroomExerciseExamReviewService({
    required this.profileId,
    required ClassroomExerciseService exerciseService,
  }) : _exerciseService = exerciseService;

  final int profileId;
  final ClassroomExerciseService _exerciseService;

  Future<GeneratedExam> getExamDetail(int examId) async {
    final exercise = await _exerciseService.getExerciseDetail(
      exerciseId: examId,
      profileId: profileId,
    );
    if (exercise == null) {
      throw const ClassroomExerciseException('');
    }
    return toGeneratedExam(exercise);
  }

  static GeneratedExam toGeneratedExam(ClassroomExercise exercise) {
    final metadata = exercise.metadata ?? const <String, dynamic>{};
    final selectedAnswers = _submittedAnswers(metadata);
    final questions = <ExamQuestion>[
      for (var index = 0; index < exercise.questions.length; index++)
        _toExamQuestion(exercise.questions[index], index),
    ];

    return GeneratedExam(
      // Keep homework out of the exam-detail cache namespace. The screen
      // already receives its exercise id separately for loading.
      id: null,
      examId: null,
      profileId: exercise.profileId,
      examType: exercise.purpose,
      title: exercise.title,
      shortText: exercise.shortText ?? exercise.description,
      createDt: exercise.createDt,
      modifyDt: exercise.modifyDt,
      grading: ExamGrading(
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

  static ExamQuestion _toExamQuestion(
    ClassroomExerciseQuestion question,
    int index,
  ) {
    final answers = <ExamAnswer>[
      for (
        var answerIndex = 0;
        answerIndex < question.answers.length;
        answerIndex++
      )
        ExamAnswer(
          label: _answerLabel(answerIndex),
          content: question.answers[answerIndex],
        ),
    ];
    final correctLabel = _answerLabelForValue(question.correctAnswer, answers);
    return ExamQuestion(
      questionName: question.displayPrompt ?? '',
      questionNumber: question.questionNumber ?? index + 1,
      answers: answers,
      correctAnswer: correctLabel,
    );
  }

  static List<SubmitExamAnswer> _submittedAnswers(
    Map<String, dynamic> metadata,
  ) {
    final rawAnswers = metadata['submitted_answers'] ?? metadata['answers'];
    if (rawAnswers is! List) {
      return const <SubmitExamAnswer>[];
    }

    return rawAnswers
        .whereType<Map>()
        .map(_submittedAnswerFromMap)
        .whereType<SubmitExamAnswer>()
        .toList(growable: false);
  }

  static SubmitExamAnswer? _submittedAnswerFromMap(
    Map<dynamic, dynamic> value,
  ) {
    final number = _asInt(value['question_number'] ?? value['number']);
    final label = (value['label'] ?? value['answer_label'])?.toString().trim();
    if (number == null || label == null || label.isEmpty) {
      return null;
    }
    return SubmitExamAnswer(questionNumber: number, label: label);
  }

  static String? _answerLabelForValue(String? value, List<ExamAnswer> answers) {
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
