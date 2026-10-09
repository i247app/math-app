import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/app_strings.dart';

void main() {
  final placeholderPattern = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}');
  Set<String> placeholders(String text) => placeholderPattern
      .allMatches(text)
      .map((match) => match.group(1)!)
      .toSet();

  test('every declared key has a translation in every supported language', () {
    // Dart has no reflection for static constants in Flutter. Check the source
    // declarations so a key missing from both languages cannot pass parity.
    final source = File(
      'lib/core/localization/app_keys.dart',
    ).readAsStringSync();
    final declarations = RegExp(
      r"static\s+const\s+\w+\s*=\s*'([^']+)'\s*;",
    ).allMatches(source).toList();
    expect(
      declarations.length,
      RegExp(r'\bstatic\s+const\b').allMatches(source).length,
      reason: 'Update the declaration check if the key syntax changes.',
    );
    final keys = declarations.map((match) => match.group(1)!).toSet();
    expect(
      keys.length,
      declarations.length,
      reason: 'Key values must be unique.',
    );
    for (final language in AppLanguage.values) {
      expect(
        AppStrings.getAll(language).keys.toSet(),
        keys,
        reason: 'Translation coverage for ${language.lookupCode}',
      );
    }
  });

  test('Vietnamese and English share keys and interpolation placeholders', () {
    final vietnamese = AppStrings.getAll(AppLanguage.vi);
    final english = AppStrings.getAll(AppLanguage.en);
    expect(vietnamese.keys.toSet(), english.keys.toSet());
    for (final key in vietnamese.keys) {
      expect(
        placeholders(english[key]!),
        placeholders(vietnamese[key]!),
        reason: 'Placeholder mismatch for $key',
      );
    }
  });

  for (final language in AppLanguage.values) {
    test('${language.lookupCode} translations contain no blank values', () {
      for (final entry in AppStrings.getAll(language).entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    });

    test(
      '${language.lookupCode} format replaces all declared placeholders',
      () {
        final previousLanguage = AppLanguageState.current;
        addTearDown(() => AppLanguageState.current = previousLanguage);
        AppLanguageState.current = language;
        for (final entry in AppStrings.getAll(language).entries) {
          final names = placeholders(entry.value);
          if (names.isEmpty) continue;
          final formatted = AppStrings.currentFormat(entry.key, {
            for (final name in names) name: '<$name>',
          });
          expect(placeholders(formatted), isEmpty, reason: entry.key);
          for (final name in names) {
            expect(formatted, contains('<$name>'), reason: entry.key);
          }
        }
      },
    );
  }
}
