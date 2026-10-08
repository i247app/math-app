import 'dart:async';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_field_shell.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_shared_helpers.dart';
import 'package:numi/shared/widgets/option_bottom_sheet_shell.dart';

class TeacherDropdownField<T> extends StatelessWidget {
  const TeacherDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.displayText,
    required this.onChanged,
    this.outlined = false,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) displayText;
  final ValueChanged<T?> onChanged;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = value == null ? null : displayText(value as T);
    final canSelect = items.isNotEmpty;
    final colors = context.themeColors;

    return TeacherFieldShell(
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSelect ? () => _openSelector(context) : null,
          borderRadius: BorderRadius.circular(outlined ? 16 : 12),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: InputDecorator(
            isEmpty: selectedLabel == null,
            decoration: teacherInputDecoration(
              hintText: items.isEmpty
                  ? context.getText(AppKeys.teacherNoOptions)
                  : null,
              outlined: outlined,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel ?? context.getText(AppKeys.teacherNoOptions),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selectedLabel == null
                          ? colors.inputHint
                          : colors.textPrimary,
                      fontSize: FontSize.normal,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: canSelect
                      ? colors.brandStrong
                      : colors.textSecondary.withValues(alpha: 0.45),
                  size: 22,
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
        final colors = context.themeColors;
        return OptionBottomSheetShell(
          backgroundColor: colors.elevatedSurface,
          handleColor: colors.border,
          shadowColor: colors.shadow,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.brandStrong,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            OptionBottomSheetList(
              itemCount: items.length,
              dividerColor: colors.border,
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
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.normal,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: colors.brandStrong,
                            size: 22,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(item),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}
