part of '../../../home_screen.dart';

class _ParentRoomClassGrid extends StatelessWidget {
  const _ParentRoomClassGrid({
    required this.entries,
    required this.onTap,
  });

  final List<_ParentRoomEntry> entries;
  final ValueChanged<_ParentRoomEntry> onTap;

  @override
  Widget build(BuildContext context) {
    if (entries.length == 1) {
      final entry = entries.first;
      return SizedBox(
        width: double.infinity,
        height: 101,
        child: _ParentRoomClassCard(
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
        return _ParentRoomClassCard(
          entry: entry,
          index: index,
          onTap: () => onTap(entry),
        );
      },
    );
  }
}
