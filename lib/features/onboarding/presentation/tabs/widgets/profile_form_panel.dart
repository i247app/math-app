part of '../setting_tab.dart';

class _AddProfilePanel extends StatelessWidget {
  const _AddProfilePanel({
    super.key,
    required this.nameController,
    required this.avatarPath,
    required this.avatarUrl,
    required this.grades,
    required this.programs,
    required this.selectedGrade,
    required this.selectedProgram,
    required this.isLoadingOptions,
    required this.isPickingAvatar,
    required this.isSaving,
    required this.errorMessage,
    required this.canRetryOptions,
    required this.onPickAvatar,
    required this.onClearAvatar,
    required this.onGradeChanged,
    required this.onProgramChanged,
    required this.onRetryOptions,
    required this.onCancel,
    required this.onSave,
    required this.scale,
  });

  final TextEditingController nameController;
  final String? avatarPath;
  final String? avatarUrl;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final GradeModel? selectedGrade;
  final ProgramModel? selectedProgram;
  final bool isLoadingOptions;
  final bool isPickingAvatar;
  final bool isSaving;
  final String? errorMessage;
  final bool canRetryOptions;
  final VoidCallback onPickAvatar;
  final VoidCallback onClearAvatar;
  final ValueChanged<GradeModel?> onGradeChanged;
  final ValueChanged<ProgramModel?> onProgramChanged;
  final VoidCallback onRetryOptions;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddProfileAvatar(
          avatarPath: avatarPath,
          avatarUrl: avatarUrl,
          isPicking: isPickingAvatar,
          scale: scale,
          onTap: onPickAvatar,
          onClear: onClearAvatar,
        ),
        SizedBox(height: 28 * scale),
        _AddProfileTextField(
          label: context.getText(AppKeys.fullName),
          controller: nameController,
          hintText: context.getText(AppKeys.studentNameHint),
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
}

class _AddProfileAvatar extends StatelessWidget {
  const _AddProfileAvatar({
    required this.avatarPath,
    required this.avatarUrl,
    required this.isPicking,
    required this.scale,
    required this.onTap,
    required this.onClear,
  });

  final String? avatarPath;
  final String? avatarUrl;
  final bool isPicking;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath?.trim();
    final url = avatarUrl?.trim();
    final size = 124 * scale;

    return Center(
      child: SizedBox(
        width: size + 24 * scale,
        height: size + 24 * scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
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
                border: Border.all(color: Colors.white, width: 4 * scale),
              ),
              child: ClipOval(
                child: path != null && path.isNotEmpty
                    ? Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.person_rounded,
                            color: const Color(0xFFD3DEE1),
                            size: 56 * scale,
                          );
                        },
                      )
                    : url != null && url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Icon(
                                Icons.person_rounded,
                                color: const Color(0xFFD3DEE1),
                                size: 56 * scale,
                              );
                            },
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: const Color(0xFFD3DEE1),
                            size: 56 * scale,
                          ),
              ),
            ),
            if (isPicking)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (path != null && path.isNotEmpty)
              Positioned(
                left: 14 * scale,
                bottom: 18 * scale,
                child: Material(
                  color: const Color(0xFFFFD8D8),
                  elevation: 5,
                  shadowColor: const Color(0xFFE83434).withValues(alpha: 0.16),
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
                  onTap: onTap,
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
    );
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
  });

  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AddProfileFieldShell(
      label: label,
      scale: scale,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _teal,
            size: 24 * scale,
          ),
          hint: Text(
            hintText,
            style: GoogleFonts.andika(
              color: const Color(0xFFA8B1B2),
              fontSize: 15 * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: GoogleFonts.andika(
            color: _deepInk,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
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
