import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_ai_app/ui/onboarding%20screen/view/onboarding_screen.dart';


@immutable
class RoutesName {
  const RoutesName._();
  static const String onBoarding = '/onBoarding';
  static const String signUp = '/signUp';
  static const String login = '/login';
}

@immutable
class AppRouter {
  PageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.onBoarding:
        return _getPageRoute(routeName: settings.name, viewToShow: const OnboardingScreen());
      default:
        return _getPageRoute(
          routeName: settings.name,
          viewToShow: Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }

  PageRoute _getPageRoute({String? routeName, Widget? viewToShow}) {
    return CupertinoPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => viewToShow!,
    );
  }
}
