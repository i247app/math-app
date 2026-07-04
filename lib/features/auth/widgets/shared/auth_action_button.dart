import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthActionButtonLayout { fullWidth, compact }

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.layout = AuthActionButtonLayout.fullWidth,
    this.isBusy = false,
    this.uppercase = false,
  });

  static const _compactWidth = 230.0;
  static const _height = 58.0;
  static const _backgroundColor = Color(0xFF339395);
  static const _disabledColor = Color(0xFFB5BFC2);

  final String label;
  final VoidCallback? onPressed;
  final AuthActionButtonLayout layout;
  final bool isBusy;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: layout == AuthActionButtonLayout.fullWidth
          ? double.infinity
          : _compactWidth,
      height: _height,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _disabledColor,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: isBusy
              ? const SizedBox(
                  key: ValueKey('busy'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : _AuthActionButtonLabel(
                  key: ValueKey(label),
                  label: uppercase ? label.toUpperCase() : label,
                ),
        ),
      ),
    );

    if (layout == AuthActionButtonLayout.compact) {
      return Center(child: button);
    }

    return button;
  }
}

class _AuthActionButtonLabel extends StatelessWidget {
  const _AuthActionButtonLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
