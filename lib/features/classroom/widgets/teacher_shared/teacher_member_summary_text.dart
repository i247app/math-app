import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';

String teacherMemberSummaryText(
  BuildContext context, {
  required int members,
  required int requests,
}) {
  if (requests <= 0) {
    return context.formatText(AppKeys.teacherMemberSummaryNoRequests, {
      'members': members,
    });
  }
  return context.formatText(AppKeys.teacherMemberSummary, {
    'members': members,
    'requests': requests,
  });
}
