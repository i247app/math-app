import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_multi_select_field.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_text_field.dart';
import 'package:numi/features/profile/widgets/form/profile_form_dropdown.dart';
import 'package:numi/shared/widgets/option_bottom_sheet_shell.dart';

void main() {
  late LingoProvider lingo;
  setUp(() => lingo = LingoProvider());
  tearDown(() => lingo.dispose());
  Widget app(Widget child, bool dark) => LingoScope(
    lingo: lingo,
    child: MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: Scaffold(body: child),
    ),
  );

  for (final dark in [false, true]) {
    final colors = dark ? AppThemeColors.dark : AppThemeColors.light;
    testWidgets(
      'teacher fields theme their fill, value and label, dark=$dark',
      (tester) async {
        final controller = TextEditingController(text: 'Class name');
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          app(
            Column(
              children: [
                TeacherTextField(
                  label: 'Name',
                  hintText: 'Type a name',
                  controller: controller,
                ),
                TeacherMultiSelectField<int>(
                  label: 'Programs',
                  values: const [1],
                  items: const [1, 2],
                  displayText: (id) => 'Program $id',
                  itemId: (id) => id,
                  onChanged: (_) {},
                ),
              ],
            ),
            dark,
          ),
        );
        expect(
          tester
              .widget<TextField>(find.byType(TextField))
              .decoration!
              .fillColor,
          colors.inputSurface,
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).style!.color,
          colors.textPrimary,
        );
        expect(
          tester.widget<Text>(find.text('Name')).style!.color,
          colors.textSecondary,
        );
        expect(
          tester.widget<Text>(find.text('Program 1').first).style!.color,
          colors.textPrimary,
        );
        await tester.tap(find.text('Program 1').first);
        await tester.pumpAndSettle();
        expect(find.byType(OptionBottomSheetShell), findsOneWidget);
        final option = find.descendant(
          of: find.byType(ListTile).first,
          matching: find.text('Program 1'),
        );
        expect(tester.widget<Text>(option).style!.color, colors.textPrimary);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'profile option sheet uses theme fonts and colors, dark=$dark',
      (tester) async {
        await tester.pumpWidget(
          app(
            ProfileFormDropdown<int>(
              label: 'Grade',
              hintText: 'Select grade',
              value: 1,
              items: const [1, 2],
              itemLabel: (id) => 'Grade $id',
              onChanged: (_) {},
            ),
            dark,
          ),
        );
        expect(
          tester.widget<Text>(find.text('Grade')).style!.color,
          colors.textSecondary,
        );
        expect(
          tester.widget<Text>(find.text('Grade 1')).style!.color,
          colors.textPrimary,
        );
        await tester.tap(find.text('Grade 1'));
        await tester.pumpAndSettle();
        expect(find.byType(OptionBottomSheetShell), findsOneWidget);
        final option = find.descendant(
          of: find.byType(ListTile).first,
          matching: find.text('Grade 1'),
        );
        expect(tester.widget<Text>(option).style!.color, colors.textPrimary);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('shared option sheet preserves explicit color overrides', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const OptionBottomSheetShell(
          backgroundColor: Colors.orange,
          handleColor: Colors.purple,
          shadowColor: Colors.blue,
          children: [Text('Option')],
        ),
        true,
      ),
    );
    final containers = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(OptionBottomSheetShell),
            matching: find.byType(Container),
          ),
        )
        .toList();
    final shell = containers.first.decoration! as BoxDecoration;
    expect(shell.color, Colors.orange);
    expect(shell.boxShadow!.single.color, Colors.blue);
    expect((containers.last.decoration! as BoxDecoration).color, Colors.purple);
  });
}
