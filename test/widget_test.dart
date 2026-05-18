import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi_flutter/main.dart';

void main() {
  testWidgets('shows NUMI welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

    expect(find.text('NUMI'), findsOneWidget);
    expect(find.text('BẮT ĐẦU'), findsOneWidget);
  });

  testWidgets('opens OTP screen after phone verification',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NumiApp());

    await tester.tap(find.text('BẮT ĐẦU'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), '0901234567');
    await tester.tap(find.text('Gửi mã OTP  →'));
    await tester.pumpAndSettle();

    expect(find.text('MÃ XÁC NHẬN'), findsOneWidget);
    expect(find.text('Xác nhận  →'), findsOneWidget);
  });
}
