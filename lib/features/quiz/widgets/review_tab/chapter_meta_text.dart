part of '../../review_tab.dart';

String _chapterMetaText(BuildContext context, PracticeChapter chapter) {
  final label = chapter.description?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }

  if (chapter.lessonCount <= 0) {
    return '${context.getText(AppKeys.chapter)} ${chapter.number}';
  }

  return '${context.getText(AppKeys.chapter)} ${chapter.number} • '
      '${chapter.lessonCount} ${context.getText(AppKeys.lessons)}';
}
