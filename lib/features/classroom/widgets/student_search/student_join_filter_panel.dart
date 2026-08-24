import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/school_models.dart';
import 'package:numi/features/classroom/helpers/student_class_search_helpers.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_filter_label.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_grade_chip.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_retry_banner.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_school_filter_field.dart';
import 'package:numi/features/classroom/widgets/student_search/student_join_selected_filter_pill.dart';

class StudentJoinFilterPanel extends StatelessWidget {
  const StudentJoinFilterPanel({
    super.key,
    required this.grades,
    required this.schools,
    required this.selectedGradeIds,
    required this.selectedSchoolIds,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onGradeTap,
    required this.onGradeRemove,
    required this.onSchoolTap,
    required this.onSchoolRemove,
  });

  final List<GradeModel> grades;
  final List<SchoolModel> schools;
  final Set<int> selectedGradeIds;
  final Set<int> selectedSchoolIds;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<GradeModel> onGradeTap;
  final ValueChanged<int> onGradeRemove;
  final VoidCallback onSchoolTap;
  final ValueChanged<int> onSchoolRemove;

  @override
  Widget build(BuildContext context) {
    final selectedSchools = selectedStudentJoinSchools(
      schools,
      selectedSchoolIds,
    );
    final showSchoolFilter = error == null || schools.isNotEmpty;
    final showGradeFilter = error == null || grades.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null) ...[
            StudentJoinRetryBanner(message: error!, onRetry: onRetry),
          ],
          if (showSchoolFilter) ...[
            Padding(
              padding: EdgeInsets.only(top: error != null ? 13 : 0),
              child: StudentJoinFilterLabel(context.getText(AppKeys.school)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: StudentJoinSchoolFilterField(
                valueText: selectedSchools.isEmpty
                    ? context.getText(AppKeys.chooseSchool)
                    : selectedSchools
                          .map(
                            (school) => studentJoinSchoolName(context, school),
                          )
                          .join(', '),
                selected: selectedSchools.isNotEmpty,
                isLoading: isLoading,
                onTap: schools.isEmpty ? null : onSchoolTap,
              ),
            ),
            if (selectedSchools.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final school in selectedSchools)
                      StudentJoinSelectedFilterPill(
                        label: studentJoinSchoolName(context, school),
                        onRemove: () {
                          final schoolId = schoolStableId(school);
                          if (schoolId != null) {
                            onSchoolRemove(schoolId);
                          }
                        },
                      ),
                  ],
                ),
              ),
          ],
          if (showGradeFilter) ...[
            Padding(
              padding: EdgeInsets.only(
                top: showSchoolFilter || error != null ? 13 : 0,
              ),
              child: StudentJoinFilterLabel(context.getText(AppKeys.grade)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: isLoading && grades.isEmpty
                  ? const SizedBox(
                      height: 30,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : grades.isEmpty
                  ? Text(
                      context.getText(AppKeys.noGrades),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: FontSize.xs,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: grades.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 30,
                          ),
                      itemBuilder: (context, index) {
                        final grade = grades[index];
                        return StudentJoinGradeChip(
                          label: studentJoinGradeLabel(context, grade),
                          selected: selectedGradeIds.contains(
                            gradeStableId(grade),
                          ),
                          onTap: () => onGradeTap(grade),
                          onRemove: () {
                            final gradeId = gradeStableId(grade);
                            if (gradeId != null) {
                              onGradeRemove(gradeId);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
