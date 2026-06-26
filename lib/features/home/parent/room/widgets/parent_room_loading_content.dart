part of '../../../home_screen.dart';

class _ParentRoomLoadingContent extends StatelessWidget {
  const _ParentRoomLoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          padding: EdgeInsets.zero,
          children: const [
            _ParentRoomSkeletonBlock(),
            _ParentRoomSkeletonBlock(),
          ],
        ),
        const SizedBox(height: 24),
        const _ParentRoomSkeletonLine(width: 128),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonLine(width: 92),
        const SizedBox(height: 14),
        const _ParentRoomSkeletonBlock(height: 104),
      ],
    );
  }
}
