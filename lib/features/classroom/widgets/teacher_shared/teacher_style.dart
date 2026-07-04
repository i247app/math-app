import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';

const teacherTeal = Color(0xFF38898B);
const teacherDeepTeal = Color(0xFF3F8F92);
const teacherHero = Color(0xFF76D1CC);
const teacherMint = Color(0xFFF4FFFE);
const teacherPaleMint = Color(0xFFF0FFFF);
const teacherBlue = Color(0xFF002B6A);
const teacherInk = Color(0xFF161D1F);
const teacherMuted = Color(0xFF718096);
const teacherCoral = Color(0xFFFB7651);

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
