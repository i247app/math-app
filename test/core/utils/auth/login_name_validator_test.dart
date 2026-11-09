import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';

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

  group('complete phone candidates', () {
    test(
      'every nonzero-leading nine-digit prefix has a Vietnam country hint',
      () {
        var testedCodes = 0;
        for (var code = 10; code <= 99; code++) {
          testedCodes++;
          for (final subscriber in ['0000000', '1234567', '9999999']) {
            final national = '$code$subscriber';
            for (final raw in [
              national,
              '0$national',
              '+84$national',
              '84$national',
            ]) {
              final result = normalizeLoginNameInput(
                PhoneRegion.vn,
                raw,
                inferPhoneRegion: true,
              );
              expect(result.phonePreviewRegion, PhoneRegion.vn, reason: raw);
            }
          }
        }
        expect(testedCodes, 90);
      },
    );

    test(
      '074 and 068 get country hints without accepting unsupported numbers',
      () {
        for (final raw in [
          '747372827',
          '0747372827',
          '+84747372827',
          '84747372827',
          '688777777',
          '0688777777',
          '+84688777777',
          '84688777777',
        ]) {
          final result = normalizeLoginNameInput(
            PhoneRegion.vn,
            raw,
            inferPhoneRegion: true,
          );
          expect(result.phonePreviewRegion, PhoneRegion.vn);
          expect(result.phoneRegion, isNull);
          expect(result.isValid, isFalse);
          expect(result.loginName, isNull);
          expect(result.errorKey, AppKeys.invalidPhone);
        }
      },
    );

    test('country hints exclude leading zero, incomplete input and explicit other countries', () {
      for (final raw in [
        '012345678',
        '74737282',
        '747372827@example.com',
        '+1747372827',
      ]) {
        expect(previewPhoneRegion(raw), isNull, reason: raw);
      }
      expect(
        previewPhoneRegion('747372827', preferredRegion: PhoneRegion.us),
        isNull,
      );
      expect(
        previewPhoneRegion('+84747372827', preferredRegion: PhoneRegion.us),
        PhoneRegion.vn,
      );
      expect(previewPhoneRegion('7473728270'), PhoneRegion.us);
    });

    for (final (raw, country, canonical) in [
      ('0901234567', PhoneRegion.vn, '+84901234567'),
      ('901234567', PhoneRegion.vn, '+84901234567'),
      ('0325802809', PhoneRegion.vn, '+84325802809'),
      ('0702465814', PhoneRegion.vn, '+84702465814'),
      ('+84 90 123 4567', PhoneRegion.vn, '+84901234567'),
      ('84901234567', PhoneRegion.vn, '+84901234567'),
      ('2025550101', PhoneRegion.us, '+12025550101'),
      ('+1 (202) 555-0101', PhoneRegion.us, '+12025550101'),
      ('12025550101', PhoneRegion.us, '+12025550101'),
    ]) {
      test('recognizes and normalizes $raw only as a complete number', () {
        final result = normalizeLoginNameInput(
          PhoneRegion.vn,
          raw,
          inferPhoneRegion: true,
        );
        expect(result.isValid, isTrue);
        expect(result.phoneRegion, country);
        expect(result.loginName, canonical);
      });
    }

    for (final raw in [
      '1',
      '1202',
      '+1',
      '+84',
      '032580280',
      '1111111111',
      '2021550101',
      '0125550101',
      '0412345678',
      '901234567890',
      '+442071838750',
      '090abc1234567',
      '++84901234567',
    ]) {
      test(
        'does not classify incomplete or invalid $raw as a phone candidate',
        () {
          expect(detectPhoneRegion(raw), isNull);
          expect(
            normalizeLoginNameInput(
              PhoneRegion.vn,
              raw,
              inferPhoneRegion: true,
            ).isValid,
            isFalse,
          );
        },
      );
    }

    test(
      'reconsiders a Vietnam prefix when the next digit completes a US number',
      () {
        expect(detectPhoneRegion('347555012'), PhoneRegion.vn);
        expect(detectPhoneRegion('3475550123'), PhoneRegion.us);
        expect(detectPhoneRegion('3475550123@'), isNull);
      },
    );

    test('manual selection applies to national input but explicit country codes override it', () {
      expect(
        detectPhoneRegion('2025550101', preferredRegion: PhoneRegion.vn),
        isNull,
      );
      expect(
        detectPhoneRegion('2025550101', preferredRegion: PhoneRegion.us),
        PhoneRegion.us,
      );
      expect(
        detectPhoneRegion('+12025550101', preferredRegion: PhoneRegion.vn),
        PhoneRegion.us,
      );
      expect(
        detectPhoneRegion('+84901234567', preferredRegion: PhoneRegion.us),
        PhoneRegion.vn,
      );
    });

    test('an unfinished international code reports a short phone number on validation', () {
      for (final code in ['+1', '+84']) {
        final result = normalizeLoginNameInput(
          PhoneRegion.vn,
          code,
          inferPhoneRegion: true,
        );
        expect(result.phoneRegion, isNull);
        expect(result.errorKey, AppKeys.phoneTooShort);
      }
    });

    test('every intermediate prefix remains intact when a numeric username becomes email', () {
      for (final email in [
        '123456789012345678901234567890@example.com',
        '901234567@example.com',
        '3475550123@example.com',
      ]) {
        for (var length = 1; length <= email.length; length++) {
          final raw = email.substring(0, length);
          final result = normalizeLoginNameInput(
            PhoneRegion.vn,
            raw,
            inferPhoneRegion: true,
          );
          if (raw.contains('@')) expect(result.kind, LoginNameKind.email);
        }
        final result = normalizeLoginNameInput(
          PhoneRegion.vn,
          email,
          inferPhoneRegion: true,
        );
        expect(result.isValid, isTrue);
        expect(result.kind, LoginNameKind.email);
        expect(result.phoneRegion, isNull);
        expect(result.loginName, email);
      }
    });
  });
}
