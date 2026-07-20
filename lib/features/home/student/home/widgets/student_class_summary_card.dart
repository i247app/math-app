import 'package:numi/features/classroom/helpers/classroom_display_helpers.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentClassSummaryCard extends StatelessWidget {
  const StudentClassSummaryCard({
    super.key,
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final className = classroomDisplayName(context, classroom);
    final teacherName = classroomTeacherName(context, classroom);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 144,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFDDF8EE), Color(0xFFD7E8FF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -88,
                top: 29,
                child: SizedBox(
                  width: 244,
                  height: 244,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9ECFF).withValues(alpha: 0.56),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3265E6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                Text(
                                  context.getText(AppKeys.studentClassroom),
                                  style: const TextStyle(
                                    color: Color(0xFF34495B),
                                    fontSize: FontSize.normal,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                className,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF14358A),
                                  fontSize: FontSize.displayMedium,
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                teacherName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF5C666C),
                                  fontSize: FontSize.normal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
