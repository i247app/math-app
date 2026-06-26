import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_language.dart';
import 'package:numi_flutter/core/localization/lingo_scope.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

const _languageBackground = Color(0xFFEEF9FB);
const _languageNavy = Color(0xFF063A7B);
const _languageInk = Color(0xFF253228);
const _languagePink = Color(0xFFC1277D);
const _languageCardBorder = Color(0xFFE3DDDF);
const _languageHeaderLine = Color(0xFFDE8C4B);
const _languageSwitchMinimumDuration = Duration(milliseconds: 1500);

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  static const _designWidth = 390.0;
  static const _designHeight = 844.0;

  bool _isChangingLanguage = false;

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    final lingo = LingoScope.read(context);
    if (lingo.language == language) {
      return;
    }

    setState(() => _isChangingLanguage = true);
    try {
      await Future.wait<void>([
        lingo.setLanguage(language),
        Future<void>.delayed(_languageSwitchMinimumDuration),
      ]);
      if (mounted) {
        setState(() => _isChangingLanguage = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isChangingLanguage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LingoScope.of(context).language;
    final media = MediaQuery.of(context);
    final width = math.min(media.size.width, 430.0);
    final scale =
        math.min(width / _designWidth, media.size.height / _designHeight);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: !_isChangingLanguage,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: _languageBackground,
              body: SafeArea(
                child: Center(
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LanguageHeader(scale: scale),
                        SizedBox(height: 62 * scale),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                          child: Column(
                            children: [
                              _LanguageOptionCard(
                                flag: '🇻🇳',
                                title:
                                    context.getText(AppKeys.languageVietnamese),
                                selected: currentLanguage == AppLanguage.vi,
                                scale: scale,
                                onTap: () => _changeLanguage(AppLanguage.vi),
                              ),
                              SizedBox(height: 18 * scale),
                              _LanguageOptionCard(
                                flag: '🇺🇸',
                                title: context.getText(AppKeys.languageEnglish),
                                selected: currentLanguage == AppLanguage.en,
                                scale: scale,
                                onTap: () => _changeLanguage(AppLanguage.en),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_isChangingLanguage)
              Positioned.fill(
                child: LoadingScreen(
                  message: context.getText(AppKeys.switchingLanguage),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageHeader extends StatelessWidget {
  const _LanguageHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70 * scale,
      child: CustomPaint(
        painter: _LanguageHeaderCurvePainter(scale: scale),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            8 * scale,
            20 * scale,
            12 * scale,
          ),
          child: Row(
            children: [
              _LanguageBackButton(scale: scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.languageTitle),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _languageNavy,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(width: 44 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageBackButton extends StatelessWidget {
  const _LanguageBackButton({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 44 * scale;

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).maybePop();
        },
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _languageNavy,
            size: 26 * scale,
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.flag,
    required this.title,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String flag;
  final String title;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? _languagePink : _languageCardBorder;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: 18 * scale,
            vertical: 18 * scale,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFFF2F8)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(26 * scale),
            border: Border.all(color: borderColor, width: 2 * scale),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: selected ? 0.18 : 0.06),
                blurRadius: 14 * scale,
                offset: Offset(0, 5 * scale),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48 * scale,
                height: 48 * scale,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFE4F1)
                      : const Color(0xFFEFF7F8),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  flag,
                  style: TextStyle(fontSize: FontSize.xxxl * scale, height: 1),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _languageInk,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34 * scale,
                height: 34 * scale,
                decoration: BoxDecoration(
                  color: selected ? _languagePink : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _languagePink,
                    width: 2.4 * scale,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24 * scale,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageHeaderCurvePainter extends CustomPainter {
  const _LanguageHeaderCurvePainter({required this.scale});

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = _languageBackground;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final linePaint = Paint()
      ..color = _languageHeaderLine.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * scale;

    final path = Path()
      ..moveTo(0, size.height - 12 * scale)
      ..quadraticBezierTo(
        size.width / 2,
        size.height - 4 * scale,
        size.width,
        size.height - 12 * scale,
      );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LanguageHeaderCurvePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
