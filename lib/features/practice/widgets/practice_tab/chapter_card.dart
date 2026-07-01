part of '../../practice_tab.dart';

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.chapter,
    required this.completedLessons,
    required this.totalLessons,
    required this.selected,
    required this.selectionMode,
    required this.onToggleSelected,
    required this.onStartTest,
    required this.scale,
  });

  final PracticeChapter chapter;
  final int completedLessons;
  final int totalLessons;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onToggleSelected;
  final VoidCallback onStartTest;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = _chapterColors(chapter.number);
    final showButton = !selectionMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleSelected,
        borderRadius: BorderRadius.circular(28 * scale),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(20 * scale),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(28 * scale),
            border: selected
                ? Border.all(color: _selectPink, width: 2.5 * scale)
                : null,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.13),
                blurRadius: 22 * scale,
                offset: Offset(0, 10 * scale),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(icon: chapter.icon, scale: scale),
                  SizedBox(width: 14 * scale),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 3 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _chapterMetaText(context, chapter),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _reviewMuted,
                              fontSize: FontSize.normal * scale,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            chapter.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _reviewInk,
                              fontSize: FontSize.xxxl * scale,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  _SelectCircle(selected: selected, scale: scale),
                ],
              ),
              if (showButton) ...[
                SizedBox(height: 20 * scale),
                _TestButton(enabled: true, scale: scale, onTap: onStartTest),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
