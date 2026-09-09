import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';

void main() {
  test('exam list request includes the assessment exam type', () {
    const request = ExamListRequest(
      profileId: 21,
      page: 1,
      size: 10,
      takeAll: false,
      examType: 'ASSESSMENT',
    );

    expect(request.toJson(), containsPair('exam_type', 'ASSESSMENT'));
    expect(request.toJson(), isNot(contains('purpose')));
  });
}
