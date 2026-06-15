part of '../presentation/teacher_classroom_screens.dart';

class _TeacherErrorPanel extends StatelessWidget {
  const _TeacherErrorPanel({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFE2E9EC)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: _teacherMuted,
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12 * scale),
          TextButton(
            onPressed: onRetry,
            child: Text(context.getText(AppKeys.retry)),
          ),
        ],
      ),
    );
  }
}

class _CoralCreateButton extends StatelessWidget {
  const _CoralCreateButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12 * scale),
          child: Ink(
            width: 218 * scale,
            height: 65 * scale,
            decoration: BoxDecoration(
              color: _teacherCoral,
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12 * scale),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.6, 0.6, 1],
                        colors: [
                          Colors.white.withValues(alpha: 0.20),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallCoralAddButton extends StatelessWidget {
  const _SmallCoralAddButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12 * scale);
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Material(
          color: _teacherCoral,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 91 * scale,
              height: 31 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12 * scale),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.6, 0.6, 1],
                          colors: [
                            Colors.white.withValues(alpha: 0.20),
                            Colors.white.withValues(alpha: 0.0),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/teacher_class_add.svg',
                    width: 12 * scale,
                    height: 12 * scale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherScreenAppBar extends StatelessWidget {
  const _TeacherScreenAppBar({
    required this.title,
    required this.scale,
    required this.onBack,
    this.action,
  });

  final String title;
  final double scale;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 0,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: SvgPicture.asset(
                'assets/images/teacher_class_back.svg',
                width: 16 * scale,
                height: 16 * scale,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _teacherTeal,
              fontSize: FontSize.title * scale,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          if (action != null)
            Align(
              alignment: Alignment.centerRight,
              child: action,
            ),
        ],
      ),
    );
  }
}

class _ClassAvatarPicker extends StatelessWidget {
  const _ClassAvatarPicker({
    required this.scale,
    required this.avatarPath,
    required this.onTap,
  });

  final double scale;
  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96 * scale,
                height: 96 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E3E6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF747781),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  image: avatarPath == null
                      ? null
                      : DecorationImage(
                          image: FileImage(File(avatarPath!)),
                          fit: BoxFit.cover,
                        ),
                ),
                child: avatarPath == null
                    ? Icon(
                        Icons.add_a_photo_outlined,
                        color: const Color(0xFF747781),
                        size: 34 * scale,
                      )
                    : null,
              ),
              Positioned(
                right: -7 * scale,
                bottom: -7 * scale,
                child: Container(
                  width: 32 * scale,
                  height: 32 * scale,
                  decoration: BoxDecoration(
                    color: _teacherTeal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x1A000000),
                        blurRadius: 15 * scale,
                        spreadRadius: -3 * scale,
                        offset: Offset(0, 10 * scale),
                      ),
                      BoxShadow(
                        color: const Color(0x1A000000),
                        blurRadius: 6 * scale,
                        spreadRadius: -4 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 15 * scale,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          context.getText(AppKeys.teacherClassImageLabel),
          style: GoogleFonts.andika(
            color: const Color(0xFF444650),
            fontSize: FontSize.normal * scale,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _TeacherTextField extends StatelessWidget {
  const _TeacherTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.scale,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final double scale;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return _TeacherFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        style: GoogleFonts.andika(
          color: _teacherInk,
          fontSize: FontSize.normal * scale,
          fontWeight: FontWeight.w400,
        ),
        decoration: _teacherInputDecoration(
          hintText: hintText,
          scale: scale,
        ),
      ),
    );
  }
}

class _TeacherDropdownField<T> extends StatelessWidget {
  const _TeacherDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
    required this.scale,
    this.outlined = false,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) displayText;
  final ValueChanged<T?> onChanged;
  final double scale;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = value == null ? null : displayText(value as T);
    final canSelect = items.isNotEmpty;

    return _TeacherFieldShell(
      label: label,
      scale: scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSelect ? () => _openSelector(context) : null,
          borderRadius:
              BorderRadius.circular(outlined ? 16 * scale : 12 * scale),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: InputDecorator(
            isEmpty: selectedLabel == null,
            decoration: _teacherInputDecoration(
              hintText: items.isEmpty
                  ? context.getText(AppKeys.teacherNoOptions)
                  : null,
              scale: scale,
              outlined: outlined,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? context.getText(AppKeys.teacherNoOptions),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: selectedLabel == null
                          ? const Color(0x806B7280)
                          : _teacherInk,
                      fontSize: FontSize.normal * scale,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: canSelect
                      ? _teacherTeal
                      : _teacherMuted.withValues(alpha: 0.45),
                  size: 22 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSelector(BuildContext context) async {
    final selected = await showModalBottomSheet<T>(
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
                    color: _teacherTeal,
                    fontSize: FontSize.title * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10 * scale),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 360 * scale),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: Color(0xFFEFF4F5),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = identical(item, value);
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            displayText(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.andika(
                              color: _teacherInk,
                              fontSize: FontSize.normal * scale,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: _teacherTeal,
                                  size: 22 * scale,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
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

    if (selected != null) {
      onChanged(selected);
    }
  }
}

class _TeacherMultiSelectField<T> extends StatelessWidget {
  const _TeacherMultiSelectField({
    required this.label,
    required this.values,
    required this.items,
    required this.displayText,
    required this.itemId,
    required this.onChanged,
    required this.scale,
    this.emptyText,
  });

  final String label;
  final List<T> values;
  final List<T> items;
  final String Function(T item) displayText;
  final int? Function(T item) itemId;
  final ValueChanged<List<T>> onChanged;
  final double scale;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = values.map(displayText).join(', ');
    final canSelect = items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeacherFieldShell(
          label: label,
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canSelect ? () => _openSelector(context) : null,
              borderRadius: BorderRadius.circular(12 * scale),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              child: InputDecorator(
                isEmpty: values.isEmpty,
                decoration: _teacherInputDecoration(
                  hintText: items.isEmpty
                      ? context.getText(AppKeys.teacherNoOptions)
                      : emptyText,
                  scale: scale,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        values.isEmpty
                            ? (emptyText ??
                                context.getText(AppKeys.teacherNoOptions))
                            : selectedLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: values.isEmpty
                              ? const Color(0x806B7280)
                              : _teacherInk,
                          fontSize: FontSize.normal * scale,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: canSelect
                          ? _teacherTeal
                          : _teacherMuted.withValues(alpha: 0.45),
                      size: 22 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (values.isNotEmpty) ...[
          SizedBox(height: 10 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: [
              for (final value in values)
                _TeacherSelectedChip(
                  label: displayText(value),
                  scale: scale,
                  onDeleted: () {
                    final id = itemId(value);
                    onChanged(
                      values
                          .where((item) => itemId(item) != id)
                          .toList(growable: false),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _openSelector(BuildContext context) async {
    final selected = await showModalBottomSheet<List<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        final maxSheetHeight = math.min(
          MediaQuery.sizeOf(context).height * 0.78,
          620 * scale,
        );
        var selectedIds = values.map(itemId).whereType<int>().toSet();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedValues = items
                .where((item) => selectedIds.contains(itemId(item)))
                .toList(growable: false);

            return Container(
              constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
                        color: _teacherTeal,
                        fontSize: FontSize.title * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: Color(0xFFEFF4F5),
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final id = itemId(item);
                          if (id == null) {
                            return const SizedBox.shrink();
                          }
                          final isSelected = selectedIds.contains(id);
                          return Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                displayText(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: _teacherInk,
                                  fontSize: FontSize.normal * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? _teacherTeal
                                    : const Color(0xFFC4C6D2),
                                size: 22 * scale,
                              ),
                              onTap: () {
                                setSheetState(() {
                                  selectedIds = Set<int>.from(selectedIds);
                                  if (isSelected) {
                                    selectedIds.remove(id);
                                  } else {
                                    selectedIds.add(id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    _TeacherPrimaryButton(
                      label: context.getText(AppKeys.save),
                      icon: Icons.check_rounded,
                      width: double.infinity,
                      height: 50 * scale,
                      scale: scale,
                      onPressed: () =>
                          Navigator.of(context).pop(selectedValues),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}

class _TeacherSelectedChip extends StatelessWidget {
  const _TeacherSelectedChip({
    required this.label,
    required this.scale,
    required this.onDeleted,
  });

  final String label;
  final double scale;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAD7BE),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 118 * scale),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: _teacherInk,
                fontSize: FontSize.caption * scale,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: Icon(
                Icons.close_rounded,
                color: _teacherInk.withValues(alpha: 0.45),
                size: 14 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherFieldShell extends StatelessWidget {
  const _TeacherFieldShell({
    required this.label,
    required this.scale,
    required this.child,
  });

  final String label;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 8 * scale),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: const Color(0xFF564148),
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              height: 1.2,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

InputDecoration _teacherInputDecoration({
  required double scale,
  String? hintText,
  bool outlined = false,
}) {
  final radius = BorderRadius.circular(outlined ? 16 * scale : 12 * scale);
  final borderColor =
      outlined ? const Color(0xFFDDE4E6) : const Color(0xFFC4C6D2);
  return InputDecoration(
    hintText: hintText,
    hintStyle: GoogleFonts.andika(
      color: const Color(0x806B7280),
      fontSize: FontSize.normal * scale,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: outlined ? Colors.white : const Color(0xFFF7FAFD),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 17 * scale,
      vertical: 16 * scale,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: _teacherTeal, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: borderColor, width: outlined ? 2 : 1),
    ),
  );
}

class _TeacherPrimaryButton extends StatelessWidget {
  const _TeacherPrimaryButton({
    required this.label,
    required this.icon,
    required this.width,
    required this.height,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double width;
  final double height;
  final double scale;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * scale),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: onPressed == null
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 2 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
          ),
          child: Material(
            color: onPressed == null
                ? _teacherTeal.withValues(alpha: 0.45)
                : _teacherTeal,
            borderRadius: BorderRadius.circular(20 * scale),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.large * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(icon, color: Colors.white, size: 18 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherFullScreenError extends StatelessWidget {
  const _TeacherFullScreenError({
    required this.message,
    required this.onRetry,
    required this.scale,
  });

  final String message;
  final VoidCallback onRetry;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: _TeacherErrorPanel(
          scale: scale,
          message: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

class _TeacherAvatar extends StatelessWidget {
  const _TeacherAvatar({
    required this.profile,
    required this.size,
  });

  final StudentProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarImage(
      size: size,
      avatarKey: profile?.avatarKey,
      avatarUrl: profile?.avatarUrl,
      borderColor: _teacherBlue.withValues(alpha: 0.10),
      borderWidth: 2,
    );
  }
}

String _displayTeacherName(StudentProfile? profile) {
  final name = profile?.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return AppStrings.current(AppKeys.teacherFallback);
}

int? _gradeStableId(GradeModel? grade) => grade?.gradeId ?? grade?.id;

int? _programStableId(ProgramModel? program) =>
    program?.programId ?? program?.id;

int? _schoolStableId(SchoolModel? school) => school?.schoolId ?? school?.id;

GradeModel? _matchGrade(List<GradeModel> grades, int? id) {
  if (id == null) {
    return null;
  }
  for (final grade in grades) {
    if (_gradeStableId(grade) == id) {
      return grade;
    }
  }
  return null;
}

ProgramModel? _matchProgram(List<ProgramModel> programs, int? id) {
  if (id == null) {
    return null;
  }
  for (final program in programs) {
    if (_programStableId(program) == id) {
      return program;
    }
  }
  return null;
}

SchoolModel? _matchSchool(List<SchoolModel> schools, int? id) {
  if (id == null) {
    return null;
  }
  for (final school in schools) {
    if (_schoolStableId(school) == id) {
      return school;
    }
  }
  return null;
}

String _gradeLabel(GradeModel grade) => grade.label?.trim().isNotEmpty == true
    ? grade.label!.trim()
    : AppStrings.current(AppKeys.grade);

String _programLabel(ProgramModel program) =>
    program.label?.trim().isNotEmpty == true
        ? program.label!.trim()
        : AppStrings.current(AppKeys.program);

String _schoolLabel(SchoolModel school) =>
    school.name?.trim().isNotEmpty == true
        ? school.name!.trim()
        : AppStrings.current(AppKeys.school);
