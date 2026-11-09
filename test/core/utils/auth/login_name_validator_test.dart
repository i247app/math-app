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

    test('keeps signup phone-only when phoneOnly is true', () {
      final result = normalizeLoginNameInput(
        PhoneRegion.vn,
        'learner@example.com',
        phoneOnly: true,
      );

      expect(result.kind, LoginNameKind.phone);
      expect(result.isValid, isFalse);
    });

    test('validates email-only for signup mode', () {
      final valid = normalizeLoginNameInput(
        PhoneRegion.vn,
        'learner@example.com',
        emailOnly: true,
      );
      expect(valid.kind, LoginNameKind.email);
      expect(valid.isValid, isTrue);
      expect(valid.loginName, 'learner@example.com');

      final invalid = normalizeLoginNameInput(
        PhoneRegion.vn,
        '0901234567',
        emailOnly: true,
      );
      expect(invalid.kind, LoginNameKind.email);
      expect(invalid.isValid, isFalse);
      expect(invalid.errorKey, AppKeys.invalidEmail);
    });
  });

  test('smart formatter supports both phone and email input', () {
    final formatter = LoginNameInputFormatter(PhoneRegion.vn);

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
    final formatter = LoginNameInputFormatter(PhoneRegion.vn);
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
    final formatter = LoginNameInputFormatter(PhoneRegion.vn);
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

  group('country code input', () {
    TextEditingValue value(String text) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    test(
      'initial 1 becomes the US prefix and the next digit starts the number',
      () {
        PhoneRegion? detected;
        final formatter = LoginNameInputFormatter(
          PhoneRegion.vn,
          onRegionDetected: (region) => detected = region,
        );
        final code = formatter.formatEditUpdate(value(''), value('1'));
        expect(code.text, isEmpty);
        expect(formatter.hasCountryCodeOnly, isTrue);
        expect(detected, PhoneRegion.us);

        final national = formatter.formatEditUpdate(code, value('2'));
        expect(national.text, '2');
        final cleared = formatter.formatEditUpdate(national, value(''));
        expect(cleared.text, isEmpty);
        expect(formatter.hasCountryCodeOnly, isFalse);
        expect(formatter.region, PhoneRegion.us);
      },
    );

    test('a manual Vietnam choice is retained for ambiguous numeric input', () {
      final formatter = LoginNameInputFormatter(
        PhoneRegion.vn,
        allowBareCountryInference: false,
      );
      expect(formatter.formatEditUpdate(value(''), value('1')).text, '1');
      expect(formatter.region, PhoneRegion.vn);
    });

    test(
      'a partial number pasted with leading 1 selects US and keeps the rest',
      () {
        final formatter = LoginNameInputFormatter(PhoneRegion.vn);
        final formatted = formatter.formatEditUpdate(value(''), value('1202'));

        expect(formatter.region, PhoneRegion.us);
        expect(formatted.text, '202');
        expect(formatted.selection.extentOffset, 3);
      },
    );

    test('a manual country choice is overridden only by an explicit other country code', () {
      final formatter = LoginNameInputFormatter(
        PhoneRegion.vn,
        allowBareCountryInference: false,
      );
      var current = formatter.formatEditUpdate(value(''), value('1202'));
      expect(formatter.region, PhoneRegion.vn);
      expect(current.text.replaceAll(' ', ''), '1202');

      current = formatter.formatEditUpdate(current, value('12025550101'));
      expect(formatter.region, PhoneRegion.vn);

      current = formatter.formatEditUpdate(current, value('+12025550101'));
      expect(formatter.region, PhoneRegion.us);
      expect(current.text.replaceAll(' ', ''), '2025550101');
    });

    for (final (raw, country, national, normalized) in [
      ('+1 (202) 555-0101', PhoneRegion.us, '2025550101', '+12025550101'),
      ('12025550101', PhoneRegion.us, '2025550101', '+12025550101'),
      ('+84 90 123 4567', PhoneRegion.vn, '901234567', '+84901234567'),
      ('84901234567', PhoneRegion.vn, '901234567', '+84901234567'),
      ('+84 090 123 4567', PhoneRegion.vn, '0901234567', '+84901234567'),
      ('0901234567', PhoneRegion.vn, '0901234567', '+84901234567'),
    ]) {
      test('keeps every national digit when pasting $raw', () {
        final formatter = LoginNameInputFormatter(PhoneRegion.vn);
        final formatted = formatter.formatEditUpdate(value(''), value(raw));
        expect(formatter.region, country);
        expect(formatted.text.replaceAll(' ', ''), national);
        expect(formatted.selection.extentOffset, formatted.text.length);
        expect(
          normalizeLoginNameInput(formatter.region, formatted.text).loginName,
          normalized,
        );
      });
    }

    test('typing +84 in separate keystrokes preserves the partial prefix', () {
      final formatter = LoginNameInputFormatter(PhoneRegion.us);
      var current = value('');
      for (final text in ['+', '+8', '+84']) {
        current = formatter.formatEditUpdate(current, value(text));
        expect(current.text, text == '+84' ? '' : text);
        expect(formatter.hasCountryCodeOnly, text == '+84');
      }
      expect(formatter.region, PhoneRegion.vn);
      expect(formatter.formatEditUpdate(current, value('9')).text, '9');
    });

    test(
      'numeric email usernames retain their prefix during incremental typing',
      () {
        for (final email in [
          '1a@example.com',
          '123@example.com',
          '1234567@example.com',
        ]) {
          final formatter = LoginNameInputFormatter(PhoneRegion.us);
          var current = value('');
          for (final character in email.split('')) {
            current = formatter.formatEditUpdate(
              current,
              value('${current.text}$character'),
            );
          }
          expect(current.text, email);
          expect(current.selection.extentOffset, email.length);
        }
      },
    );

    test(
      'replacing a number with an email does not prepend a consumed code',
      () {
        final formatter = LoginNameInputFormatter(PhoneRegion.us);
        var current = formatter.formatEditUpdate(value(''), value('1'));
        current = formatter.formatEditUpdate(current, value('2025550101'));
        current = formatter.formatEditUpdate(
          current,
          value('learner@example.com'),
        );
        expect(current.text, 'learner@example.com');
      },
    );

    test(
      'unsupported international codes remain visible and cannot submit',
      () {
        final formatter = LoginNameInputFormatter(PhoneRegion.vn);
        final formatted = formatter.formatEditUpdate(
          value(''),
          value('+442071838750'),
        );
        expect(formatted.text, '+442071838750');
        expect(
          normalizeLoginNameInput(PhoneRegion.vn, formatted.text).isValid,
          isFalse,
        );
      },
    );

    test(
      'an international number restored by navigation is normalized once',
      () {
        expect(
          normalizeLoginNameInput(PhoneRegion.vn, '+84901234567').loginName,
          '+84901234567',
        );
        expect(
          normalizeLoginNameInput(PhoneRegion.us, '+12025550101').loginName,
          '+12025550101',
        );
      },
    );
  });
}
