import 'package:flutter/material.dart';
import 'package:numi/features/classroom/presentation/tabs/student_classroom_tab.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/dashboard/navigation/parent_tab_host.dart';

class StudentTabHost extends StatelessWidget {
  const StudentTabHost({super.key, required this.args});

  final DashboardTabArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 2) {
      return StudentClassroomTab(
        bottomPadding: args.bottomPadding,
        user: args.user,
        activeProfile: args.activeProfile,
        classroomService: args.classroomService,
        isActive: args.isActive,
        activeRefreshTick: args.activeRefreshTick,
      );
    }

    return ParentTabHost(args: args);
  }
}
