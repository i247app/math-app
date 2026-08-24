import 'package:numi/app/navigation/app_screen.dart';

class AppCoordinatorState {
  const AppCoordinatorState({this.screen = AppScreen.welcome});

  final AppScreen screen;

  bool get isRestoringSession => screen == AppScreen.restoring;

  AppCoordinatorState copyWith({AppScreen? screen}) {
    return AppCoordinatorState(screen: screen ?? this.screen);
  }
}
