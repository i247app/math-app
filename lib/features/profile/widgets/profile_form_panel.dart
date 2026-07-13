import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/profile/models/profile_id_type_option.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/account/settings_cancel_button.dart';
import 'package:numi/features/settings/widgets/account/settings_save_button.dart';
import 'package:numi/features/profile/widgets/form/add_profile_avatar.dart';
import 'package:numi/features/profile/widgets/form/add_profile_dropdown.dart';
import 'package:numi/features/profile/widgets/form/add_profile_text_field.dart';

class AddProfilePanel extends StatelessWidget {
  const AddProfilePanel({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.idController,
    required this.role,
    required this.avatarKey,
    required this.avatarUrl,
    required this.schools,
    required this.grades,
    required this.programs,
    required this.selectedSchool,
    required this.selectedGrade,
    required this.selectedProgram,
    required this.selectedIdType,
    required this.isLoadingOptions,
    required this.isSaving,
    required this.canSave,
    required this.errorMessage,
    required this.canRetryOptions,
    required this.onAvatarChanged,
    required this.onClearAvatar,
    required this.onSchoolChanged,
    required this.onGradeChanged,
    required this.onProgramChanged,
    required this.onIdTypeChanged,
    required this.onRetryOptions,
    required this.onCancel,
    required this.onSave,
    required this.scale,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController idController;
  final String role;
  final String? avatarKey;
  final String? avatarUrl;
  final List<SchoolModel> schools;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final SchoolModel? selectedSchool;
  final GradeModel? selectedGrade;
  final ProgramModel? selectedProgram;
  final String? selectedIdType;
  final bool isLoadingOptions;
  final bool isSaving;
  final bool canSave;
  final String? errorMessage;
  final bool canRetryOptions;
  final ValueChanged<String> onAvatarChanged;
  final VoidCallback onClearAvatar;
  final ValueChanged<SchoolModel?> onSchoolChanged;
  final ValueChanged<GradeModel?> onGradeChanged;
  final ValueChanged<ProgramModel?> onProgramChanged;
  final ValueChanged<String?> onIdTypeChanged;
  final VoidCallback onRetryOptions;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage?.trim();
    final isTeacherProfile = role == 'TEACHER';
    final isParentProfile = role == 'PARENT';
    final idTypeOptions = isTeacherProfile
        ? teacherProfileIdTypeOptions
        : studentProfileIdTypeOptions;
    final selectedIdTypeOption = _firstIdTypeOption(
      idTypeOptions,
      selectedIdType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddProfileAvatar(
          avatarKey: avatarKey,
          avatarUrl: avatarUrl,
          scale: scale,
          onChanged: onAvatarChanged,
          onClear: onClearAvatar,
        ),
        SizedBox(height: 28 * scale),
        AddProfileTextField(
          label: context.getText(AppKeys.fullName),
          controller: nameController,
          hintText: isTeacherProfile
              ? context.getText(AppKeys.profileTeacherNameHint)
              : isParentProfile
              ? context.getText(AppKeys.parentProfileNameHint)
              : context.getText(AppKeys.studentNameHint),
          scale: scale,
        ),
        if (isParentProfile) ...[
          SizedBox(height: 18 * scale),
          AddProfileTextField(
            label: context.getText(AppKeys.email),
            controller: emailController,
            hintText: context.getText(AppKeys.parentProfileEmailHint),
            keyboardType: TextInputType.emailAddress,
            scale: scale,
          ),
          SizedBox(height: 18 * scale),
          AddProfileTextField(
            label: context.getText(AppKeys.phoneNumber),
            controller: phoneController,
            hintText: context.getText(AppKeys.parentProfilePhoneHint),
            keyboardType: TextInputType.phone,
            scale: scale,
          ),
        ],
        if (!isParentProfile) ...[
          SizedBox(height: 18 * scale),
          if (isLoadingOptions)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 58 * scale),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.tealIcon,
                  strokeWidth: 3 * scale,
                ),
              ),
            ),
          if (!isLoadingOptions) ...[
            AddProfileDropdown<SchoolModel>(
              label: context.getText(AppKeys.school),
              hintText: context.getText(AppKeys.notSelected),
              value: selectedSchool,
              items: schools,
              itemLabel: (school) => school.name?.trim().isNotEmpty == true
                  ? school.name!.trim()
                  : context.getText(AppKeys.noSchools),
              onChanged: onSchoolChanged,
              scale: scale,
            ),
            SizedBox(height: 18 * scale),
            if (!isTeacherProfile) ...[
              AddProfileDropdown<ProgramModel>(
                label: context.getText(AppKeys.learningProgram),
                hintText: context.getText(AppKeys.notSelected),
                value: selectedProgram,
                items: programs,
                itemLabel: (program) => program.label?.trim().isNotEmpty == true
                    ? program.label!.trim()
                    : context.getText(AppKeys.program),
                onChanged: onProgramChanged,
                scale: scale,
              ),
              SizedBox(height: 18 * scale),
              AddProfileDropdown<GradeModel>(
                label: context.getText(AppKeys.grade),
                hintText: context.getText(AppKeys.notSelected),
                value: selectedGrade,
                items: grades,
                itemLabel: (grade) => grade.label?.trim().isNotEmpty == true
                    ? grade.label!.trim()
                    : context.getText(AppKeys.grade),
                onChanged: onGradeChanged,
                scale: scale,
              ),
              SizedBox(height: 18 * scale),
            ],
            if (isTeacherProfile) ...[
              AddProfileDropdown<ProfileIdTypeOption>(
                label: context.getText(AppKeys.profileIdTypeLabel),
                hintText: context.getText(AppKeys.profileIdTypeHint),
                value: selectedIdTypeOption,
                items: idTypeOptions,
                itemLabel: (option) => context.getText(option.labelKey),
                onChanged: (option) => onIdTypeChanged(option?.value),
                scale: scale,
              ),
              SizedBox(height: 18 * scale),
            ],
            AddProfileTextField(
              label: context.getText(AppKeys.profileIdValueLabel),
              controller: idController,
              hintText: isTeacherProfile
                  ? context.getText(AppKeys.profileTeacherIdHint)
                  : context.getText(AppKeys.profileStudentIdHint),
              scale: scale,
            ),
          ],
        ],
        if (error != null && error.isNotEmpty) ...[
          SizedBox(height: 14 * scale),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: AppColors.orange500,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          if (canRetryOptions && !isSaving && !isLoadingOptions) ...[
            SizedBox(height: 10 * scale),
            Center(
              child: TextButton(
                onPressed: onRetryOptions,
                child: Text(
                  context.getText(AppKeys.reloadOptions),
                  style: GoogleFonts.andika(
                    color: AppColors.tealIcon,
                    fontSize: FontSize.caption * scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ],
        SizedBox(height: 90 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SettingsCancelButton(
              scale: scale,
              onTap: isSaving ? () {} : onCancel,
            ),
            SizedBox(width: 14 * scale),
            Opacity(
              opacity: isSaving ? 0.72 : 1,
              child: SettingsSaveButton(
                scale: scale,
                enabled: canSave,
                onTap: onSave,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static ProfileIdTypeOption? _firstIdTypeOption(
    List<ProfileIdTypeOption> options,
    String? value,
  ) {
    final normalized = value?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    for (final option in options) {
      if (option.value == normalized) {
        return option;
      }
    }
    return null;
  }
}
