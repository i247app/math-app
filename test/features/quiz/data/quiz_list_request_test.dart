import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/quiz/data/quiz_api_models.dart';

void main() {
  test('quiz list request includes the assessment purpose', () {
    const request = QuizListRequest(
      profileId: 21,
      page: 1,
      size: 10,
      takeAll: false,
      purpose: 'ASSESSMENT',
    );

    expect(request.toJson(), containsPair('purpose', 'ASSESSMENT'));
  });
}
