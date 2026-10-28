import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';

void main() {
  const baseStats = <String, dynamic>{
    'correct_number': 8,
    'score_percentage': 80,
    'skipped_number': 0,
    'total_questions': 10,
    'esess_id': 99,
    'review': 'Existing review',
  };

  test('stats AI strings round-trip and map to the app model', () {
    final dto = ExamStatsDto.fromJson({
      ...baseStats,
      'short_text': 'Keep practicing',
      'ai_review_short': 'You are making progress.',
      'ai_review_long': 'You are making progress.\nPractice subtraction next.',
    });
    final model = dto.toModel();
    expect(model.shortText, 'Keep practicing');
    expect(model.aiReviewShort, 'You are making progress.');
    expect(
      model.aiReviewLong,
      'You are making progress.\nPractice subtraction next.',
    );
    expect(model.review, 'Existing review');
    expect(dto.toJson()['short_text'], model.shortText);
    expect(dto.toJson()['ai_review_short'], model.aiReviewShort);
    expect(dto.toJson()['ai_review_long'], model.aiReviewLong);
  });

  for (final fields in [
    <String, dynamic>{},
    <String, dynamic>{
      'short_text': null,
      'ai_review_short': null,
      'ai_review_long': null,
    },
  ]) {
    test('stats accept missing or null AI strings: $fields', () {
      final dto = ExamStatsDto.fromJson({...baseStats, ...fields});
      final model = dto.toModel();
      expect(dto.shortText, isNull);
      expect(dto.aiReviewShort, isNull);
      expect(dto.aiReviewLong, isNull);
      expect(model.shortText, isNull);
      expect(model.aiReviewShort, isNull);
      expect(model.aiReviewLong, isNull);
      expect(model.review, 'Existing review');
    });
  }

  test('stats preserve empty AI strings', () {
    final dto = ExamStatsDto.fromJson({
      ...baseStats,
      'short_text': '',
      'ai_review_short': '',
      'ai_review_long': '',
    });
    final model = dto.toModel();
    expect(model.shortText, '');
    expect(model.aiReviewShort, '');
    expect(model.aiReviewLong, '');
  });
}
