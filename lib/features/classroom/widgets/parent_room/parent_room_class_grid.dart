import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/features/classroom/application/read_models/parent_room_read_model.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/widgets/room_class_summary_card.dart';
import 'package:numi/features/profile/application/read_models/profile_display_read_model.dart';
import 'package:numi/shared/widgets/app_responsive_card_group.dart';

class ParentRoomClassGrid extends StatelessWidget {
  const ParentRoomClassGrid({
    super.key,
    required this.entries,
    required this.onOpen,
  });

  static const _backgroundColors = <Color>[
    AppColors.brandTeal,
    AppColors.brandOrange,
    Color(0xFF8A008C),
    Color(0xFFFFB400),
  ];

  final List<ParentRoomEntry> entries;
  final ValueChanged<ParentRoomEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppResponsiveCardGroup(
      maxColumns: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        for (var index = 0; index < entries.length; index++)
          AspectRatio(
            aspectRatio: 1,
            child: RoomClassSummaryCard(
              key: ValueKey('parent-room-class-card-$index'),
              studentName: profileDisplayName(context, entries[index].child),
              className: roomClassName(context, entries[index].classroom),
              teacherName: roomTeacherName(context, entries[index]),
              backgroundColor:
                  _backgroundColors[index % _backgroundColors.length],
              onTap: () => onOpen(entries[index]),
            ),
          ),
      ],
    );
  }
}
