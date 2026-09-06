import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';

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
