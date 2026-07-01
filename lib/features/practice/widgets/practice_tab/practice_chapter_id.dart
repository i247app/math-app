part of '../../practice_tab.dart';

String _practiceChapterId(ChapterModel chapter) {
  final id = chapter.chapterId ?? chapter.id;
  return id == null ? 'chapter-${chapter.displayOrder ?? 0}' : '$id';
}
