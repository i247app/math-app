import 'dart:io' show Platform;

import 'package:flutter/material.dart';

ScrollBehavior getCustomBehavior() {
  if (Platform.isIOS) {
    return const ScrollBehavior();
  } else {
    return CustomScrollBehavior();
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Colors.blue,
      child: child,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
