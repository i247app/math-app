import 'package:flutter/material.dart';

import 'package:numi/features/auth/presentation/widgets/auth_digit_box.dart';

class PasscodeInputRow extends StatelessWidget {
  const PasscodeInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.hasError,
    required this.onChanged,
    required this.onEmptyBackspace,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool hasError;
  final void Function(int index, String value) onChanged;
  final void Function(int index) onEmptyBackspace;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
          child: SizedBox(
            width: 64,
            height: 70,
            child: AuthDigitBox.passcode(
              controller: controllers[index],
              focusNode: focusNodes[index],
              // PasscodeScreen requests focus after the first frame so the
              // Android IME opens directly with its numeric configuration.
              autofocus: false,
              textInputAction: index == 3
                  ? TextInputAction.done
                  : TextInputAction.next,
              hasError: hasError,
              onChanged: (value) => onChanged(index, value),
              onEmptyBackspace: () => onEmptyBackspace(index),
            ),
          ),
        );
      }),
    );
  }
}
