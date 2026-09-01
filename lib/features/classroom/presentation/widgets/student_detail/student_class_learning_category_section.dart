import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom/presentation/widgets/student_detail/student_class_category_tile.dart';
import 'package:numi/features/classroom/presentation/widgets/student_detail/student_class_section_title.dart';
import 'package:numi/features/homework/presentation/screens/student_homework_screen.dart';

class StudentClassLearningCategorySection extends StatelessWidget {
  const StudentClassLearningCategorySection({
    super.key,
    required this.classroomId,
    required this.profileId,
    required this.homeworkCount,
    required this.isLoadingHomework,
  });

  final int classroomId;
  final int profileId;
  final int homeworkCount;
  final bool isLoadingHomework;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudentClassSectionTitle(
          context.getText(AppKeys.studentClassLearningCategories),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              StudentClassCategoryTile(
                backgroundColor: const Color(0xFFFDF0F5),
                iconAsset: 'assets/icons/student-class-assignment.svg',
                title: context.getText(AppKeys.studentClassAssignments),
                subtitle: isLoadingHomework && homeworkCount == 0
                    ? ''
                    : context.formatText(
                        AppKeys.studentClassAssignmentsCountFormat,
                        {'count': homeworkCount},
                      ),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => StudentHomeworkScreen(
                      classroomId: classroomId,
                      profileId: profileId,
                    ),
                  ),
                ),
              ),
              StudentClassCategoryTile(
                backgroundColor: const Color(0xFFFDF4EE),
                iconAsset: 'assets/icons/student-class-quiz.svg',
                title: context.getText(AppKeys.studentClassQuizzes),
                subtitle: context.getText(AppKeys.studentClassQuizzesSubtitle),
              ),
              StudentClassCategoryTile(
                backgroundColor: const Color(0xFFF0F4FF),
                iconAsset: 'assets/icons/student-class-resources.svg',
                title: context.getText(AppKeys.studentClassMaterials),
                subtitle: context.getText(
                  AppKeys.studentClassMaterialsSubtitle,
                ),
              ),
              StudentClassCategoryTile(
                backgroundColor: const Color(0xFFEDFBF3),
                iconAsset: 'assets/icons/student-class-grades.svg',
                title: context.getText(AppKeys.studentClassGrades),
                subtitle: context.getText(AppKeys.studentClassGradesSubtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
