import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  static const _teal = Color(0xFF2C8B8D);
  static const _coral = Color(0xFFF97952);
  static const _taglineCoral = Color(0xFFFF7043);
  static const _background = Color(0xFFFAFCFC);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: _background,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: _WelcomeComposition(onStart: onStart),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeComposition extends StatelessWidget {
  const _WelcomeComposition({required this.onStart});

  final VoidCallback onStart;

  static const _mascotAsset = 'assets/images/welcome_figma_mascot.png';
  static const _wavesAsset = 'assets/images/welcome_figma_waves.png';
  static const _booksAsset = 'assets/images/welcome_figma_books.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(
          child: ColoredBox(color: WelcomeScreen._background),
        ),
        const Positioned(
          left: 0,
          right: 0,
          top: 75,
          height: 284,
          child: Center(
            child: SizedBox(
              width: 284,
              height: 284,
              child: Image(
                image: AssetImage(_mascotAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 329,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 211,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'NUMI',
                        style: GoogleFonts.bagelFatOne(
                          color: WelcomeScreen._teal,
                          fontSize: 40,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'NUMI',
                        style: GoogleFonts.bagelFatOne(
                          color: WelcomeScreen._coral,
                          fontSize: 40,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 385,
          child: Center(
            child: SizedBox(
              width: 170,
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.andika(
                    color: WelcomeScreen._teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    height: 22.5 / 18,
                  ),
                  children: [
                    const TextSpan(text: 'Học tập '),
                    TextSpan(
                      text: 'thông minh\n',
                      style: GoogleFonts.andika(
                        color: WelcomeScreen._taglineCoral,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        height: 22.5 / 18,
                      ),
                    ),
                    const TextSpan(text: 'Tiến bộ mỗi ngày'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 443,
          height: 6,
          child: Center(
            child: SizedBox(
              width: 48,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: WelcomeScreen._taglineCoral,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 425,
          height: 375,
          child: Center(
            child: SizedBox(
              width: 470,
              height: 375,
              child: Opacity(
                opacity: 0.7,
                child: ClipRect(
                  child: Image.asset(
                    _wavesAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 499,
          height: 209,
          child: Center(
            child: SizedBox(
              width: 361,
              height: 209,
              child: ClipRect(
                child: Image.asset(
                  _booksAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 688,
          height: 58,
          child: Center(
            child: SizedBox(
              width: 230,
              height: 58,
              child: _StartButton(onStart: onStart),
            ),
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WelcomeScreen._coral,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onStart();
        },
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            context.getText(AppKeys.start).toUpperCase(),
            style: GoogleFonts.fredoka(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
