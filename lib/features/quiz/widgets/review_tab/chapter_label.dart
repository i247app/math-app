part of '../../review_tab.dart';

String _chapterLabel(ChapterModel chapter) {
  return _nonEmpty(chapter.label) ?? 'Chapter';
}
