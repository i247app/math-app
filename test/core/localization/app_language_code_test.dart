import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';

void main() {
  test('formats supported language codes for each service', () {
    for (final input in ['vi', 'vi-VN', ' VI_vn ']) {
      final code = AppLanguageCode.tryParse(input)!;
      expect(code.languageCode, 'vi');
      expect(code.ttsCode, 'vi-VN');
      expect(code.underscoreCode, 'vi_VN');
    }
    expect(AppLanguage.en.localeCode.ttsCode, 'en-US');
    final british = AppLanguageCode.tryParse('en_gb')!;
    expect(british.languageTag, 'en-GB');
    expect(british.underscoreCode, 'en_GB');
    expect(AppLanguage.fromCode('en-GB'), AppLanguage.en);
  });

  test('invalid or unsupported codes do not silently become Vietnamese', () {
    for (final input in [null, '', 'fr', 'en-', 'en_US_extra', 'en-INVALID']) {
      expect(AppLanguageCode.tryParse(input), isNull, reason: '$input');
    }
    expect(AppLanguage.fromCode('fr'), AppLanguage.vi);
  });
}
