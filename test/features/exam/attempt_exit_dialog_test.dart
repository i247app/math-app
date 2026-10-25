import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/shared/attempt_exit_dialog.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final (language, isRoadmap) in [
    for (final language in AppLanguage.values) ...[
      (language, false),
      (language, true),
    ],
  ]) {
    testWidgets('localized exit dialog in $language (roadmap: $isRoadmap)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await lingo.setLanguage(language);
      final updates = <String>[];

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showAssessmentExitDialog(
                    context,
                    titleKey: isRoadmap
                        ? AppKeys.lessonExitTitle
                        : AppKeys.assessmentExitTitle,
                    onUpdateStatus: (status) async => updates.add(status),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final labels = language == AppLanguage.en
          ? ['Discard', 'Save']
          : ['Hủy', 'Lưu'];
      final message = language == AppLanguage.en
          ? 'Do you want to save your progress to continue later, or discard this session?'
          : 'Bạn muốn lưu tiến trình để tiếp tục sau hay hủy phiên này?';
      expect(find.text(message), findsOneWidget);
      final title = language == AppLanguage.en
          ? (isRoadmap ? 'Leave test' : 'Leave assessment')
          : 'Thoát bài';
      expect(find.text(title), findsOneWidget);
      final keys = ['assessment-cancel-attempt', 'assessment-leave-active'];
      final cancelStyle = tester.widget<Text>(find.text(labels.first)).style!;
      for (var index = 0; index < labels.length; index++) {
        expect(find.text(labels[index]), findsOneWidget);
        final labelText = tester.widget<Text>(find.text(labels[index]));
        expect(labelText.style!.fontSize, cancelStyle.fontSize);
        expect(labelText.style!.fontWeight, cancelStyle.fontWeight);
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(labels[index]))
              .didExceedMaxLines,
          isFalse,
        );
        expect(
          find.descendant(
            of: find.byKey(ValueKey(keys[index])),
            matching: find.byType(FittedBox),
          ),
          findsNothing,
        );
        final textRect = tester.getRect(find.text(labels[index]));
        final buttonRect = tester.getRect(find.byKey(ValueKey(keys[index])));
        expect(textRect.left, greaterThanOrEqualTo(buttonRect.left));
        expect(textRect.right, lessThanOrEqualTo(buttonRect.right));
      }
      await tester.tap(find.text(labels.last));
      await tester.pumpAndSettle();
      expect(updates, [assessmentActiveStatus]);
      expect(tester.takeException(), isNull);
    });
  }
}
