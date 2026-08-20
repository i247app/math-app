import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/app_search_field.dart';

void main() {
  testWidgets('renders the shared search UI and forwards interactions', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changedValue;
    var filterTapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: AppSearchField(
              controller: controller,
              hintText: 'Search items',
              onChanged: (value) => changedValue = value,
              onFilterPressed: () => filterTapCount += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search items'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(tester.getSize(find.byType(AppSearchField)).height, 42);

    await tester.enterText(find.byType(TextField), 'fractions');
    expect(changedValue, 'fractions');

    await tester.tap(find.byIcon(Icons.tune_rounded));
    expect(filterTapCount, 1);
  });

  testWidgets('uses semantic color and typography tokens in dark mode', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: AppSearchField(
            controller: controller,
            hintText: 'Search items',
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppSearchField),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    final field = tester.widget<TextField>(find.byType(TextField));

    expect(decoration.color, AppThemeColors.dark.inputSurface);
    expect(field.style?.color, AppThemeColors.dark.textPrimary);
    expect(field.decoration?.hintStyle?.color, AppThemeColors.dark.inputHint);
    expect(
      field.style?.fontFamily,
      AppTheme.dark().textTheme.bodyLarge?.fontFamily,
    );
  });
}
