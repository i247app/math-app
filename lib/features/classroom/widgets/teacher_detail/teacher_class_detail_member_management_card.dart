import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/helpers/teacher_member_summary_helpers.dart';

class TeacherClassDetailMemberManagementCard extends StatelessWidget {
  const TeacherClassDetailMemberManagementCard({
    super.key,
    required this.memberCount,
    required this.requestCount,
    required this.onTap,
  });
  final int memberCount;
  final int requestCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 77),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/icons/teacher-class-members.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.getText(AppKeys.teacherMemberManagement),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1E3A5F),
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w700,
                            height: 1.22,
                          ),
                        ),
                        Text(
                          teacherMemberSummaryText(
                            context,
                            members: memberCount,
                            requests: requestCount,
                          ),
                          maxLines: requestCount > 0 ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textCoolMuted,
                            fontSize: FontSize.small,
                            fontWeight: FontWeight.w400,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/teacher-class-chevron.svg',
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
