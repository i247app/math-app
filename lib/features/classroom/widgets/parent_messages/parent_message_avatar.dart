import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ParentMessageAvatar extends StatelessWidget {
  const ParentMessageAvatar({
    super.key,
    this.asset,
    this.isGroup = false,
    this.showOnline = false,
    this.size = 48,
  });

  final String? asset;
  final bool isGroup;
  final bool showOnline;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: isGroup
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.brandStrong,
                      borderRadius: BorderRadius.circular(size * 0.28),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: colors.onBrand,
                      size: size * 0.52,
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      asset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: colors.infoSurface,
                        child: Icon(
                          Icons.person_rounded,
                          color: colors.brandStrong,
                          size: size * 0.54,
                        ),
                      ),
                    ),
                  ),
          ),
          if (showOnline)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.23,
                height: size * 0.23,
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.elevatedSurface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
