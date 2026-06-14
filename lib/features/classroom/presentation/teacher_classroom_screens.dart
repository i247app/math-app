import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_strings.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/network/program_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/profile/avatar_picker.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_state.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/profile/profile_api.dart';
import 'package:numi_flutter/features/profile/school_api.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';

part '../../home/teacher/teacher_home_tab.dart';
part '../../home/teacher/teacher_report_tab.dart';
part 'teacher_classroom_tab.dart';
part '../../home/teacher/teacher_study_tab.dart';
part 'teacher_create_class_screen.dart';
part 'teacher_class_detail_screen.dart';
part '../../homework/presentation/teacher_homework_screen.dart';
part '../../homework/presentation/teacher_homework_detail_screen.dart';
part '../../homework/presentation/teacher_create_homework_screen.dart';
part 'teacher_class_members_screen.dart';
part '../widgets/teacher_shared_widgets.dart';

const _teacherTeal = Color(0xFF38898B);
const _teacherDeepTeal = Color(0xFF3F8F92);
const _teacherHero = Color(0xFF76D1CC);
const _teacherMint = Color(0xFFF4FFFE);
const _teacherPaleMint = Color(0xFFF0FFFF);
const _teacherBlue = Color(0xFF002B6A);
const _teacherInk = Color(0xFF161D1F);
const _teacherMuted = Color(0xFF718096);
const _teacherCoral = Color(0xFFFB7651);

String _teacherMemberSummaryText(
  BuildContext context, {
  required int members,
  required int requests,
}) {
  if (requests <= 0) {
    return context.formatText(
      AppKeys.teacherMemberSummaryNoRequests,
      {'members': members},
    );
  }
  return context.formatText(
    AppKeys.teacherMemberSummary,
    {
      'members': members,
      'requests': requests,
    },
  );
}
