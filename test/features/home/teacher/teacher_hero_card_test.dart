import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_hero_card.dart';

void main() {
  testWidgets('keeps the Vietnamese hero title visible on a narrow phone', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: lingo,
          child: const Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: 320, child: TeacherHeroCard()),
            ),
          ),
        ),
      ),
    );

    final title = find.text('Sẵn sàng cho ngày mới');
    expect(title, findsOneWidget);
    expect(find.byType(FittedBox), findsOneWidget);
    expect(
      tester.renderObject<RenderParagraph>(title).didExceedMaxLines,
      isFalse,
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('teacher-hero-mascot'))),
      const Size(92, 92),
    );
  });
}
