part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherCreateClassForm extends StatelessWidget {
  const _TeacherCreateClassForm({
    required this.scale,
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

  final double scale;
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
      padding: EdgeInsets.fromLTRB(
        28 * scale,
        24 * scale,
        28 * scale,
        24 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ClassAvatarPicker(
            scale: scale,
            avatarPath: avatarPath,
            onTap: onPickAvatar,
          ),
          SizedBox(height: 20 * scale),
          _TeacherDropdownField<GradeModel>(
            label: context.getText(AppKeys.teacherGradeLevel),
            value: selectedGrade,
            items: grades,
            displayText: _gradeLabel,
            onChanged: onGradeChanged,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _TeacherTextField(
            label: context.getText(AppKeys.teacherClassName),
            hintText: context.getText(AppKeys.teacherClassNameHint),
            controller: nameController,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _TeacherMultiSelectField<ProgramModel>(
            label: context.getText(AppKeys.learningProgram),
            values: selectedPrograms,
            items: programs,
            displayText: _programLabel,
            itemId: _programStableId,
            emptyText: context.getText(AppKeys.chooseProgram),
            onChanged: onProgramsChanged,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _TeacherDropdownField<SchoolModel>(
            label: context.getText(AppKeys.school),
            value: selectedSchool,
            items: schools,
            displayText: _schoolLabel,
            onChanged: onSchoolChanged,
            scale: scale,
            outlined: true,
          ),
          SizedBox(height: 14 * scale),
          _TeacherTextField(
            label: context.getText(AppKeys.teacherClassDescription),
            hintText: context.getText(AppKeys.teacherClassDescriptionHint),
            controller: descriptionController,
            scale: scale,
            maxLines: 4,
          ),
          SizedBox(height: 28 * scale),
          Center(
            child: _TeacherPrimaryButton(
              label: isSubmitting
                  ? context.getText(AppKeys.teacherCreating)
                  : context.getText(AppKeys.teacherCreate),
              icon: Icons.arrow_forward_rounded,
              width: 230 * scale,
              height: 56 * scale,
              scale: scale,
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
