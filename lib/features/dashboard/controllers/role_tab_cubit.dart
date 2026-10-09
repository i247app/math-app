import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/profile/models/profile_role.dart';

class RoleTabState {
  const RoleTabState({
    this.activeTab = DashboardTabId.home,
    this.previousTab = DashboardTabId.home,
    this.selectionRevision = 0,
  });
  final DashboardTabId activeTab;
  final DashboardTabId previousTab;
  final int selectionRevision;
}

abstract class RoleTabCubit extends Cubit<RoleTabState> {
  RoleTabCubit({required this.role}) : super(const RoleTabState());
  final ProfileRole role;

  void selectTab(DashboardTabId tab) {
    if (!supportedDashboardTabs(role).contains(tab)) return;
    emit(
      RoleTabState(
        activeTab: tab,
        previousTab: state.activeTab,
        selectionRevision: state.selectionRevision + 1,
      ),
    );
  }
}
