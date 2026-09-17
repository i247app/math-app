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

    await tester.tap(find.byIcon(Icons.tune_rounded));
    expect(filterTapCount, 1);

    await tester.enterText(find.byType(TextField), 'fractions');
    await tester.pump();
    expect(changedValue, 'fractions');
    expect(find.byIcon(Icons.tune_rounded), findsNothing);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(changedValue, isEmpty);
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

  testWidgets('supports pill, filled, and outlined appearances', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    Future<void> pumpAppearance(AppSearchFieldAppearance appearance) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppSearchField(
              controller: controller,
              hintText: 'Search items',
              appearance: appearance,
            ),
          ),
        ),
      );
    }

    await pumpAppearance(AppSearchFieldAppearance.pill);
    expect(tester.getSize(find.byType(AppSearchField)).height, 49);
    var field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.isCollapsed, isTrue);

    await pumpAppearance(AppSearchFieldAppearance.filled);
    field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.filled, isTrue);
    expect(field.decoration?.isCollapsed, isFalse);
    expect(field.decoration?.focusedBorder, isA<OutlineInputBorder>());

    await pumpAppearance(AppSearchFieldAppearance.outlined);
    field = tester.widget<TextField>(find.byType(TextField));
    final enabledBorder = field.decoration?.enabledBorder as OutlineInputBorder;
    expect(enabledBorder.borderSide.color, AppThemeColors.light.border);
  });

  testWidgets('keeps a custom suffix and forwards search submission', (
    tester,
  ) async {
    final controller = TextEditingController(text: '7A');
    addTearDown(controller.dispose);
    String? submittedValue;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppSearchField(
            controller: controller,
            hintText: 'Class code',
            appearance: AppSearchFieldAppearance.filled,
            showDefaultPrefixIcon: false,
            showClearButton: false,
            suffixIcon: const Icon(Icons.qr_code_scanner_rounded),
            onSubmitted: (value) => submittedValue = value,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.testTextInput.receiveAction(TextInputAction.search);
    expect(submittedValue, '7A');
  });
}
