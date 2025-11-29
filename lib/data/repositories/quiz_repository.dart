import '../network/network.dart' as network;
import '../responses/quiz/generate_quiz_response.dart';
import '../responses/quiz/submit_quiz_response.dart';

class QuizRepository {
  Future<GenerateQuizResponse> generateQuiz(String uid) async {
    final response = await network.generateQuiz(uid);
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
