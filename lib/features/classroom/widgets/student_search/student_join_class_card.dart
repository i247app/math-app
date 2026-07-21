import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/widgets/student_search/student_class_search_assets.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/helpers/classroom_display_helpers.dart';
import 'package:numi/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_class_action_state.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_class_badge.dart';

class StudentJoinClassCard extends StatelessWidget {
  const StudentJoinClassCard({
    super.key,
    required this.classroom,
    required this.isJoining,
    required this.onJoin,
  });

  final ClassroomModel classroom;
  final bool isJoining;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final name = classroomDisplayName(context, classroom);
    final teacher = classroomTeacherName(
      context,
      classroom,
      fallbackToSchool: true,
    );
    final code = classroomCode(classroom);
    final action = StudentJoinClassActionState.fromRelationship(
      classroom.relationshipStatus,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 87,
            decoration: const BoxDecoration(
              color: AppColors.orange700,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0C6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        studentJoinBookIcon,
                        width: 33,
                        height: 29.25,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textNavy,
                              fontSize: FontSize.normal,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              letterSpacing: 0,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              teacher,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 5,
                              children: [
                                if (code != null)
                                  StudentJoinClassBadge(
                                    label: context.formatText(
                                      AppKeys.studentClassCodeLabel,
                                      {'code': code},
                                    ),
                                    color: const Color(0xFFE5E8EB),
                                    textColor: const Color(0xFF747781),
                                  ),
                                StudentJoinClassBadge(
                                  label: context.getText(action.labelKey),
                                  color: action.badgeColor,
                                  textColor: action.badgeTextColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 62,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: isJoining || !action.canRequest
                          ? null
                          : onJoin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: action.buttonColor,
                        disabledBackgroundColor: action.buttonColor,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: isJoining
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : SvgPicture.asset(
                              action.iconPath,
                              width: action.iconWidth,
                              height: action.iconHeight,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
