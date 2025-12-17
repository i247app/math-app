import '../network/network.dart' as network;
import '../responses/quiz/generate_quiz_response.dart';
import '../responses/quiz/submit_quiz_response.dart';

class QuizRepository {
  Future<GenerateQuizResponse> generateQuiz(
    String uid, {
    String? gradeId,
    String? semesterId,
  }) async {
    final response = await network.generateQuiz(
      uid,
      gradeId: gradeId,
      semesterId: semesterId,
    );
    return response;
  }

  Future<GenerateQuizResponse> generatePractice(String uid) async {
    final response = await network.generatePractice(uid);
    return response;
  }

  Future<SubmitQuizResponse> submitQuiz(
    String uid,
    List<Map<String, dynamic>> answers,
  ) async {
    final response = await network.submitQuiz(uid, answers);
    return response;
  }
}
