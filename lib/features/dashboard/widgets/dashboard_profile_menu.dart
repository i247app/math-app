import 'package:flutter/material.dart';

import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/helpers/profile_display_helpers.dart';
import 'package:numi/features/profile/widgets/profile_avatar_image.dart';

class DashboardProfileMenu extends StatelessWidget {
  const DashboardProfileMenu({
    super.key,
    required this.profiles,
    required this.onSelect,
  });

  final List<StudentProfile> profiles;
  final ValueChanged<StudentProfile> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox(
      width: 240,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.42),
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Material(
          color: colors.elevatedSurface,
          elevation: 0,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: profiles.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final profile = profiles[index];
                final name = compactProfileName(
                  profileDisplayName(context, profile),
                );

                return InkWell(
                  onTap: () => onSelect(profile),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 5,
                    ),
                    child: Row(
                      spacing: 11,
                      children: [
                        ProfileAvatarImage(
                          size: 42,
                          avatarKey: profile.avatarKey,
                          avatarUrl: profile.avatarUrl,
                        ),
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _nameStyle(colors),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _nameStyle(AppThemeColors colors) => TextStyle(
    color: colors.textPrimary,
    fontSize: FontSize.avatarName,
    fontWeight: FontWeight.w900,
    height: 1.1,
  );
}
