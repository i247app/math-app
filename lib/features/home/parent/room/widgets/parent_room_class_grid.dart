import 'package:flutter/material.dart';
import 'package:numi/features/home/parent/room/models/parent_room_entry.dart';
import 'package:numi/features/home/parent/room/widgets/parent_room_class_card.dart';

class ParentRoomClassGrid extends StatelessWidget {
  const ParentRoomClassGrid({
    super.key,
    required this.entries,
    required this.onTap,
  });

  final List<ParentRoomEntry> entries;
  final ValueChanged<ParentRoomEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.length == 1) {
      final entry = entries.first;
      return SizedBox(
        width: double.infinity,
        height: 101,
        child: ParentRoomClassCard(
          entry: entry,
          index: 0,
          onTap: () => onTap(entry),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
        mainAxisExtent: 101,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ParentRoomClassCard(
          entry: entry,
          index: index,
          onTap: () => onTap(entry),
        );
      },
    );
  }
}
