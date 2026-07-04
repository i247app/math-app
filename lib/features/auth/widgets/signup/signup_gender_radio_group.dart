import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/auth/widgets/signup/signup_gender_choice.dart';

class SignupGenderRadioGroup extends StatelessWidget {
  const SignupGenderRadioGroup({
    super.key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hintText;
  final List<SignupGenderChoice> items;
  final ValueChanged<String?>? onChanged;

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
    return Container(
      height: 52,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7E7), width: 1.5),
      ),
      child: Text(
        hintText,
        style: GoogleFonts.andika(
          color: const Color(0xFF7E9088),
          fontSize: 15,
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
    final accentColor = const Color(0xFF339395);
    return SizedBox(
      height: 53,
      child: Material(
        color: selected ? const Color(0xFFE8FAF8) : Colors.white,
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
                color: selected ? accentColor : const Color(0xFFE7E7E7),
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
                    style: GoogleFonts.andika(
                      color: selected ? accentColor : AppColors.ink,
                      fontSize: 15,
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
    final accentColor = const Color(0xFF339395);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accentColor, width: selected ? 6 : 2),
        color: Colors.white,
      ),
    );
  }
}
