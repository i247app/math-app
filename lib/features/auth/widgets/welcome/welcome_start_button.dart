import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/auth/widgets/welcome/welcome_style.dart';

class WelcomeStartButton extends StatelessWidget {
  const WelcomeStartButton({
    super.key,
    required this.onStart,
    required this.scale,
  });

  final VoidCallback onStart;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20 * scale);

    return Material(
      color: WelcomeStyle.coral,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: radius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.getText(AppKeys.continueLabel),
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            SizedBox(width: 9 * scale),
            SvgPicture.asset(
              'assets/images/welcome_screen/welcome_arrow_right.svg',
              width: 16 * scale,
              height: 16 * scale,
            ),
          ],
        ),
      ),
    );
  }
}
