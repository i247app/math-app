import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class NotificationStatusView extends StatelessWidget {
  const NotificationStatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final contentHeight = constraints.maxHeight > 48
            ? constraints.maxHeight - 48
            : 0.0;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            28,
            24,
            28,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: contentHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 18,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: colors.elevatedSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: colors.brandStrong, size: 34),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.andika(
                            color: colors.textPrimary,
                            fontSize: FontSize.large,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.andika(
                            color: colors.textSecondary,
                            fontSize: FontSize.small,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                    if (onAction != null && actionLabel != null)
                      FilledButton(
                        onPressed: onAction,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.brandStrong,
                          foregroundColor: colors.onBrand,
                        ),
                        child: Text(actionLabel!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    final refresh = onRefresh;
    if (refresh == null) {
      return content;
    }
    return RefreshIndicator(
      color: colors.brandStrong,
      onRefresh: refresh,
      child: content,
    );
  }
}
