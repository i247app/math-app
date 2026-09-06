import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/games/screens/games_tab.dart';
import 'package:numi/features/profile/data/grade_service.dart';

class _UnusedGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) {
    throw StateError('The initial grade list should be used by this test.');
  }
}

void main() {
  const grades = <GradeModel>[
    GradeModel(id: 1, label: 'Lớp 1', displayOrder: 1),
    GradeModel(id: 2, label: 'Lớp 2', displayOrder: 2),
    GradeModel(id: 3, label: 'Lớp 3', displayOrder: 3),
    GradeModel(id: 4, label: 'Lớp 4', displayOrder: 4),
    GradeModel(id: 5, label: 'Lớp 5', displayOrder: 5),
  ];

  testWidgets('shows the illustrated grade path and keeps grade navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        home: LingoScope(
          lingo: lingo,
          child: GamesTab(
            userId: 1,
            initialGrades: grades,
            gradeService: _UnusedGradeService(),
            bottomPadding: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final background = tester.widget<Image>(find.byType(Image).first);
    expect(
      background.image,
      isA<AssetImage>().having(
        (image) => image.assetName,
        'asset name',
        'assets/images/game-grade-selection-road-map.png',
      ),
    );
    expect(find.byTooltip('Mẫu giáo'), findsOneWidget);
    const sourceCenters = <String, Offset>{
      'Mẫu giáo': Offset(440, 1512),
      'Lớp 1': Offset(412, 1241),
      'Lớp 2': Offset(450, 970),
      'Lớp 3': Offset(423, 728),
      'Lớp 4': Offset(454, 486),
      'Lớp 5': Offset(416, 258),
    };
    const sourceSizes = <String, Size>{
      'Mẫu giáo': Size(151, 142),
      'Lớp 1': Size(149, 137),
      'Lớp 2': Size(143, 131),
      'Lớp 3': Size(144, 127),
      'Lớp 4': Size(138, 120),
      'Lớp 5': Size(137, 120),
    };
    const imageScale = 852 / 1844;
    const imageOffsetX = (393 - (853 * imageScale)) / 2;
    for (final entry in sourceCenters.entries) {
      final button = find.byTooltip(entry.key);
      expect(button, findsOneWidget);

      final actualCenter = tester.getCenter(button);
      final expectedCenter = Offset(
        imageOffsetX + (entry.value.dx * imageScale),
        entry.value.dy * imageScale,
      );
      expect(actualCenter.dx, closeTo(expectedCenter.dx, 1));
      expect(actualCenter.dy, closeTo(expectedCenter.dy, 1));
      final actualSize = tester.getSize(button);
      final sourceSize = sourceSizes[entry.key]!;
      expect(actualSize.width, closeTo(sourceSize.width * imageScale, 1));
      expect(actualSize.height, closeTo(sourceSize.height * imageScale, 1));
    }

    await tester.tap(find.byTooltip('Lớp 1'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('games-catalog')), findsOneWidget);
    expect(find.text('Nông trại Numi'), findsOneWidget);
    expect(find.text('Numi Monster Rescue'), findsOneWidget);
    expect(find.text('Hành trình Numi 02'), findsNothing);
    expect(find.text('Hành trình Numi 03'), findsNothing);

    await tester.tap(find.text('Lớp 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Lớp 3'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('games-catalog')), findsOneWidget);
    expect(find.text('Nông trại Numi'), findsOneWidget);
    expect(find.text('Numi Monster Rescue'), findsOneWidget);
    expect(find.text('Hành trình Numi 02'), findsNothing);
    expect(find.text('Hành trình Numi 03'), findsNothing);
  });
}
