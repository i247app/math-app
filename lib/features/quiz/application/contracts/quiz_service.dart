import 'package:numi/features/quiz/domain/models/quiz.dart';

const quizPurposeAssessment = 'ASSESSMENT';
const quizPurposePractice = 'PRACTICE';
const quizTypeGeneral = 'GENERAL';
const quizTypeReinforcement = 'REINFORCEMENT';
const assessmentQuizType = quizPurposeAssessment;

abstract interface class QuizService {
  Future<GeneratedQuiz> generateAssessmentQuiz({
    String purpose = quizPurposeAssessment,
    String typeOfQuiz = quizTypeGeneral,
    String? gradeLabel,
    int? previousQuizId,
    List<String>? chapters,
    int? profileId,
  });

  Future<List<GeneratedQuiz>> listQuizzes({int? userId, int? profileId});

  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  });

  Future<QuizProgressResponse> getQuizProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  });

  Future<GeneratedQuiz> submitQuiz({
    required int quizId,
    required List<SubmitQuizAnswer> answers,
    int? profileId,
  });

  Future<GeneratedQuiz> getQuizDetail(int quizId);
}
