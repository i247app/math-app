import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/games/presentation/games_tab.dart';
import 'package:numi/features/profile/data/grade_api.dart';

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
        'assets/images/game-grade-selection-background-2.jpg',
      ),
    );
    expect(find.byTooltip('Mẫu giáo'), findsNothing);
    const sourceCenters = <int, Offset>{
      1: Offset(320, 1043),
      2: Offset(266, 809),
      3: Offset(329, 604),
      4: Offset(290, 396),
      5: Offset(288, 189),
    };
    const sourceSizes = <int, Size>{
      1: Size(170, 156),
      2: Size(154, 138),
      3: Size(149, 127),
      4: Size(142, 118),
      5: Size(136, 109),
    };
    const imageScale = 852 / 1280;
    const imageOffsetX = (393 - (592 * imageScale)) / 2;
    for (final entry in sourceCenters.entries) {
      final button = find.byTooltip('Lớp ${entry.key}');
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
  });
}
