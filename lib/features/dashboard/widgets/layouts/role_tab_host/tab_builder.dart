part of '../role_tab_host.dart';

extension _RoleTabBuilder on RoleTabHostState {
  Widget _buildTab(BuildContext context, DashboardTabId tab) {
    return widget.tabFactory.buildTab(
      context: context,
      role: widget.activeRole,
      args: widget.args.forActivation(
        tab: tab,
        isActive: tab == widget.args.activeTab,
        refreshTick: _activationTicks[tab] ?? 0,
      ),
    );
  }
}
