import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/shared/helpers/teacher_profile_option_helpers.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_class_avatar_picker.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_dropdown_field.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_multi_select_field.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_primary_button.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_text_field.dart';

class TeacherCreateClassForm extends StatelessWidget {
  const TeacherCreateClassForm({
    super.key,
    required this.avatarPath,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.selectedGrade,
    required this.selectedPrograms,
    required this.selectedSchool,
    required this.nameController,
    required this.descriptionController,
    required this.isSubmitting,
    required this.onPickAvatar,
    required this.onGradeChanged,
    required this.onProgramsChanged,
    required this.onSchoolChanged,
    required this.onSubmit,
  });
  final String? avatarPath;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
  final GradeModel? selectedGrade;
  final List<ProgramModel> selectedPrograms;
  final SchoolModel? selectedSchool;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isSubmitting;
  final VoidCallback onPickAvatar;
  final ValueChanged<GradeModel?> onGradeChanged;
  final ValueChanged<List<ProgramModel>> onProgramsChanged;
  final ValueChanged<SchoolModel?> onSchoolChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        spacing: 14,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TeacherClassAvatarPicker(
              avatarPath: avatarPath,
              onTap: onPickAvatar,
            ),
          ),
          TeacherDropdownField<GradeModel>(
            label: context.getText(AppKeys.teacherGradeLevel),
            value: selectedGrade,
            items: grades,
            displayText: gradeLabel,
            onChanged: onGradeChanged,
          ),
          TeacherTextField(
            label: context.getText(AppKeys.teacherClassName),
            hintText: context.getText(AppKeys.teacherClassNameHint),
            controller: nameController,
          ),
          TeacherMultiSelectField<ProgramModel>(
            label: context.getText(AppKeys.learningProgram),
            values: selectedPrograms,
            items: programs,
            displayText: programLabel,
            itemId: programStableId,
            emptyText: context.getText(AppKeys.chooseProgram),
            onChanged: onProgramsChanged,
          ),
          TeacherDropdownField<SchoolModel>(
            label: context.getText(AppKeys.school),
            value: selectedSchool,
            items: schools,
            displayText: schoolLabel,
            onChanged: onSchoolChanged,
            outlined: true,
          ),
          TeacherTextField(
            label: context.getText(AppKeys.teacherClassDescription),
            hintText: context.getText(AppKeys.teacherClassDescriptionHint),
            controller: descriptionController,
            maxLines: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Center(
              child: TeacherPrimaryButton(
                label: isSubmitting
                    ? context.getText(AppKeys.teacherCreating)
                    : context.getText(AppKeys.teacherCreate),
                icon: Icons.arrow_forward_rounded,
                width: 230,
                height: 56,
                onPressed: isSubmitting ? null : onSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
