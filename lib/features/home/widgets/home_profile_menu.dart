import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/widgets/profile_avatar_image.dart';

class HomeProfileMenu extends StatelessWidget {
  const HomeProfileMenu({
    super.key,
    required this.profiles,
    required this.scale,
    required this.maxWidth,
    required this.onSelect,
  });

  final List<StudentProfile> profiles;
  final double scale;
  final double maxWidth;
  final ValueChanged<StudentProfile> onSelect;

  @override
  Widget build(BuildContext context) {
    final width = _preferredWidth(context);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12 * scale),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 240 * scale),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: 6 * scale),
            itemCount: profiles.length,
            separatorBuilder: (_, __) => SizedBox(height: scale),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final name = compactHomeProfileName(
                homeProfileDisplayName(context, profile),
              );

              return InkWell(
                onTap: () => onSelect(profile),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 13 * scale,
                    vertical: 5 * scale,
                  ),
                  child: Row(
                    children: [
                      ProfileAvatarImage(
                        size: 42 * scale,
                        avatarKey: profile.avatarKey,
                        avatarUrl: profile.avatarUrl,
                      ),
                      SizedBox(width: 11 * scale),
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _nameStyle,
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
    );
  }

  TextStyle get _nameStyle => TextStyle(
        color: const Color(0xFF002B6A),
        fontSize: FontSize.avatarName * scale,
        fontWeight: FontWeight.w900,
        height: 1.1,
      );

  double _preferredWidth(BuildContext context) {
    var longestNameWidth = 0.0;
    for (final profile in profiles) {
      final painter = TextPainter(
        text: TextSpan(
          text: compactHomeProfileName(
            homeProfileDisplayName(context, profile),
          ),
          style: _nameStyle,
        ),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      longestNameWidth = math.max(longestNameWidth, painter.width);
    }

    final fixedContentWidth = (13 * 2 + 42 + 11) * scale;
    final desiredWidth = fixedContentWidth + longestNameWidth + 10 * scale;
    return desiredWidth.clamp(150 * scale, maxWidth);
  }
}

String compactHomeProfileName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.length <= 2) {
    return parts.join(' ');
  }
  return '${parts.first} ${parts.last}';
}

String homeProfileDisplayName(
  BuildContext context,
  StudentProfile profile,
) {
  final name = profile.name?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }

  final profileCode = profile.profileCode?.trim();
  if (profileCode != null && profileCode.isNotEmpty) {
    return profileCode;
  }

  return context.getText(AppKeys.student);
}
