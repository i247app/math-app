import 'package:flutter/widgets.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/profile/domain/models/profile_role.dart';

abstract interface class DashboardTabFactory {
  Widget buildTab({
    required BuildContext context,
    required ProfileRole role,
    required DashboardTabArgs args,
  });
}
