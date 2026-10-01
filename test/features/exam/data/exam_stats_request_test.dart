import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_service.dart';

void main() {
  for (final types in [
    [examTypeAssessment],
    [examTypeGrade],
    [examTypePractice],
    [examTypeGrade, examTypeAssessment],
  ]) {
    test('session list request serializes exam_types as an array ($types)', () {
      final request = ExamStatsRequest(profileId: 21, examTypes: types);
      final json = request.toJson();
      expect(json, {'profile_id': 21, 'exam_types': types});
      expect(json['exam_types'], isA<List<String>>());
      expect(json, isNot(contains('exam_type')));
      final restored = ExamStatsRequest.fromJson(json);
      expect(restored.profileId, 21);
      expect(restored.examTypes, types);
    });
  }
}
