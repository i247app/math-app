import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/welcome/screens/welcome_screen.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final size in const [
    Size(320, 568),
    Size(360, 800),
    Size(390, 844),
    Size(800, 1024),
    Size(844, 390),
  ]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('welcome actions remain reachable at $size / $textScale', (
        tester,
      ) async {
        var starts = 0;
        var logins = 0;
        var assessments = 0;
        await _pumpWelcome(
          tester,
          size: size,
          textScale: textScale,
          onStart: () => starts++,
          onLogin: () => logins++,
          onAssessment: () => assessments++,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Đăng Nhập'), findsOneWidget);
        expect(find.text('Đăng Ký'), findsOneWidget);
        expect(find.text('Thử Ngay!'), findsOneWidget);

        final start = find.byKey(const ValueKey('welcome-signup-action'));
        final login = find.byKey(const ValueKey('welcome-login-action'));
        final assessment = find.byKey(
          const ValueKey('welcome-assessment-action'),
        );
        await tester.ensureVisible(assessment);
        await tester.tap(assessment);
        await tester.pumpAndSettle();
        await tester.ensureVisible(start);
        await tester.tap(start);
        await tester.pumpAndSettle();
        await tester.ensureVisible(login);
        await tester.tap(login);
        await tester.pumpAndSettle();
        expect(starts, 1);
        expect(logins, 1);
        expect(assessments, 1);
        expect(tester.takeException(), isNull);
        expect(tester.getSize(login).height, greaterThanOrEqualTo(48));
      });
    }
  }

  testWidgets('English labels and dark theme render without exceptions', (
    tester,
  ) async {
    await _pumpWelcome(
      tester,
      size: const Size(390, 844),
      language: AppLanguage.en,
      dark: true,
    );
    expect(find.text('SIGNUP'), findsOneWidget);
    expect(find.text('Try It Now!'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reference composition keeps the artwork above the actions', (
    tester,
  ) async {
    await _pumpWelcome(tester, size: const Size(360, 800));
    final mascot = find.byKey(const ValueKey('welcome-thinking-mascot'));
    final start = find.byKey(const ValueKey('welcome-login-action'));
    final login = find.byKey(const ValueKey('welcome-signup-action'));
    expect(tester.getRect(mascot).bottom, lessThan(tester.getRect(start).top));
    expect(tester.getRect(start).bottom, lessThan(tester.getRect(login).top));
    expect(start.hitTestable(), findsOneWidget);
    expect(login.hitTestable(), findsOneWidget);
    expect(tester.getSize(start).width, closeTo(230.4, 0.1));

    // Optional review image: flutter test --dart-define=WELCOME_PREVIEW=true ...
    if (const bool.fromEnvironment('WELCOME_PREVIEW')) {
      await _savePreview(tester, 'welcome.png');
    }
  });

  testWidgets('welcome labels update when the app language changes', (
    tester,
  ) async {
    final lingo = await _pumpWelcome(
      tester,
      size: const Size(320, 568),
      textScale: 2,
    );
    expect(find.text('Thử Ngay!'), findsOneWidget);
    expect(find.text('Đăng Nhập'), findsOneWidget);
    expect(find.text('Đăng Ký'), findsOneWidget);
    expect(find.text('Học & Đánh Giá'), findsOneWidget);

    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Try It Now!'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('SIGNUP'), findsOneWidget);
    expect(find.text('Learn & Assess'), findsOneWidget);
    expect(find.text('Thử Ngay!'), findsNothing);
    expect(tester.takeException(), isNull);

    await lingo.setLanguage(AppLanguage.vi);
    await tester.pumpAndSettle();
    expect(find.text('Thử Ngay!'), findsOneWidget);
    expect(find.text('Đăng Nhập'), findsOneWidget);
    expect(find.text('Đăng Ký'), findsOneWidget);
    expect(find.text('Try It Now!'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final textScale in [1.0, 2.0]) {
    testWidgets('English cloud label wraps without clipping at $textScale', (
      tester,
    ) async {
      var assessments = 0;
      await _pumpWelcome(
        tester,
        size: const Size(360, 800),
        language: AppLanguage.en,
        textScale: textScale,
        onAssessment: () => assessments++,
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('Try It Now!'),
      );
      final boxes = paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 0, extentOffset: 11),
      );
      expect(boxes.map((box) => box.top).toSet().length, 2);
      expect(paragraph.didExceedMaxLines, isFalse);
      final labelRect = tester.getRect(find.text('Try It Now!'));
      final actionRect = tester.getRect(
        find.byKey(const ValueKey('welcome-assessment-action')),
      );
      expect(
        boxes.every(
          (box) =>
              labelRect.top + box.top >= actionRect.top &&
              labelRect.top + box.bottom <= actionRect.bottom,
        ),
        isTrue,
      );
      await tester.tap(find.byKey(const ValueKey('welcome-assessment-action')));
      await tester.pumpAndSettle();
      expect(assessments, 1);
      expect(tester.takeException(), isNull);
      if (textScale == 1 && const bool.fromEnvironment('WELCOME_PREVIEW')) {
        await _savePreview(tester, 'welcome-en.png');
      }
    });
  }
}

Future<void> _savePreview(WidgetTester tester, String fileName) async {
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('welcome-preview-boundary')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory('build/welcome-preview').create(recursive: true);
    await File(
      'build/welcome-preview/$fileName',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<LingoProvider> _pumpWelcome(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
  AppLanguage language = AppLanguage.vi,
  bool dark = false,
  VoidCallback? onStart,
  VoidCallback? onLogin,
  VoidCallback? onAssessment,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 32);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final lingo = LingoProvider();
  await lingo.setLanguage(language);
  addTearDown(lingo.dispose);

  for (final font in const [
    ('NunitoVariable', 'assets/fonts/Nunito-wght.ttf'),
    ('BagelFatOne', 'assets/fonts/BagelFatOne-Regular.ttf'),
  ]) {
    final loader = FontLoader(font.$1)..addFont(rootBundle.load(font.$2));
    await loader.load();
  }

  await tester.pumpWidget(
    LingoScope(
      lingo: lingo,
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: const ValueKey('welcome-preview-boundary'),
          child: WelcomeScreen(
            onStart: onStart ?? () {},
            onAssessment: onAssessment ?? () {},
            onLogin: onLogin ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return lingo;
}
