import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/parent/room/helpers/parent_room_helpers.dart';
import 'package:numi/features/home/parent/room/models/parent_room_entry.dart';
import 'package:numi/features/home/parent/room/widgets/parent_room_detail_meta.dart';

class ParentRoomDetailHero extends StatelessWidget {
  const ParentRoomDetailHero({required this.entry});

  final ParentRoomEntry entry;

  @override
  Widget build(BuildContext context) {
    final className = roomClassName(context, entry.classroom);
    final teacherName = roomTeacherName(context, entry);
    final grade = entry.classroom.gradeId == null
        ? context.getText(AppKeys.grade)
        : context.formatText(AppKeys.studentGradeFilter, {
            'grade': entry.classroom.gradeId,
          });
    final description = entry.classroom.description?.trim();
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFFF5C9E),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.xxxl,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => parentRoomShowComingSoon(context),
                icon: const Icon(Icons.share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ParentRoomDetailMeta(icon: Icons.groups_2_outlined, label: grade),
          const SizedBox(height: 7),
          ParentRoomDetailMeta(
            icon: Icons.workspace_premium_outlined,
            label: teacherName,
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 7),
            ParentRoomDetailMeta(icon: Icons.notes_rounded, label: description),
          ],
        ],
      ),
    );
  }
}
