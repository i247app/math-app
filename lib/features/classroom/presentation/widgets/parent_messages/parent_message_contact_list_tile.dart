import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/presentation/widgets/parent_messages/parent_message_avatar.dart';
import 'package:numi/features/classroom/presentation/widgets/parent_messages/parent_message_contact_data.dart';

class ParentMessageContactListTile extends StatelessWidget {
  const ParentMessageContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onMore,
  });

  final ParentMessageContactData contact;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
          child: Row(
            spacing: 14,
            children: [
              ParentMessageAvatar(
                asset: contact.asset,
                showOnline: contact.isOnline,
                size: 48,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3,
                  children: [
                    Text(
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      contact.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: contact.isOnline
                            ? colors.success
                            : colors.textMuted,
                        fontSize: FontSize.xs,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMore,
                icon: const Icon(Icons.more_horiz_rounded),
                color: colors.textMuted,
                tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
