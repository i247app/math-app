import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/classroom/application/read_models/parent_room_read_model.dart';
import 'package:numi/features/classroom/application/read_models/parent_room_entry.dart';
import 'package:numi/features/classroom/presentation/widgets/parent_room/parent_room_detail_meta.dart';

class ParentRoomDetailHero extends StatelessWidget {
  const ParentRoomDetailHero({super.key, required this.entry});

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
    final programName = entry.classroom.programName?.trim();
    final code = _roomCode(entry);
    final joinLink = 'numinumi.vn/join/$code';
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6038),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
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
              ),
              IconButton(
                onPressed: () => _copy(joinLink),
                icon: const Icon(Icons.share_outlined),
                color: colors.textPrimary,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 17),
            child: ParentRoomDetailMeta(
              icon: Icons.groups_2_outlined,
              label: grade,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: ParentRoomDetailMeta(
              icon: Icons.menu_book_outlined,
              label: programName?.isNotEmpty == true
                  ? programName!
                  : teacherName,
            ),
          ),
          if (description != null && description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: ParentRoomDetailMeta(
                icon: Icons.notes_rounded,
                label: description,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Material(
                  color: const Color(0xFFF4F8FA),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _copy(code),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            code,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: FontSize.xs,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 7),
                          SvgPicture.asset(
                            'assets/icons/teacher-class-copy.svg',
                            width: 15,
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/icons/teacher-class-qr.png',
                  width: 20,
                  height: 20,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFA),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      joinLink,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontSize.xs,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _copy(joinLink),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: SvgPicture.asset(
                        'assets/icons/teacher-class-copy.svg',
                        width: 17,
                        height: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roomCode(ParentRoomEntry entry) {
    final classroomCode = entry.classroom.classroomCode?.trim();
    if (classroomCode != null && classroomCode.isNotEmpty) {
      return classroomCode;
    }
    final id = entry.classroomId;
    if (id == null) {
      return 'NM-9988';
    }
    final idText = id.toString();
    final suffix = idText.length > 4
        ? idText.substring(idText.length - 4)
        : idText.padLeft(4, '0');
    return 'NM-$suffix';
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.selectionClick();
  }
}
