import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';

void main() {
  test(
    'successful empty profile response does not fall back to user id',
    () async {
      final service = _RecordingExamService();

      final result = await loadCompletedParentAssessments(
        examService: service,
        profileId: 42,
        userId: 7,
        page: 1,
        size: 5,
      );

      expect(result.exams, isEmpty);
      expect(service.requests, const <_ExamRequest>[
        _ExamRequest(profileId: 42),
      ]);
    },
  );
}

class _RecordingExamService implements ExamService {
  final List<_ExamRequest> requests = <_ExamRequest>[];

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    requests.add(_ExamRequest(userId: userId, profileId: profileId));
    return const ExamListResponse(mstatus: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExamRequest {
  const _ExamRequest({this.userId, this.profileId});

  final int? userId;
  final int? profileId;

  @override
  bool operator ==(Object other) {
    return other is _ExamRequest &&
        other.userId == userId &&
        other.profileId == profileId;
  }

  @override
  int get hashCode => Object.hash(userId, profileId);
}
