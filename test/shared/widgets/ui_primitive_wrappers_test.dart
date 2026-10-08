import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_theme_controller.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_add_button.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_dropdown_field.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_multi_select_field.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_primary_button.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_option_bottom_sheet.dart';
import 'package:numi/features/profile/widgets/form/profile_form_dropdown.dart';
import 'package:numi/features/settings/widgets/menu/language_bottom_sheet.dart';
import 'package:numi/features/settings/widgets/menu/settings_language_card.dart';
import 'package:numi/features/settings/widgets/menu/settings_theme_switch_card.dart';
import 'package:numi/shared/widgets/settings_action_card.dart';
import 'package:numi/shared/widgets/teacher_small_coral_add_button.dart';

void main() {
  final lingo = LingoProvider();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<void> pumpApp(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Align(alignment: Alignment.topCenter, child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('profile selector distinguishes clearing from cancellation', (
    tester,
  ) async {
    final changes = <String?>[];
    await pumpApp(
      tester,
      ProfileFormDropdown<String>(
        label: 'Profile option',
        hintText: 'Choose',
        value: 'A',
        items: const ['A', 'B'],
        itemLabel: (item) => item,
        allowEmpty: true,
        emptyLabel: 'Clear selection',
        onChanged: changes.add,
      ),
    );

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear selection'));
    await tester.pumpAndSettle();
    expect(changes, [null]);

    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(changes, [null, 'B']);
  });

  testWidgets('teacher selector scrolls and retains dark theme surface', (
    tester,
  ) async {
    String? selected;
    final items = List.generate(24, (index) => 'Class $index');
    await pumpApp(
      tester,
      TeacherDropdownField<String>(
        label: 'Class',
        value: items.first,
        items: items,
        displayText: (item) => item,
        onChanged: (value) => selected = value,
      ),
      dark: true,
    );

    await tester.tap(find.text('Class 0'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    final list = find.byType(ListView);
    final surfaces = tester.widgetList<Container>(
      find.ancestor(of: list, matching: find.byType(Container)),
    );
    expect(
      surfaces.any(
        (surface) =>
            surface.decoration is BoxDecoration &&
            (surface.decoration! as BoxDecoration).color ==
                AppThemeColors.dark.elevatedSurface,
      ),
      isTrue,
    );
    await tester.scrollUntilVisible(find.text('Class 23'), 250);
    await tester.tap(find.text('Class 23'));
    await tester.pumpAndSettle();
    expect(selected, 'Class 23');
    expect(find.byType(ListView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exercise selector retains subtitles and returns the option', (
    tester,
  ) async {
    int? selected;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            selected = await showModalBottomSheet<int>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => CreateClassroomExerciseOptionBottomSheet<int>(
                options: const [1, 2],
                titleKey: AppKeys.teacherAssignmentProgramLabel,
                isSelected: (option) => option == 1,
                titleBuilder: (_, option) => 'Program $option',
                subtitleBuilder: (_, option) => 'Description $option',
              ),
            );
          },
          child: const Text('Choose program'),
        ),
      ),
    );
    await tester.tap(find.text('Choose program'));
    await tester.pumpAndSettle();
    expect(find.text('Description 2'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.tap(find.text('Description 2'));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });

  testWidgets('multi-select keeps save visible and discards cancelled edits', (
    tester,
  ) async {
    final changes = <List<int>>[];
    await pumpApp(
      tester,
      TeacherMultiSelectField<int>(
        label: 'Recipients',
        values: const [],
        items: List.generate(24, (index) => index),
        displayText: (item) => 'Recipient $item',
        itemId: (item) => item,
        emptyText: 'Choose recipients',
        onChanged: changes.add,
      ),
    );
    tester.view.physicalSize = const Size(390, 640);
    tester.view.padding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPadding);
    await tester.pump();

    await tester.tap(find.text('Choose recipients').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recipient 1'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(changes, isEmpty);

    await tester.tap(find.text('Choose recipients').first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
    await tester.tap(find.text('Recipient 0'));
    await tester.scrollUntilVisible(find.text('Recipient 23'), 250);
    await tester.tap(find.text('Recipient 23'));
    await tester.pumpAndSettle();
    final save = find.byType(TeacherPrimaryButton);
    expect(save.hitTestable(), findsOneWidget);
    expect(tester.getBottomRight(save).dy, lessThanOrEqualTo(640 - 24));
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(changes, [
      <int>[0, 23],
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coral button wrappers retain sizes and enabled callbacks', (
    tester,
  ) async {
    var memberTaps = 0;
    var smallTaps = 0;
    await pumpApp(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TeacherMemberAddButton(onTap: () => memberTaps++),
          TeacherSmallCoralAddButton(onTap: () => smallTaps++),
          const TeacherMemberAddButton(key: ValueKey('disabled'), onTap: null),
        ],
      ),
    );
    final member = find.byType(TeacherMemberAddButton).first;
    final small = find.byType(TeacherSmallCoralAddButton);
    expect(tester.getSize(member), const Size(82, 31));
    expect(tester.getSize(small), const Size(91, 35));
    await tester.tap(member);
    await tester.tap(small);
    await tester.tap(find.byKey(const ValueKey('disabled')));
    await tester.pumpAndSettle();
    expect(memberTaps, 1);
    expect(smallTaps, 1);
  });

  testWidgets('settings action and language rows retain their intents', (
    tester,
  ) async {
    var actionTaps = 0;
    final languages = <AppLanguage>[];
    await pumpApp(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsActionCard(
            icon: Icons.logout,
            iconColor: Colors.red,
            iconBackground: Colors.redAccent,
            title: 'Sign out',
            subtitle: 'Leave this session',
            isDestructive: true,
            onTap: () => actionTaps++,
          ),
          SettingsLanguageCard(
            currentLanguage: AppLanguage.vi,
            onLanguageChanged: languages.add,
          ),
        ],
      ),
      dark: true,
    );
    expect(
      tester.widget<Text>(find.text('Sign out')).style?.color,
      AppThemeColors.dark.accentStrong,
    );
    await tester.tap(find.text('Leave this session'));
    expect(actionTaps, 1);
    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageBottomSheet), findsOneWidget);
    await tester.tap(find.text(lingo.lookup(AppKeys.languageEnglish)));
    await tester.pumpAndSettle();
    expect(languages, [AppLanguage.en]);
  });

  testWidgets('theme settings change only through the switch', (tester) async {
    final controller = AppThemeController();
    addTearDown(controller.dispose);
    await pumpApp(
      tester,
      ListenableBuilder(
        listenable: controller,
        builder: (_, _) => SettingsThemeSwitchCard(controller: controller),
      ),
    );
    await tester.tap(find.text(lingo.lookup(AppKeys.appThemeMenuTitle)));
    await tester.pumpAndSettle();
    expect(controller.themeMode, ThemeMode.light);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(controller.themeMode, ThemeMode.dark);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });
}
