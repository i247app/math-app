import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/presentation/widgets/parent_messages/parent_message_avatar.dart';

class ParentMessagePreviewTile extends StatelessWidget {
  const ParentMessagePreviewTile({
    super.key,
    required this.name,
    required this.preview,
    required this.time,
    required this.onTap,
    this.asset,
    this.isGroup = false,
    this.unreadCount = 0,
  });

  final String name;
  final String preview;
  final String time;
  final VoidCallback onTap;
  final String? asset;
  final bool isGroup;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(18);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: radius,
        border: Border.all(color: colors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (isGroup)
                  Container(
                    width: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.brandStrong,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(isGroup ? 10 : 12, 12, 0, 12),
                  child: ParentMessageAvatar(
                    asset: asset,
                    isGroup: isGroup,
                    showOnline: isGroup,
                    size: 48,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: FontSize.compact,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          preview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: FontSize.small,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 11, 12, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 9,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: FontSize.xxxs,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: colors.onError,
                              fontSize: FontSize.xxxs,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
