import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.onBack,
    this.title,
    this.titleWidget,
  });

  final VoidCallback onBack;
  final String? title;
  final Widget? titleWidget;

  static const _backIconAsset = 'assets/icons/pin-figma-back.svg';
  static const _mascotAsset = 'assets/images/numi-mascot.png';

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: PageHeader(
            scale: 1,
            backgroundColor: Colors.transparent,
            actionWidth: 44,
            horizontalPadding: 20,
            verticalPadding: 8,
            leading: AppBackButton(
              iconAsset: _backIconAsset,
              onPressed: onBack,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 74),
            const RepaintBoundary(child: Center(child: _AuthMascot())),
            if (titleWidget != null || title != null) ...[
              const SizedBox(height: 4),
              Center(
                child:
                    titleWidget ??
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: colors.textPrimary,
                        fontSize: FontSize.displayLarge,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                        letterSpacing: 0,
                      ),
                    ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AuthMascot extends StatelessWidget {
  const _AuthMascot();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 184),
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Image.asset(AuthHeader._mascotAsset, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
