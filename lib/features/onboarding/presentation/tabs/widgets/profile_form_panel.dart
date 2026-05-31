part of '../setting_tab.dart';

class _AddProfilePanel extends StatelessWidget {
  const _AddProfilePanel({
    super.key,
    required this.nameController,
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
    final idTypeOptions =
        isTeacherProfile ? _teacherIdTypeOptions : _studentIdTypeOptions;
    final selectedIdTypeOption = _firstIdTypeOption(
      idTypeOptions,
      selectedIdType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddProfileAvatar(
          avatarKey: avatarKey,
          avatarUrl: avatarUrl,
          scale: scale,
          onChanged: onAvatarChanged,
          onClear: onClearAvatar,
        ),
        SizedBox(height: 28 * scale),
        _AddProfileTextField(
          label: context.getText(AppKeys.fullName),
          controller: nameController,
          hintText: isTeacherProfile
              ? context.getText(AppKeys.profileTeacherNameHint)
              : context.getText(AppKeys.studentNameHint),
          scale: scale,
        ),
        SizedBox(height: 18 * scale),
        if (isLoadingOptions)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 58 * scale),
            child: Center(
              child: CircularProgressIndicator(
                color: _teal,
                strokeWidth: 3 * scale,
              ),
            ),
          )
        else ...[
          _AddProfileDropdown<SchoolModel>(
            label: context.getText(AppKeys.school),
            hintText: context.getText(AppKeys.chooseSchool),
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
            _AddProfileDropdown<ProgramModel>(
              label: context.getText(AppKeys.learningProgram),
              hintText: context.getText(AppKeys.chooseProgram),
              value: selectedProgram,
              items: programs,
              itemLabel: (program) => program.label?.trim().isNotEmpty == true
                  ? program.label!.trim()
                  : context.getText(AppKeys.program),
              onChanged: onProgramChanged,
              scale: scale,
            ),
            SizedBox(height: 18 * scale),
            _AddProfileDropdown<GradeModel>(
              label: context.getText(AppKeys.grade),
              hintText: context.getText(AppKeys.chooseGrade),
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
          _AddProfileDropdown<_ProfileIdTypeOption>(
            label: context.getText(AppKeys.profileIdTypeLabel),
            hintText: context.getText(AppKeys.profileIdTypeHint),
            value: selectedIdTypeOption,
            items: idTypeOptions,
            itemLabel: (option) => context.getText(option.label),
            onChanged: (option) => onIdTypeChanged(option?.value),
            allowEmpty: true,
            emptyLabel: context.getText(AppKeys.profileIdTypeNone),
            scale: scale,
          ),
          SizedBox(height: 18 * scale),
          _AddProfileTextField(
            label: context.getText(AppKeys.profileIdValueLabel),
            controller: idController,
            hintText: isTeacherProfile
                ? context.getText(AppKeys.profileTeacherIdHint)
                : context.getText(AppKeys.profileStudentIdHint),
            scale: scale,
          ),
        ],
        if (error != null && error.isNotEmpty) ...[
          SizedBox(height: 14 * scale),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _orange,
              fontSize: 13 * scale,
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
                    color: _teal,
                    fontSize: 13 * scale,
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
            _CancelButton(scale: scale, onTap: isSaving ? () {} : onCancel),
            SizedBox(width: 14 * scale),
            Opacity(
              opacity: isSaving ? 0.72 : 1,
              child:
                  _SaveButton(scale: scale, onTap: isSaving ? () {} : onSave),
            ),
          ],
        ),
      ],
    );
  }

  static _ProfileIdTypeOption? _firstIdTypeOption(
    List<_ProfileIdTypeOption> options,
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

class _AddProfileAvatar extends StatelessWidget {
  const _AddProfileAvatar({
    required this.avatarKey,
    required this.avatarUrl,
    required this.scale,
    required this.onChanged,
    required this.onClear,
  });

  final String? avatarKey;
  final String? avatarUrl;
  final double scale;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final key = avatarKey?.trim();
    final url = avatarUrl?.trim();
    final hasCatalogAvatar = ProfileAvatarCatalog.urlForKey(key) != null;
    final size = 124 * scale;

    return Center(
      child: Semantics(
        button: true,
        label: context.getText(AppKeys.chooseAvatar),
        child: SizedBox(
          width: size + 24 * scale,
          height: size + 24 * scale,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => _openAvatarSheet(context, key),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EAED),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: ProfileAvatarImage(
                    size: size,
                    avatarKey: key,
                    avatarUrl: hasCatalogAvatar ? null : url,
                    foregroundColor: const Color(0xFFD3DEE1),
                    borderColor: Colors.white,
                    borderWidth: 4 * scale,
                  ),
                ),
              ),
              if (key != null && key.isNotEmpty)
                Positioned(
                  left: 14 * scale,
                  bottom: 18 * scale,
                  child: Material(
                    color: const Color(0xFFFFD8D8),
                    elevation: 5,
                    shadowColor:
                        const Color(0xFFE83434).withValues(alpha: 0.16),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClear,
                      child: SizedBox(
                        width: 38 * scale,
                        height: 38 * scale,
                        child: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFFE83434),
                          size: 22 * scale,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10 * scale,
                bottom: 18 * scale,
                child: Material(
                  color: _teal,
                  elevation: 5,
                  shadowColor: _teal.withValues(alpha: 0.24),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _openAvatarSheet(context, key),
                    child: SizedBox(
                      width: 36 * scale,
                      height: 36 * scale,
                      child: Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                        size: 18 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAvatarSheet(
      BuildContext context, String? selectedKey) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return FractionallySizedBox(
          heightFactor: 0.68,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              10 * scale,
              20 * scale,
              bottomInset + 20 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28 * scale),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24 * scale,
                  offset: Offset(0, -8 * scale),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 46 * scale,
                      height: 5 * scale,
                      margin: EdgeInsets.only(bottom: 14 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E9EC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    context.getText(AppKeys.chooseAvatar),
                    style: GoogleFonts.andika(
                      color: _teal,
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 16 * scale,
                        crossAxisSpacing: 16 * scale,
                      ),
                      itemCount: ProfileAvatarCatalog.options.length,
                      itemBuilder: (context, index) {
                        final option = ProfileAvatarCatalog.options[index];
                        final isSelected = option.key == selectedKey;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).pop(option.key),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ProfileAvatarImage(
                                  size: 82 * scale,
                                  avatarKey: option.key,
                                  borderColor:
                                      isSelected ? _teal : Colors.transparent,
                                  borderWidth: 4 * scale,
                                ),
                                if (isSelected)
                                  Positioned(
                                    right: 4 * scale,
                                    bottom: 4 * scale,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: _teal,
                                      size: 24 * scale,
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
      },
    );

    if (result != null) {
      onChanged(result);
    }
  }
}

class _AddProfileTextField extends StatelessWidget {
  const _AddProfileTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.scale,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AddProfileFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: GoogleFonts.andika(
          color: _deepInk,
          fontSize: 15 * scale,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.andika(
            color: const Color(0xFFA8B1B2),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AddProfileDropdown<T> extends StatelessWidget {
  const _AddProfileDropdown({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.scale,
    this.allowEmpty = false,
    this.emptyLabel,
  });

  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final double scale;
  final bool allowEmpty;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.contains(value) ? value : null;
    final selectedLabel =
        selectedValue == null ? null : itemLabel(selectedValue);

    return _AddProfileFieldShell(
      label: label,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openBottomSheet(context, selectedValue),
          borderRadius: BorderRadius.circular(14 * scale),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedLabel ?? hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: selectedLabel == null
                        ? const Color(0xFFA8B1B2)
                        : _deepInk,
                    fontSize: 15 * scale,
                    fontWeight: selectedLabel == null
                        ? FontWeight.w800
                        : FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _teal,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBottomSheet(BuildContext context, T? selectedValue) async {
    final result = await showModalBottomSheet<_AddProfileSelectResult<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            10 * scale,
            20 * scale,
            bottomInset + 18 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28 * scale),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24 * scale,
                offset: Offset(0, -8 * scale),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 46 * scale,
                    height: 5 * scale,
                    margin: EdgeInsets.only(bottom: 14 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E9EC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.andika(
                    color: _teal,
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10 * scale),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360 * scale),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length + (allowEmpty ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFEFF4F5),
                    ),
                    itemBuilder: (context, index) {
                      final isEmptyOption = allowEmpty && index == 0;
                      final item = isEmptyOption
                          ? null
                          : items[index - (allowEmpty ? 1 : 0)];
                      final optionLabel = isEmptyOption
                          ? emptyLabel ??
                              context.getText(AppKeys.profileIdTypeNone)
                          : itemLabel(item as T);
                      final isSelected = isEmptyOption
                          ? selectedValue == null
                          : identical(item, selectedValue) ||
                              item == selectedValue;

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            optionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.andika(
                              color: _deepInk,
                              fontSize: 16 * scale,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              letterSpacing: 0,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: _teal,
                                  size: 22 * scale,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(
                            _AddProfileSelectResult<T>(item),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      onChanged(result.value);
    }
  }
}

class _AddProfileSelectResult<T> {
  const _AddProfileSelectResult(this.value);

  final T? value;
}

class _AddProfileFieldShell extends StatelessWidget {
  const _AddProfileFieldShell({
    required this.label,
    required this.child,
    required this.scale,
  });

  final String label;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: const Color(0xFF604950),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          height: 56 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFD8E4E7), width: 1.6),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}
