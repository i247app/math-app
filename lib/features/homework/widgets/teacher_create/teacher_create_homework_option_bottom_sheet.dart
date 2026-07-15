import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_colors.dart';

class CreateHomeworkOptionBottomSheet<T> extends StatelessWidget {
  const CreateHomeworkOptionBottomSheet({
    super.key,
    required this.options,
    required this.titleKey,
    required this.isSelected,
    required this.titleBuilder,
    required this.bottomInset,
    this.subtitleBuilder,
  });

  final List<T> options;
  final String titleKey;
  final bool Function(T option) isSelected;
  final String Function(BuildContext context, T option) titleBuilder;
  final String Function(BuildContext context, T option)? subtitleBuilder;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
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
              context.getText(titleKey),
              style: GoogleFonts.andika(
                color: AppColors.teal520,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Color(0xFFEFF4F5)),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final selected = isSelected(option);
                  final subtitle = subtitleBuilder?.call(context, option);
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        titleBuilder(context, option),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: AppColors.textInkDark,
                          fontSize: 16,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: subtitle == null
                          ? null
                          : Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.andika(
                                color: AppColors.textCoolMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.teal520,
                              size: 22,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
