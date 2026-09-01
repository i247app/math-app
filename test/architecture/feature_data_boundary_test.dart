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

  test('home and dashboard only use public APIs from other features', () {
    const aggregatorFeatures = <String>{'home', 'dashboard'};
    const publicPrefixes = <String>[
      'application/contracts/',
      'application/read_models/',
      'domain/',
    ];
    final featureImport = RegExp(r"package:numi/features/([^/]+)/([^']+)");
    final violations = <String>[];

    for (final sourceFeature in aggregatorFeatures) {
      final directory = Directory('lib/features/$sourceFeature');
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final normalizedPath = entity.path.replaceAll('\\', '/');
        final lines = entity.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          final match = featureImport.firstMatch(lines[index]);
          if (match == null) {
            continue;
          }

          final targetFeature = match.group(1)!;
          final targetPath = match.group(2)!;
          if (targetFeature == sourceFeature ||
              publicPrefixes.any(targetPath.startsWith)) {
            continue;
          }

          violations.add('$normalizedPath:${index + 1}: ${lines[index]}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Aggregator features must not reach into another feature\'s data, '
          'presentation, widget, helper, or private model folders. Use its '
          'domain model, application contract, or public read-model:\n'
          '${violations.join('\n')}',
    );
  });

  test('features use the standard top-level layers', () {
    const allowedLayers = <String>{
      'application',
      'data',
      'domain',
      'presentation',
    };
    final violations = <String>[];

    for (final feature in Directory('lib/features').listSync()) {
      if (feature is! Directory) {
        violations.add('Feature root contains a file: ${feature.path}');
        continue;
      }

      for (final entry in feature.listSync()) {
        if (entry is File) {
          violations.add('Feature root contains a file: ${entry.path}');
          continue;
        }
        if (entry is Directory) {
          final layer = entry.uri.pathSegments
              .where((segment) => segment.isNotEmpty)
              .last;
          if (!allowedLayers.contains(layer)) {
            violations.add('Non-standard feature layer: ${entry.path}');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Feature roots may only contain application, data, domain, and '
          'presentation layers:\n${violations.join('\n')}',
    );
  });

  test('application and presentation files stay responsibility-sized', () {
    const maximumLines = 650;
    final violations = <String>[];

    for (final entity in Directory('lib/features').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.endsWith('.g.dart')) {
        continue;
      }

      final normalizedPath = entity.path.replaceAll('\\', '/');
      if (!normalizedPath.contains('/application/') &&
          !normalizedPath.contains('/presentation/')) {
        continue;
      }

      final lineCount = entity.readAsLinesSync().length;
      if (lineCount > maximumLines) {
        violations.add('$normalizedPath: $lineCount lines');
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Large hand-written files should be split by responsibility before '
          'they exceed $maximumLines lines:\n${violations.join('\n')}',
    );
  });
}
