import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/chapter_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/quiz/chapter_api.dart';
import 'package:numi_flutter/features/quiz/practice_catalog.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/assessment_screen.dart';
import 'package:numi_flutter/features/quiz/presentation/practice_chapter_screen.dart';

const _reviewInk = Color(0xFF14213D);
const _reviewMuted = Color(0xFF77859A);
const _reviewBackground = Color(0xFFEEF9FB);
const _headerNavy = Color(0xFF063A7B);
const _selectPink = Color(0xFFB72A7F);
const _checkPink = Color(0xFFFF4081);
const _uncheckedCircle = Color(0xFF8B5CF6);
const _testYellow = Color(0xFFFFC400);
const _testShadow = Color(0xFFD18400);

PracticeChapter _parentPreviewChapter(BuildContext context) {
  const titleKeys = <String>[
    AppKeys.practiceLesson18Title,
    AppKeys.practiceLesson19Title,
    AppKeys.practiceLesson20Title,
    AppKeys.practiceLesson21Title,
    AppKeys.practiceLesson22Title,
    AppKeys.practiceLesson23Title,
    AppKeys.practiceLesson24Title,
    AppKeys.practiceLesson25Title,
    AppKeys.practiceLesson26Title,
    AppKeys.practiceLesson27Title,
  ];
  final source = gradeOnePracticeChapters[1];

  return PracticeChapter(
    number: source.number,
    title: source.title,
    completedLessons: 2,
    icon: source.icon,
    lessons: List.generate(
      titleKeys.length,
      (index) => PracticeLesson(
        number: source.lessons[index].number,
        title: context.getText(titleKeys[index]),
      ),
    ),
  );
}

class ReviewTab extends StatefulWidget {
  const ReviewTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.isParentMode,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onAddProfile,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final bool isParentMode;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final VoidCallback onAddProfile;
  final double bottomPadding;
  final double scale;

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final ChapterService _chapterService = ChapterApi();
  final QuizService _quizService = QuizApi();

  List<PracticeChapter> _chapters = const <PracticeChapter>[];
  bool _isLoadingChapters = false;
  bool _isGeneratingPracticeQuiz = false;
  String? _chapterLoadError;
  int _loadRequestId = 0;
  final Set<int> _selectedChapterNumbers = <int>{};

  @override
  void initState() {
    super.initState();
    if (!widget.isParentMode) {
      _loadChaptersForActiveProfile();
    }
  }

  @override
  void didUpdateWidget(covariant ReviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProfileId = ActiveProfileSession.profileStableId(
      oldWidget.activeProfile,
    );
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    if (!widget.isParentMode &&
        (oldWidget.isParentMode ||
            oldWidget.user?.id != widget.user?.id ||
            oldProfileId != profileId)) {
      _loadChaptersForActiveProfile();
    }
  }

  Future<void> _loadChaptersForActiveProfile() async {
    final requestId = ++_loadRequestId;
    final profile = widget.activeProfile;
    if (profile == null) {
      setState(() {
        _isLoadingChapters = false;
        _chapters = const <PracticeChapter>[];
        _selectedChapterNumbers.clear();
      });
      return;
    }

    setState(() {
      _isLoadingChapters = false;
      _chapterLoadError = null;
      _chapters = const <PracticeChapter>[];
      _selectedChapterNumbers.clear();
    });

    await _loadChaptersForProfile(profile, requestId);
  }

  Future<void> _loadChaptersForProfile(
    StudentProfile? profile,
    int requestId,
  ) async {
    if (profile == null) {
      return;
    }

    final programId = _profileProgramId(profile);
    final gradeId = _profileGradeId(profile);
    final semesterId = _profileSemesterId(profile);
    if (programId == null || gradeId == null || semesterId == null) {
      setState(() {
        _chapterLoadError = context.readText(AppKeys.chapterMissingProfileInfo);
        _chapters = const <PracticeChapter>[];
      });
      return;
    }

    setState(() {
      _isLoadingChapters = true;
      _chapterLoadError = null;
    });

    try {
      final chapters = await _chapterService.listChapters(
        programId: programId,
        gradeId: gradeId,
        semesterId: semesterId,
      );
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _chapters = _practiceChaptersFromApi(chapters);
        _isLoadingChapters = false;
      });
    } on ChapterException catch (error) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _chapterLoadError = error.message;
        _isLoadingChapters = false;
      });
    } catch (_) {
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _chapterLoadError = context.readText(AppKeys.chapterLoadFailed);
        _isLoadingChapters = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    if (widget.isParentMode) {
      return ColoredBox(
        color: _reviewBackground,
        child: PracticeChapterScreen(
          chapter: _parentPreviewChapter(context),
          embedded: true,
          bottomPadding: widget.bottomPadding,
        ),
      );
    }

    final totalLessons = _chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.lessonCount,
    );
    final completedLessons = _chapters.fold<int>(
      0,
      (sum, chapter) => sum + chapter.completedLessons,
    );

    final hasSelection = _selectedChapterNumbers.isNotEmpty;
    final selectedCtaGap = 26 * scale;
    final selectedCtaHeight = 68 * scale;

    return ColoredBox(
      color: _reviewBackground,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: widget.bottomPadding +
                  (hasSelection ? selectedCtaHeight + selectedCtaGap : 0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReviewHeader(scale: scale, topInset: topInset),
                SizedBox(height: 18 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: _buildBody(
                    chapters: _chapters,
                    totalLessons: totalLessons,
                    completedLessons: completedLessons,
                    scale: scale,
                  ),
                ),
              ],
            ),
          ),
          if (hasSelection)
            Positioned(
              left: 24 * scale,
              right: 24 * scale,
              bottom: widget.bottomPadding + selectedCtaGap,
              child: Row(
                children: [
                  Expanded(
                    child: _StartSelectedButton(
                      count: _selectedChapterNumbers.length,
                      scale: scale,
                      onTap: _startSelectedTest,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  _ClearSelectionButton(scale: scale, onTap: _clearSelection),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _toggleChapter(PracticeChapter chapter) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_selectedChapterNumbers.add(chapter.number)) {
        _selectedChapterNumbers.remove(chapter.number);
      }
    });
  }

  Future<void> _startSingleTest(PracticeChapter chapter) async {
    HapticFeedback.mediumImpact();
    await _generatePracticeQuiz(<PracticeChapter>[chapter]);
  }

  void _clearSelection() {
    HapticFeedback.selectionClick();
    setState(_selectedChapterNumbers.clear);
  }

  Future<void> _startSelectedTest() async {
    HapticFeedback.mediumImpact();
    final selectedChapters = _chapters
        .where((chapter) => _selectedChapterNumbers.contains(chapter.number))
        .toList();
    await _generatePracticeQuiz(selectedChapters);
  }

  Future<void> _generatePracticeQuiz(List<PracticeChapter> chapters) async {
    if (_isGeneratingPracticeQuiz || chapters.isEmpty) {
      return;
    }

    final chapterNames = chapters
        .map((chapter) => chapter.title.trim())
        .where((chapter) => chapter.isNotEmpty)
        .toList();
    if (chapterNames.isEmpty) {
      return;
    }

    setState(() => _isGeneratingPracticeQuiz = true);

    final result = await Navigator.of(context).push<AiAssessmentResult>(
      MaterialPageRoute<AiAssessmentResult>(
        builder: (_) => AiAssessmentScreen(
          quizService: _quizService,
          purpose: quizPurposePractice,
          typeOfQuiz: quizTypeGeneral,
          gradeLabel: assessmentQuizGradeLabel,
          chapters: chapterNames,
          profileId: ActiveProfileSession.profileStableId(
            widget.activeProfile,
          ),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isGeneratingPracticeQuiz = false;
      if (result != AiAssessmentResult.generationFailed) {
        _selectedChapterNumbers.clear();
      }
    });

    if (result == AiAssessmentResult.generationFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.createQuestionFailed))),
      );
    }
  }

  Widget _buildBody({
    required List<PracticeChapter> chapters,
    required int totalLessons,
    required int completedLessons,
    required double scale,
  }) {
    if (_isLoadingChapters) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 140 * scale),
        child: Center(
          child: CircularProgressIndicator(
            color: _headerNavy,
            strokeWidth: 3 * scale,
          ),
        ),
      );
    }

    final error = widget.profileLoadError?.trim();
    if (error != null && error.isNotEmpty) {
      return _ReviewProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.profileLoadErrorTitle),
        message: error,
        buttonLabel: context.getText(AppKeys.retry),
        onTap: widget.onRefreshProfiles,
        scale: scale,
      );
    }

    if (widget.activeProfile == null) {
      return _ReviewProfileStatePanel(
        icon: Icons.groups_2_outlined,
        title: context.getText(AppKeys.noProfileTitle),
        message: context.getText(AppKeys.noProfileMessage),
        buttonLabel: context.getText(AppKeys.addProfile),
        onTap: widget.onAddProfile,
        scale: scale,
      );
    }

    final chapterError = _chapterLoadError?.trim();
    if (chapterError != null && chapterError.isNotEmpty) {
      return _ReviewProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.chapterLoadErrorTitle),
        message: chapterError,
        buttonLabel: context.getText(AppKeys.retry),
        onTap: _loadChaptersForActiveProfile,
        scale: scale,
      );
    }

    if (chapters.isEmpty) {
      return _ReviewProfileStatePanel(
        icon: Icons.menu_book_outlined,
        title: context.getText(AppKeys.noChapterTitle),
        message: context.getText(AppKeys.noChapterMessage),
        buttonLabel: context.getText(AppKeys.retry),
        onTap: _loadChaptersForActiveProfile,
        scale: scale,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: '📝',
                value: '$totalLessons',
                label: context.getText(AppKeys.exercises),
                scale: scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: _StatTile(
                icon: '🔥',
                value: '365',
                label: context.getText(AppKeys.days),
                scale: scale,
              ),
            ),
          ],
        ),
        SizedBox(height: 26 * scale),
        for (final chapter in chapters) ...[
          _ChapterCard(
            chapter: chapter,
            completedLessons: completedLessons,
            totalLessons: totalLessons,
            selected: _selectedChapterNumbers.contains(chapter.number),
            selectionMode: _selectedChapterNumbers.isNotEmpty,
            onToggleSelected: () => _toggleChapter(chapter),
            onStartTest: () => _startSingleTest(chapter),
            scale: scale,
          ),
          SizedBox(height: 18 * scale),
        ],
      ],
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  const _ReviewHeader({required this.scale, required this.topInset});

  final double scale;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topInset + 60 * scale,
      padding: EdgeInsets.only(top: topInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        context.getText(AppKeys.reviewTitle),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.andika(
          color: const Color(0xFF339395),
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ReviewProfileStatePanel extends StatelessWidget {
  const _ReviewProfileStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onTap,
    required this.scale,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 78 * scale),
      padding: EdgeInsets.symmetric(
        horizontal: 28 * scale,
        vertical: 54 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(
          color: const Color(0xFFE3DDDF).withValues(alpha: 0.70),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E7775).withValues(alpha: 0.06),
            blurRadius: 22 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00776F), size: 58 * scale),
          SizedBox(height: 40 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF253228),
              fontSize: 28 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF515F54),
              fontSize: 17 * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 34 * scale),
          Material(
            color: _headerNavy,
            shadowColor: _headerNavy.withValues(alpha: 0.20),
            elevation: 4,
            borderRadius: BorderRadius.circular(22 * scale),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(22 * scale),
              child: Container(
                constraints: BoxConstraints(minWidth: 154 * scale),
                padding: EdgeInsets.symmetric(
                  horizontal: 28 * scale,
                  vertical: 15 * scale,
                ),
                child: Text(
                  buttonLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.scale,
  });

  final String icon;
  final String value;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 14 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46 * scale,
            height: 46 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2FF),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: TextStyle(fontSize: 26 * scale, height: 1),
            ),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewInk,
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _reviewMuted,
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                  _Badge(
                    icon: chapter.icon,
                    scale: scale,
                  ),
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
                              fontSize: 16 * scale,
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
                              fontSize: 22 * scale,
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
                  _SelectCircle(
                    selected: selected,
                    scale: scale,
                  ),
                ],
              ),
              if (showButton) ...[
                SizedBox(height: 20 * scale),
                _TestButton(
                  enabled: true,
                  scale: scale,
                  onTap: onStartTest,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.scale,
  });

  final String icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58 * scale,
      height: 58 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        icon,
        style: TextStyle(
          fontSize: 28 * scale,
          height: 1,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _SelectCircle extends StatelessWidget {
  const _SelectCircle({
    required this.selected,
    required this.scale,
  });

  final bool selected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34 * scale,
      height: 34 * scale,
      decoration: BoxDecoration(
        color: selected ? _checkPink : Colors.transparent,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(
                color: _uncheckedCircle,
                width: 2.4 * scale,
              ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, color: Colors.white, size: 25 * scale)
          : null,
    );
  }
}

class _TestButton extends StatelessWidget {
  const _TestButton({
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16 * scale),
          child: _DepthButtonSurface(
            radius: 16 * scale,
            depth: 8 * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 17 * scale,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFF3B0031),
                  size: 25 * scale,
                ),
                SizedBox(width: 14 * scale),
                Flexible(
                  child: Text(
                    context.getText(AppKeys.test),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF3B0031),
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartSelectedButton extends StatelessWidget {
  const _StartSelectedButton({
    required this.count,
    required this.scale,
    required this.onTap,
  });

  final int count;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: _DepthButtonSurface(
          radius: 18 * scale,
          depth: 8 * scale,
          padding: EdgeInsets.symmetric(
            horizontal: 18 * scale,
            vertical: 18 * scale,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded,
                  color: const Color(0xFF3B0031), size: 24 * scale),
              SizedBox(width: 10 * scale),
              Flexible(
                child: Text(
                  context.formatText(AppKeys.startTest, {'count': count}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF3B0031),
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearSelectionButton extends StatelessWidget {
  const _ClearSelectionButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(18 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 106 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 22 * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close_rounded,
                  color: _selectPink,
                  size: 23 * scale,
                ),
                SizedBox(width: 7 * scale),
                Text(
                  context.getText(AppKeys.clearSelection),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _selectPink,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DepthButtonSurface extends StatelessWidget {
  const _DepthButtonSurface({
    required this.radius,
    required this.depth,
    required this.padding,
    required this.child,
  });

  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _testShadow),
        child: Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _testYellow,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: padding,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterCardColors {
  const _ChapterCardColors({
    required this.background,
    required this.shadow,
  });

  final Color background;
  final Color shadow;
}

_ChapterCardColors _chapterColors(int number) {
  return switch (number) {
    1 => const _ChapterCardColors(
        background: Color(0xFFBFEFF4),
        shadow: Color(0xFF62C7D2),
      ),
    2 => const _ChapterCardColors(
        background: Color(0xFFD9F1DD),
        shadow: Color(0xFF8DD39C),
      ),
    3 => const _ChapterCardColors(
        background: Color(0xFFEADDF7),
        shadow: Color(0xFFBDA1DA),
      ),
    _ => const _ChapterCardColors(
        background: Color(0xFFFFF0B9),
        shadow: Color(0xFFE8C85A),
      ),
  };
}

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

int? _profileProgramId(StudentProfile profile) =>
    profile.program?.programId ?? profile.program?.id ?? profile.programId;

int? _profileGradeId(StudentProfile profile) =>
    profile.grade?.gradeId ?? profile.grade?.id ?? profile.gradeId;

int? _profileSemesterId(StudentProfile profile) =>
    profile.semester?.semesterId ?? profile.semester?.id ?? profile.semesterId;

List<PracticeChapter> _practiceChaptersFromApi(List<ChapterModel> chapters) {
  final sorted = [...chapters]..sort((a, b) {
      final left = a.displayOrder ?? 0;
      final right = b.displayOrder ?? 0;
      if (left != right) {
        return left.compareTo(right);
      }
      return _chapterLabel(a).compareTo(_chapterLabel(b));
    });

  return List.generate(sorted.length, (index) {
    final chapter = sorted[index];
    final number = index + 1;
    final lessonCount = chapter.lessonCount ??
        _fallbackPracticeChapter(number)?.lessonCount ??
        0;

    return PracticeChapter(
      id: _practiceChapterId(chapter),
      number: number,
      title: _chapterDescription(chapter) ?? _chapterLabel(chapter),
      description: _chapterLabel(chapter),
      lessons: const <PracticeLesson>[],
      lessonCountOverride: lessonCount,
      completedLessons: _fakeCompletedLessons(number, lessonCount),
      icon: _chapterIcon(number),
    );
  });
}

PracticeChapter? _fallbackPracticeChapter(int number) {
  for (final chapter in gradeOnePracticeChapters) {
    if (chapter.number == number) {
      return chapter;
    }
  }
  return null;
}

String _chapterLabel(ChapterModel chapter) {
  return _nonEmpty(chapter.label) ?? 'Chapter';
}

String? _chapterDescription(ChapterModel chapter) {
  return _nonEmpty(chapter.description);
}

String _practiceChapterId(ChapterModel chapter) {
  final id = chapter.chapterId ?? chapter.id;
  return id == null ? 'chapter-${chapter.displayOrder ?? 0}' : '$id';
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _chapterIcon(int number) {
  return switch (number) {
    2 => '🎯',
    4 => '🔥',
    _ => '🏆',
  };
}

int _fakeCompletedLessons(int chapterNumber, int lessonCount) {
  if (lessonCount <= 0) {
    return 0;
  }
  return switch (chapterNumber) {
    1 => lessonCount,
    2 => (lessonCount * 0.38).round().clamp(1, lessonCount),
    _ => 0,
  };
}
