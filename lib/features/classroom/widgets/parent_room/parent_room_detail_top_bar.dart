import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ParentRoomDetailTopBar extends StatelessWidget {
  const ParentRoomDetailTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        boxShadow: [
          BoxShadow(color: colors.shadow, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                onBack();
              },
              icon: Icon(Icons.arrow_back_rounded, color: colors.brandStrong),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.brandStrong,
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
