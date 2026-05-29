import 'package:flutter/widgets.dart';

import 'lingo_provider.dart';

class LingoScope extends InheritedNotifier<LingoProvider> {
  const LingoScope({
    super.key,
    required LingoProvider lingo,
    required super.child,
  }) : super(notifier: lingo);

  static LingoProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LingoScope>();
    assert(scope != null, 'No LingoScope found in context.');
    return scope!.notifier!;
  }

  static LingoProvider read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<LingoScope>();
    final scope = element?.widget as LingoScope?;
    assert(scope != null, 'No LingoScope found in context.');
    return scope!.notifier!;
  }
}
