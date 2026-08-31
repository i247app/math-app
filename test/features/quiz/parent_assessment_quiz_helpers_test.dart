import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';

void main() {
  test('student profile scope does not fall back to user quizzes', () async {
    final service = _RecordingQuizService();

    final result = await loadCompletedParentAssessments(
      quizService: service,
      profileId: 42,
      userId: 7,
      page: 1,
      size: 5,
      allowUserFallback: false,
    );

    expect(result.quizzes, isEmpty);
    expect(service.requests, const <_QuizRequest>[_QuizRequest(profileId: 42)]);
  });
}

class _RecordingQuizService implements QuizService {
  final List<_QuizRequest> requests = <_QuizRequest>[];

  @override
  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    requests.add(_QuizRequest(userId: userId, profileId: profileId));
    return const QuizListResponse(mstatus: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _QuizRequest {
  const _QuizRequest({this.userId, this.profileId});

  final int? userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return other is _QuizRequest &&
        other.userId == userId &&
        other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(userId, profileId);
}
