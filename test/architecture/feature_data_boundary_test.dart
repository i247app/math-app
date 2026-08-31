import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature layers outside data do not import network DTOs', () {
    final violations = <String>[];
    final features = Directory('lib/features');

    for (final entity in features.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final normalizedPath = entity.path.replaceAll('\\', '/');
      if (normalizedPath.contains('/data/')) {
        continue;
      }

      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (line.contains("package:numi/features/") &&
            line.contains('/data/dto/')) {
          violations.add('$normalizedPath:${index + 1}: $line');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Application, domain, and presentation must consume domain models '
          'or contracts, not network DTOs:\n'
          '${violations.join('\n')}',
    );
  });

  test('domain models do not import data implementations', () {
    final violations = <String>[];
    final features = Directory('lib/features');

    for (final entity in features.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final normalizedPath = entity.path.replaceAll('\\', '/');
      if (!normalizedPath.contains('/domain/')) {
        continue;
      }

      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (lines[index].contains('/data/')) {
          violations.add('$normalizedPath:${index + 1}: ${lines[index]}');
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
