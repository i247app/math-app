import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/helpers/home_profile_display_helpers.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/room/models/parent_room_entry.dart';

class ParentRoomClassCard extends StatelessWidget {
  const ParentRoomClassCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onTap,
  });

  final ParentRoomEntry entry;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isBlue = index.isOdd;
    final childName = homeProfileDisplayName(context, entry.child);
    final className = roomClassName(context, entry.classroom);
    final teacherName = roomTeacherName(context, entry);
    final fg = isBlue ? colors.info : colors.brandStrong;
    final bg = isBlue ? colors.infoSurface : colors.surface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: fg.withValues(alpha: 0.22)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                teacherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg,
                  fontSize: FontSize.caption,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
