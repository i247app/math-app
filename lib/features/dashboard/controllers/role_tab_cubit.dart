import 'package:flutter_bloc/flutter_bloc.dart';

class RoleTabState {
  const RoleTabState({
    this.activeTab = 0,
    this.previousTab = 0,
    this.selectionRevision = 0,
  });

  final int activeTab;
  final int previousTab;
  final int selectionRevision;
}

abstract class RoleTabCubit extends Cubit<RoleTabState> {
  RoleTabCubit({required this.maxTabIndex}) : super(const RoleTabState());

  final int maxTabIndex;

  void selectTab(int index) {
    if (index < 0 || index > maxTabIndex) {
      return;
    }

    emit(
      RoleTabState(
        activeTab: index,
        previousTab: state.activeTab,
        selectionRevision: state.selectionRevision + 1,
      ),
    );
  }
}
