import 'package:flutter/material.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/home/student/home/helpers/student_home_view_helpers.dart';
import 'package:numi_flutter/features/home/student/home/widgets/student_homework_status_chip.dart';

class StudentHomeworkPreviewCard extends StatelessWidget {
  const StudentHomeworkPreviewCard({
    super.key,
    required this.exercise,
    required this.classroom,
    required this.index,
    required this.onTap,
  });

  final ClassroomExercise? exercise;
  final ClassroomModel classroom;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = index.isEven
        ? const Color(0xFFC12A73)
        : const Color(0xFFD33A82);
    final badgeColor = index.isEven
        ? const Color(0xFFFFDDE6)
        : const Color(0xFFDDF4F8);
    final badgeTextColor = index.isEven
        ? const Color(0xFFC12A73)
        : const Color(0xFF32868A);
    final title = exercise == null
        ? context.getText(AppKeys.studentNoHomeworkTitle)
        : studentModeHomeworkTitle(exercise!);
    final className = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final dueText = exercise == null
        ? context.getText(AppKeys.studentNoHomeworkMessage)
        : studentModeHomeworkDueDate(context, exercise!);

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E5969).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(5, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.90),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise == null
                                  ? ''
                                  : studentModeHomeworkCreatedDate(exercise!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B5C62),
                                fontSize: FontSize.caption * 0.82,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          StudentHomeworkStatusChip(
                            label: className,
                            color: const Color(0xFFF2F4F6),
                            textColor: const Color(0xFF4F5960),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF121B42),
                                fontSize: FontSize.normal,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                          ),
                          StudentHomeworkStatusChip(
                            label: exercise?.purpose?.trim().isNotEmpty == true
                                ? studentModePurposeLabel(exercise!.purpose!)
                                : context.getText(AppKeys.studentHomework),
                            color: badgeColor,
                            textColor: badgeTextColor,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF5D5D5D),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dueText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5D5D5D),
                                fontSize: FontSize.caption,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
