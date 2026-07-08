import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/chapter_models.dart';
import 'package:numi_flutter/core/network/profile_models.dart';
import 'package:numi_flutter/core/theme/app_theme_colors.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/profile/active_profile_session.dart';
import 'package:numi_flutter/features/practice/practice_api.dart';
import 'package:numi_flutter/features/practice/practice_catalog.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/practice/cache/practice_chapter_cache.dart';
import 'package:numi_flutter/features/quiz/quiz_api.dart';
import 'package:numi_flutter/features/quiz/presentation/assessment_screen.dart';
import 'package:numi_flutter/features/practice/presentation/practice_chapter_screen.dart';

part 'widgets/practice_tab/practice_header.dart';
part 'widgets/practice_tab/practice_profile_state_panel.dart';
part 'widgets/practice_tab/stat_tile.dart';
part 'widgets/practice_tab/chapter_card.dart';
part 'widgets/practice_tab/badge.dart';
part 'widgets/practice_tab/select_circle.dart';
part 'widgets/practice_tab/test_button.dart';
part 'widgets/practice_tab/start_selected_button.dart';
part 'widgets/practice_tab/clear_selection_button.dart';
part 'widgets/practice_tab/depth_button_surface.dart';
part 'widgets/practice_tab/chapter_card_colors.dart';
part 'widgets/practice_tab/chapter_colors.dart';
part 'widgets/practice_tab/chapter_meta_text.dart';
part 'widgets/practice_tab/profile_program_id.dart';
part 'widgets/practice_tab/profile_grade_id.dart';
part 'widgets/practice_tab/profile_semester_id.dart';
part 'widgets/practice_tab/practice_chapters_from_api.dart';
part 'widgets/practice_tab/fallback_practice_chapter.dart';
part 'widgets/practice_tab/chapter_label.dart';
part 'widgets/practice_tab/chapter_description.dart';
part 'widgets/practice_tab/practice_chapter_id.dart';
part 'widgets/practice_tab/non_empty.dart';
part 'widgets/practice_tab/chapter_icon.dart';
part 'widgets/practice_tab/estimated_completed_lessons.dart';

const _reviewInk = Color(0xFF14213D);
const _reviewMuted = Color(0xFF77859A);
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

class PracticeTab extends StatefulWidget {
  const PracticeTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.isParentMode,
    required this.profileLoadError,
    required this.onRefreshProfiles,
    required this.onAddProfile,
    required this.bottomPadding,
    required this.scale,
    this.activeRefreshTick = 0,
    this.isActive = true,
  });

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final bool isParentMode;
  final String? profileLoadError;
  final Future<void> Function() onRefreshProfiles;
  final VoidCallback onAddProfile;
  final double bottomPadding;
  final double scale;
  final int activeRefreshTick;
  final bool isActive;

  @override
  State<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<PracticeTab> {
  final PracticeService _chapterService = PracticeApi();
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
    if (widget.isActive && !widget.isParentMode) {
      _loadChaptersForActiveProfile();
    }
  }

  @override
  void didUpdateWidget(covariant PracticeTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive && !widget.isParentMode) {
      _loadChaptersForActiveProfile();
      return;
    }
    if (!widget.isActive) {
      return;
    }
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
    } else if (!widget.isParentMode &&
        oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadChaptersForActiveProfile(forceRefresh: true);
    }
  }

  Future<void> _loadChaptersForActiveProfile({
    bool forceRefresh = false,
  }) async {
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

    await _loadChaptersForProfile(
      profile,
      requestId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadChaptersForProfile(
    StudentProfile? profile,
    int requestId, {
    bool forceRefresh = false,
  }) async {
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

    final cachedChapters = PracticeChapterCache.peekChapters(
      programId: programId,
      gradeId: gradeId,
      semesterId: semesterId,
    );
    if (cachedChapters != null) {
      setState(() {
        _chapters = _practiceChaptersFromApi(cachedChapters);
        _chapterLoadError = null;
        _isLoadingChapters = false;
      });
    } else {
      setState(() {
        _isLoadingChapters = true;
        _chapterLoadError = null;
      });
    }

    final shouldRefresh =
        forceRefresh ||
        !PracticeChapterCache.isFresh(
          programId: programId,
          gradeId: gradeId,
          semesterId: semesterId,
        );
    if (!shouldRefresh) {
      return;
    }

    try {
      final chapters = await PracticeChapterCache.loadChapters(
        service: _chapterService,
        programId: programId,
        gradeId: gradeId,
        semesterId: semesterId,
        forceRefresh: forceRefresh || cachedChapters != null,
      );
      if (!mounted || requestId != _loadRequestId) {
        return;
      }

      setState(() {
        _chapters = _practiceChaptersFromApi(chapters);
        _isLoadingChapters = false;
      });
    } on PracticeException catch (error) {
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
    final colors = context.themeColors;
    final scale = widget.scale;
    final topInset = MediaQuery.paddingOf(context).top;

    if (widget.isParentMode) {
      return ColoredBox(
        color: colors.pageBackground,
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
      color: colors.pageBackground,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom:
                  widget.bottomPadding +
                  (hasSelection ? selectedCtaHeight + selectedCtaGap : 0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PracticeTabHeader(scale: scale, topInset: topInset),
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
                    child: PracticeStartSelectedButton(
                      count: _selectedChapterNumbers.length,
                      scale: scale,
                      onTap: _startSelectedTest,
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  PracticeClearSelectionButton(
                    scale: scale,
                    onTap: _clearSelection,
                  ),
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
          profileId: ActiveProfileSession.profileStableId(widget.activeProfile),
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
            color: context.themeColors.brandStrong,
            strokeWidth: 3 * scale,
          ),
        ),
      );
    }

    final error = widget.profileLoadError?.trim();
    if (error != null && error.isNotEmpty) {
      return PracticeProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.profileLoadErrorTitle),
        message: error,
        buttonLabel: context.getText(AppKeys.retry),
        onTap: widget.onRefreshProfiles,
        scale: scale,
      );
    }

    if (widget.activeProfile == null) {
      return PracticeProfileStatePanel(
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
      return PracticeProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.chapterLoadErrorTitle),
        message: chapterError,
        buttonLabel: context.getText(AppKeys.retry),
        onTap: () => _loadChaptersForActiveProfile(forceRefresh: true),
        scale: scale,
      );
    }

    if (chapters.isEmpty) {
      return PracticeProfileStatePanel(
        icon: Icons.menu_book_outlined,
        title: context.getText(AppKeys.noChapterTitle),
        message: context.getText(AppKeys.noChapterMessage),
        buttonLabel: context.getText(AppKeys.retry),
        onTap: () => _loadChaptersForActiveProfile(forceRefresh: true),
        scale: scale,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PracticeStatTile(
                icon: '📝',
                value: '$totalLessons',
                label: context.getText(AppKeys.exercises),
                scale: scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: PracticeStatTile(
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
          PracticeChapterCard(
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
