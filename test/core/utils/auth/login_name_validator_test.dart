import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/auth/login_name_input_formatter.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';

void main() {
  group('normalizeLoginNameInput', () {
    test('normalizes a Vietnamese phone number', () {
      final result = normalizeLoginNameInput(PhoneRegion.vn, '090 123 4567');

      expect(result.kind, LoginNameKind.phone);
      expect(result.loginName, '+84901234567');
      expect(result.errorKey, isNull);
    });

    test('accepts an email without treating it as a phone', () {
      final result = normalizeLoginNameInput(
        PhoneRegion.vn,
        ' learner@example.com ',
      );

      expect(result.kind, LoginNameKind.email);
      expect(result.loginName, 'learner@example.com');
      expect(result.errorKey, isNull);
    });

    test('rejects an invalid email', () {
      final result = normalizeLoginNameInput(PhoneRegion.vn, 'learner@');

      expect(result.kind, LoginNameKind.email);
      expect(result.loginName, isNull);
      expect(result.errorKey, AppKeys.invalidEmail);
    });

    test('keeps signup phone-only', () {
      final result = normalizeLoginNameInput(
        PhoneRegion.vn,
        'learner@example.com',
        phoneOnly: true,
      );

      expect(result.kind, LoginNameKind.phone);
      expect(result.isValid, isFalse);
    });
  });

  test('smart formatter supports both phone and email input', () {
    const formatter = LoginNameInputFormatter(PhoneRegion.vn);

    final phone = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '0901234567'),
    );
    final email = formatter.formatEditUpdate(
      phone,
      const TextEditingValue(text: 'learner @example.com'),
    );

    expect(phone.text, '090 123 4567');
    expect(email.text, 'learner@example.com');
  });

  test('smart formatter keeps the email cursor at a mid-string deletion', () {
    const formatter = LoginNameInputFormatter(PhoneRegion.vn);
    const oldValue = TextEditingValue(
      text: 'learner@example.com',
      selection: TextSelection.collapsed(offset: 7),
    );
    const newValue = TextEditingValue(
      text: 'learne@example.com',
      selection: TextSelection.collapsed(offset: 6),
    );

    final formatted = formatter.formatEditUpdate(oldValue, newValue);

    expect(formatted.text, 'learne@example.com');
    expect(formatted.selection, const TextSelection.collapsed(offset: 6));
  });

  test('smart formatter keeps the phone cursor at a mid-string deletion', () {
    const formatter = LoginNameInputFormatter(PhoneRegion.vn);
    const oldValue = TextEditingValue(
      text: '090 123 4567',
      selection: TextSelection.collapsed(offset: 5),
    );
    const newValue = TextEditingValue(
      text: '090 23 4567',
      selection: TextSelection.collapsed(offset: 4),
    );

    final formatted = formatter.formatEditUpdate(oldValue, newValue);

    expect(formatted.text, '090 234 567');
    expect(formatted.selection, const TextSelection.collapsed(offset: 4));
  });
}
