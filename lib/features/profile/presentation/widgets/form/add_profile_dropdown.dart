import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/presentation/widgets/form/add_profile_field_shell.dart';
import 'package:numi/features/profile/presentation/widgets/form/add_profile_select_result.dart';
import 'package:numi/features/profile/presentation/widgets/form/profile_form_keyboard.dart';

class AddProfileDropdown<T> extends StatelessWidget {
  const AddProfileDropdown({
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

    return AddProfileFieldShell(
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
    final result = await showModalBottomSheet<AddProfileSelectResult<T>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, -8),
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
                    width: 46,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E9EC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.andika(
                    color: AppColors.tealIcon,
                    fontSize: FontSize.xxxl,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length + (allowEmpty ? 1 : 0),
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: Color(0xFFEFF4F5)),
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
                              ).pop(AddProfileSelectResult<T>(item));
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
