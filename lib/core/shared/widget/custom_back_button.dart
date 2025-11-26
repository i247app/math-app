import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final bool? canGoHome;
  final VoidCallback? onCustomBack;

  const CustomBackButton({
    super.key,
    this.canGoHome = false,
    this.onCustomBack,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (onCustomBack != null) {
          onCustomBack!();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
