import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/home/widgets/promo_actions/promo_actions.dart';

void main() {
  Widget subject(List<Widget> children) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            child: PromoActionsSection(height: 160, children: children),
          ),
        ),
      ),
    );
  }

  testWidgets('one child fills the entire promo section', (tester) async {
    const cardKey = Key('single-card');

    await tester.pumpWidget(
      subject(const [ColoredBox(key: cardKey, color: Colors.red)]),
    );

    expect(tester.getSize(find.byKey(cardKey)), const Size(200, 160));
  });

  testWidgets('two children split the promo section horizontally', (
    tester,
  ) async {
    const firstKey = Key('first-card');
    const secondKey = Key('second-card');

    await tester.pumpWidget(
      subject(const [
        ColoredBox(key: firstKey, color: Colors.red),
        ColoredBox(key: secondKey, color: Colors.blue),
      ]),
    );

    expect(tester.getSize(find.byKey(firstKey)), const Size(95, 160));
    expect(tester.getSize(find.byKey(secondKey)), const Size(95, 160));
  });

  testWidgets('nested vertical group splits its column evenly', (tester) async {
    const topKey = Key('top-card');
    const bottomKey = Key('bottom-card');
    const rightKey = Key('right-card');

    await tester.pumpWidget(
      subject(const [
        PromoActionGroup(
          direction: Axis.vertical,
          spacing: 7,
          children: [
            ColoredBox(key: topKey, color: Colors.red),
            ColoredBox(key: bottomKey, color: Colors.green),
          ],
        ),
        ColoredBox(key: rightKey, color: Colors.blue),
      ]),
    );

    expect(tester.getSize(find.byKey(topKey)), const Size(95, 76.5));
    expect(tester.getSize(find.byKey(bottomKey)), const Size(95, 76.5));
    expect(tester.getSize(find.byKey(rightKey)), const Size(95, 160));
  });
}
