import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/widgets/form/profile_form_field_shell.dart';
import 'package:numi/features/profile/widgets/form/profile_form_keyboard.dart';
import 'package:numi/shared/widgets/option_bottom_sheet_shell.dart';

class ProfileFormDropdown<T> extends StatelessWidget {
  const ProfileFormDropdown({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.allowEmpty = false,
    this.emptyLabel,
  });

  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool allowEmpty;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final selectedValue = items.contains(value) ? value : null;
    final selectedLabel = selectedValue == null
        ? null
        : itemLabel(selectedValue);

    return ProfileFormFieldShell(
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            dismissProfileFormKeyboard();
            _openBottomSheet(context, selectedValue);
          },
          borderRadius: BorderRadius.circular(14),
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
                        : AppColors.textPrimary,
                    fontSize: FontSize.normal,
                    fontWeight: selectedLabel == null
                        ? FontWeight.w800
                        : FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.tealIcon,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBottomSheet(BuildContext context, T? selectedValue) async {
    dismissProfileFormKeyboard();
    final result = await showModalBottomSheet<_ProfileFormSelectResult<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return OptionBottomSheetShell(
          children: [
            Text(
              label,
              style: GoogleFonts.andika(
                color: AppColors.tealIcon,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            OptionBottomSheetList(
              itemCount: items.length + (allowEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                final isEmptyOption = allowEmpty && index == 0;
                final item = isEmptyOption
                    ? null
                    : items[index - (allowEmpty ? 1 : 0)];
                final optionLabel = isEmptyOption
                    ? emptyLabel ?? context.getText(AppKeys.profileIdTypeNone)
                    : itemLabel(item as T);
                final isSelected = isEmptyOption
                    ? selectedValue == null
                    : identical(item, selectedValue) || item == selectedValue;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      optionLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: AppColors.textPrimary,
                        fontSize: FontSize.normal,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.tealIcon,
                            size: 22,
                          )
                        : null,
                    onTap: () {
                      dismissProfileFormKeyboard();
                      Navigator.of(
                        context,
                      ).pop(_ProfileFormSelectResult<T>(item));
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    dismissProfileFormKeyboard();
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      onChanged(result.value);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dismissProfileFormKeyboard();
      });
    }
  }
}

class _ProfileFormSelectResult<T> {
  const _ProfileFormSelectResult(this.value);

  final T? value;
}
