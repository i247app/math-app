import 'package:flutter_bloc/flutter_bloc.dart';

class HomeTabState {
  const HomeTabState({
    this.activeTab = 0,
    this.previousTab = 0,
  });

  final int activeTab;
  final int previousTab;
}

abstract class HomeTabCubit extends Cubit<HomeTabState> {
  HomeTabCubit({required this.maxTabIndex}) : super(const HomeTabState());

  final int maxTabIndex;

  void selectTab(int index) {
    if (index < 0 || index > maxTabIndex || index == state.activeTab) {
      return;
    }

    emit(
      HomeTabState(
        activeTab: index,
        previousTab: state.activeTab,
      ),
    );
  }
}
