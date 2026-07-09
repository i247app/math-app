import 'package:flutter/material.dart';
import 'package:numi_flutter/features/home/helpers/home_dashboard_helpers.dart';
import 'package:numi_flutter/features/home/widgets/home_dashboard_args.dart';
import 'package:numi_flutter/features/games/presentation/games_tab.dart';
import 'package:numi_flutter/features/home/parent/assessment/parent_assessment_tab.dart';
import 'package:numi_flutter/features/home/parent/home/parent_home_tab.dart';
import 'package:numi_flutter/features/home/parent/room/parent_room_tab.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key, required this.args});

  final HomeDashboardArgs args;

  @override
  Widget build(BuildContext context) {
    if (args.activeTab == 0) {
      return ParentHomeContent(args: args);
    }

    if (args.activeTab == 1) {
      return ParentAssessmentTab(args: args);
    }

    if (args.activeTab == 2) {
      return ParentRoomTab(args: args);
    }

    if (args.activeTab == 3) {
      return GamesTab(
        userId: args.user?.id,
        initialGrades: args.initialGrades,
        gradeService: args.gradeService,
        initialGradeId: profileGradeId(args.activeProfile),
        initialGradeLabel: args.activeProfile?.grade?.label,
        bottomPadding: args.bottomPadding,
      );
    }

    if (args.activeTab == 4) {
      return dashboardSettings(args);
    }

    return const SizedBox.shrink();
  }
}