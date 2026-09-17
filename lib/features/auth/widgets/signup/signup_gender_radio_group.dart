import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_choice.dart';

class SignupGenderRadioGroup extends StatelessWidget {
  const SignupGenderRadioGroup({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  final SignupGender? value;
  final String hintText;
  final List<SignupGenderChoice> items;
  final ValueChanged<SignupGender?>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty || onChanged == null) {
      return _SignupGenderDisabledHint(hintText: hintText);
    }

    return Row(
      children: [
        for (final item in items) ...[
          Expanded(
            child: _SignupGenderRadioItem(
              label: context.getText(item.labelKey),
              selected: value == item.value,
              onTap: () {
                final nextValue = value == item.value ? null : item.value;
                onChanged?.call(nextValue);
              },
            ),
          ),
          if (item != items.last) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _SignupGenderDisabledHint extends StatelessWidget {
  const _SignupGenderDisabledHint({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colors.inputSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Text(
        hintText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: colors.inputHint,
          fontSize: FontSize.compact,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SignupGenderRadioItem extends StatelessWidget {
  const _SignupGenderRadioItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final accentColor = colors.brandStrong;

    return SizedBox(
      height: 53,
      child: Material(
        color: selected
            ? colors.brand.withValues(alpha: 0.12)
            : colors.inputSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accentColor : colors.border,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SignupGenderRadioMark(selected: selected),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: selected ? accentColor : colors.textPrimary,
                      fontSize: FontSize.compact,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
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

class _SignupGenderRadioMark extends StatelessWidget {
  const _SignupGenderRadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final accentColor = colors.brandStrong;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: selected ? 6 : 2),
        color: colors.inputSurface,
      ),
    );
  }
}
