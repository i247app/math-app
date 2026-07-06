import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    required this.onPressed,
    this.iconAsset = 'assets/images/pin_figma_back.svg',
    this.size = 44,
  });

  final VoidCallback onPressed;
  final String iconAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Material(
        color: Colors.white.withValues(alpha: 0.8),
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: const Color(0xFFA2B1A3).withValues(alpha: 0.1),
          ),
        ),
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed();
          },
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child: SvgPicture.asset(iconAsset, width: 16, height: 16),
          ),
        ),
      ),
    );
  }
}
