import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/auth/helpers/auth_error_messages.dart';

void main() {
  testWidgets('blank auth errors use a visible localized fallback', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: LingoScope(
          lingo: LingoProvider(),
          child: Builder(
            builder: (context) {
              result = localizedAuthError(context, '   ');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(result, 'Response từ server không hợp lệ.');
  });
}
