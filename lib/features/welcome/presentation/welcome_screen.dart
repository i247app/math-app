import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/features/welcome/widgets/welcome_composition.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onLogin,
  });

  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _didPrecacheNextScreenAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheNextScreenAssets) {
      return;
    }

    _didPrecacheNextScreenAssets = true;
    const welcomeAssetPrefix = 'assets/images/welcome_screen/';
    precacheImage(
      const AssetImage('assets/images/welcome_figma_mascot.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/welcome_figma_waves.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/welcome_figma_books.png'),
      context,
    );
    precacheImage(
      const AssetImage('${welcomeAssetPrefix}welcome_hero_math_friends.png'),
      context,
    );
    precacheImage(
      const AssetImage('${welcomeAssetPrefix}welcome_logo_mascot.png'),
      context,
    );
    precacheImage(
      const AssetImage('${welcomeAssetPrefix}welcome_card_assessment.png'),
      context,
    );
    precacheImage(
      const AssetImage('${welcomeAssetPrefix}welcome_card_teacher_support.png'),
      context,
    );
    precacheImage(
      const AssetImage(
        '${welcomeAssetPrefix}welcome_card_progress_tracking.png',
      ),
      context,
    );
    precacheImage(
      const AssetImage('${welcomeAssetPrefix}welcome_card_game_learning.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: ColoredBox(
        color: colors.pageBackground,
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: WelcomeComposition(
                  onStart: widget.onStart,
                  onLogin: widget.onLogin,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
