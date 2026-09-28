import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class PasscodeInputRow extends StatelessWidget {
  const PasscodeInputRow({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    this.showDigits = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final VoidCallback onChanged;
  final bool showDigits;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Center(
      child: SizedBox(
        width: 292,
        height: 70,
        child: Stack(
          children: [
            ExcludeSemantics(
              child: IgnorePointer(
                child: Row(
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                      child: Container(
                        width: 64,
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.inputSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: hasError
                                ? colors.error
                                : colors.passcodeBorder,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.passcodeShadow,
                              blurRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: index < controller.text.length
                            ? Text(
                                showDigits ? controller.text[index] : '•',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: colors.textPrimary,
                                      fontSize: FontSize.displayMedium,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                      letterSpacing: 0,
                                    ),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                alwaysIncludeSemantics: true,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: !showDigits,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged(),
                  onTap: () {
                    controller.selection = TextSelection.collapsed(
                      offset: controller.text.length,
                    );
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
