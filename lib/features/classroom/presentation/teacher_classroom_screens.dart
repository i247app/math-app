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
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/profile/avatar_picker.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_cubit.dart';
import 'package:numi_flutter/features/classroom/presentation/bloc/classroom_state.dart';
import 'package:numi_flutter/features/home/cache/home_profile_cache.dart';
import 'package:numi_flutter/features/home/home_api.dart';
import 'package:numi_flutter/features/home/teacher/cache/teacher_home_snapshot.dart';
import 'package:numi_flutter/features/home/widgets/home_tab_header.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/profile/profile_api.dart';
import 'package:numi_flutter/features/profile/school_api.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';

part '../../home/teacher/home/helpers/teacher_home_helpers.dart';
part '../../home/teacher/home/teacher_home_tab.dart';
part '../../home/teacher/home/widgets/teacher_assignment_skeleton_card.dart';
part '../../home/teacher/home/widgets/teacher_assignments_loading_panel.dart';
part '../../home/teacher/home/widgets/teacher_class_card.dart';
part '../../home/teacher/home/widgets/teacher_class_carousel.dart';
part '../../home/teacher/home/widgets/teacher_class_section_header.dart';
part '../../home/teacher/home/widgets/teacher_class_skeleton_card.dart';
part '../../home/teacher/home/widgets/teacher_hero_card.dart';
part '../../home/teacher/home/widgets/teacher_home_section_header.dart';
part '../../home/teacher/home/widgets/teacher_loading_panel.dart';
part '../../home/teacher/home/widgets/teacher_no_class_panel.dart';
part '../../home/teacher/home/widgets/teacher_recent_assignment_card.dart';
part '../../home/teacher/home/widgets/teacher_recent_assignment_carousel.dart';
part '../../home/teacher/home/widgets/teacher_skeleton_carousel.dart';
part '../../home/teacher/home/widgets/teacher_top_bar.dart';
part '../../home/teacher/report/teacher_report_tab.dart';
part '../../home/teacher/shared/widgets/class_default_image.dart';
part '../../home/teacher/shared/widgets/class_thumb.dart';
part '../../home/teacher/shared/widgets/teacher_skeleton_block.dart';
part '../../home/teacher/shared/widgets/teacher_skeleton_card.dart';
part '../../home/teacher/study/helpers/teacher_study_helpers.dart';
part '../../home/teacher/study/models/teacher_study_date_parts.dart';
part '../../home/teacher/study/models/teacher_study_exercise_batch.dart';
part '../../home/teacher/study/teacher_study_tab.dart';
part '../../home/teacher/study/widgets/teacher_study_class_filters.dart';
part '../../home/teacher/study/widgets/teacher_study_exercise_card.dart';
part '../../home/teacher/study/widgets/teacher_study_filter_chip.dart';
part '../../home/teacher/study/widgets/teacher_study_loading_indicator.dart';
part '../../home/teacher/study/widgets/teacher_study_purpose_filters.dart';
part '../../home/teacher/study/widgets/teacher_study_search_field.dart';
part 'teacher_classroom_tab.dart';
part '../widgets/teacher_tab/classroom_list_card.dart';
part '../widgets/teacher_tab/teacher_class_number_badge.dart';
part '../widgets/teacher_tab/teacher_classroom_add_button.dart';
part '../widgets/teacher_tab/teacher_classroom_empty_state.dart';
part '../widgets/teacher_tab/teacher_classroom_entrance.dart';
part '../widgets/teacher_tab/teacher_classroom_header.dart';
part '../widgets/teacher_tab/teacher_classroom_helpers.dart';
part '../widgets/teacher_tab/teacher_classroom_loading_content.dart';
part '../widgets/teacher_tab/teacher_classroom_search_field.dart';
part '../widgets/teacher_tab/teacher_classroom_skeleton_card.dart';
part '../widgets/teacher_tab/teacher_classroom_body.dart';
part 'teacher_create_class_screen.dart';
part '../widgets/teacher_create/create_class_result.dart';
part '../widgets/teacher_create/teacher_create_class_form.dart';
part 'teacher_class_detail_screen.dart';
part '../widgets/teacher_detail/class_code_chip.dart';
part '../widgets/teacher_detail/class_detail_helpers.dart';
part '../widgets/teacher_detail/class_detail_info_card.dart';
part '../widgets/teacher_detail/class_detail_lower_content.dart';
part '../widgets/teacher_detail/class_detail_meta_row.dart';
part '../widgets/teacher_detail/class_function_grid.dart';
part '../widgets/teacher_detail/class_function_tile.dart';
part '../widgets/teacher_detail/member_management_card.dart';
part '../../homework/presentation/teacher_homework_screen.dart';
part '../../homework/presentation/teacher_homework_detail_screen.dart';
part '../../homework/presentation/teacher_create_homework_screen.dart';
part 'teacher_class_members_screen.dart';
part '../widgets/teacher_members/teacher_class_members_content.dart';
part '../widgets/teacher_members/teacher_member_helpers.dart';
part '../widgets/teacher_members/classroom_member_avatar.dart';
part '../widgets/teacher_members/join_request_card.dart';
part '../widgets/teacher_members/join_request_row.dart';
part '../widgets/teacher_members/joined_member_avatar.dart';
part '../widgets/teacher_members/joined_member_card.dart';
part '../widgets/teacher_members/member_text_block.dart';
part '../widgets/teacher_members/request_action_icon.dart';
part '../widgets/teacher_members/send_invite_button.dart';
part '../widgets/teacher_members/student_invite_search_sheet.dart';
part '../widgets/teacher_members/student_search_result_list.dart';
part '../widgets/teacher_members/student_search_result_tile.dart';
part '../widgets/teacher_members/teacher_empty_member_text.dart';
part '../widgets/teacher_members/teacher_member_add_button.dart';
part '../widgets/teacher_members/teacher_member_section_title.dart';
part '../widgets/teacher_members/teacher_sending_invite_overlay.dart';
part '../widgets/teacher_shared/class_avatar_picker.dart';
part '../widgets/teacher_shared/coral_create_button.dart';
part '../widgets/teacher_shared/small_coral_add_button.dart';
part '../widgets/teacher_shared/teacher_avatar.dart';
part '../widgets/teacher_shared/teacher_background_refresh_label.dart';
part '../widgets/teacher_shared/teacher_dropdown_field.dart';
part '../widgets/teacher_shared/teacher_error_panel.dart';
part '../widgets/teacher_shared/teacher_field_shell.dart';
part '../widgets/teacher_shared/teacher_full_screen_error.dart';
part '../widgets/teacher_shared/teacher_multi_select_field.dart';
part '../widgets/teacher_shared/teacher_primary_button.dart';
part '../widgets/teacher_shared/teacher_screen_app_bar.dart';
part '../widgets/teacher_shared/teacher_selected_chip.dart';
part '../widgets/teacher_shared/teacher_shared_helpers.dart';
part '../widgets/teacher_shared/teacher_text_field.dart';

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
