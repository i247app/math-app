import 'package:flutter/material.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final Widget child;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontalPadding = width < 370 ? 24.0 : 32.0;

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: double.infinity,
        height: constraints.maxHeight,
        child: SingleChildScrollView(
          keyboardDismissBehavior: keyboardDismissBehavior,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
