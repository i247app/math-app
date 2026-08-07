import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/games/math_squadron/math_squadron_data.dart';
import 'package:numi/features/games/presentation/math_squadron_stage_screen.dart';
import 'package:numi/features/games/presentation/numi_farm_stage_screen.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/practice/practice_catalog.dart';
import 'package:numi/features/practice/presentation/practice_chapter_screen.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';

const _gamesTeal = Color(0xFF006762);
const _gamesOrange = Color(0xFFFF7B54);
const _gamesCream = Color(0xFFFFF6DA);

enum _GamesStep { grade, game, map }

class GamesTab extends StatefulWidget {
  const GamesTab({
    super.key,
    required this.userId,
    required this.initialGrades,
    required this.gradeService,
    required this.bottomPadding,
    this.initialGradeId,
    this.initialGradeLabel,
  });

  final int? userId;
  final List<GradeModel> initialGrades;
  final GradeService gradeService;
  final double bottomPadding;
  final int? initialGradeId;
  final String? initialGradeLabel;

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  List<GradeModel> _grades = const <GradeModel>[];
  GradeModel? _selectedGrade;
  _GamePreview? _selectedGame;
  bool _isLoadingGrades = false;
  String? _gradeError;
  int _farmCompletedStages = 0;
  int _squadronCompletedStages = 0;

  _GamesStep get _step {
    if (_selectedGrade == null) {
      return _GamesStep.grade;
    }
    if (_selectedGame == null) {
      return _GamesStep.game;
    }
    return _GamesStep.map;
  }

  @override
  void initState() {
    super.initState();
    _grades = widget.initialGrades;
    _selectedGrade = _preferredGrade(_grades);
    if (_grades.isEmpty) {
      _loadGrades();
    }
  }

  @override
  void didUpdateWidget(covariant GamesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _grades = widget.initialGrades;
      _selectedGrade = _preferredGrade(_grades);
      _selectedGame = null;
      _farmCompletedStages = 0;
      _squadronCompletedStages = 0;
      if (_grades.isEmpty) {
        _loadGrades();
      }
      return;
    }

    if (_grades.isEmpty && widget.initialGrades.isNotEmpty) {
      setState(() {
        _grades = widget.initialGrades;
        _selectedGrade ??= _preferredGrade(_grades);
        _isLoadingGrades = false;
        _gradeError = null;
      });
    }
  }

  GradeModel? _preferredGrade(List<GradeModel> grades) {
    if (grades.isEmpty) {
      return null;
    }

    for (final grade in grades) {
      final gradeId = grade.gradeId ?? grade.id;
      if (widget.initialGradeId != null && gradeId == widget.initialGradeId) {
        return grade;
      }
      if (widget.initialGradeLabel?.trim().isNotEmpty == true &&
          grade.label?.trim() == widget.initialGradeLabel?.trim()) {
        return grade;
      }
    }
    return null;
  }

  Future<void> _loadGrades() async {
    final userId = widget.userId;
    if (userId == null || userId <= 0 || _isLoadingGrades) {
      setState(
        () => _gradeError = context.readText(AppKeys.noAccountForGrades),
      );
      return;
    }

    setState(() {
      _isLoadingGrades = true;
      _gradeError = null;
    });

    try {
      final grades = await widget.gradeService.listGrades(userId: userId);
      if (!mounted) {
        return;
      }
      setState(() {
        _grades = grades;
        _selectedGrade ??= _preferredGrade(grades);
        _isLoadingGrades = false;
      });
    } on GradeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gradeError = error.message;
        _isLoadingGrades = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gradeError = context.readText(AppKeys.gradeLoadFailed);
        _isLoadingGrades = false;
      });
    }
  }

  void _selectGrade(GradeModel grade) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedGrade = grade;
      _selectedGame = null;
      _farmCompletedStages = 0;
      _squadronCompletedStages = 0;
    });
  }

  void _selectGame(_GamePreview game) {
    HapticFeedback.lightImpact();
    setState(() => _selectedGame = game);
  }

  void _changeGrade() {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedGrade = null;
      _selectedGame = null;
    });
  }

  void _backToGames() {
    HapticFeedback.selectionClick();
    setState(() => _selectedGame = null);
  }

  Future<void> _openLevel(PracticeLesson lesson) async {
    HapticFeedback.lightImpact();
    if (_selectedGame?.id == 'journey-1' &&
        lesson.number >= 1 &&
        lesson.number <= 5) {
      final stageScreen = lesson.number <= 2
          ? NumiFarmHarvestStageScreen(stage: lesson.number)
          : NumiFarmChoiceStageScreen(stage: lesson.number);
      final completed = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => stageScreen));
      if (completed == true &&
          mounted &&
          _farmCompletedStages < lesson.number) {
        setState(() => _farmCompletedStages = lesson.number);
      }
      return;
    }

    if (_selectedGame?.id == 'math-squadron' &&
        lesson.number >= 1 &&
        lesson.number <= mathSquadronLevels.length) {
      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => MathSquadronStageScreen(level: lesson.number),
        ),
      );
      if (completed == true &&
          mounted &&
          _squadronCompletedStages < lesson.number) {
        setState(() => _squadronCompletedStages = lesson.number);
      }
      return;
    }

    if (!mounted) {
      return;
    }
    context.showInfoDialog(
      context.formatText(AppKeys.gamesLevelComingSoon, {
        'level': lesson.number,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.035, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: switch (_step) {
        _GamesStep.grade => _GamesGradeSelection(
          key: const ValueKey('games-grade-selection'),
          grades: _grades,
          isLoading: _isLoadingGrades,
          errorMessage: _gradeError,
          onRetry: _loadGrades,
          onSelected: _selectGrade,
        ),
        _GamesStep.game => _GamesCatalog(
          key: const ValueKey('games-catalog'),
          selectedGrade: _selectedGrade!,
          bottomPadding: widget.bottomPadding,
          onChangeGrade: _changeGrade,
          onSelected: _selectGame,
        ),
        _GamesStep.map => _GamesMap(
          key: ValueKey(
            'games-map-${_selectedGame!.id}-$_farmCompletedStages-$_squadronCompletedStages',
          ),
          game: _selectedGame!,
          grade: _selectedGrade!,
          completedStages: switch (_selectedGame!.id) {
            'journey-1' => _farmCompletedStages,
            'math-squadron' => _squadronCompletedStages,
            _ => 0,
          },
          bottomPadding: widget.bottomPadding,
          onBack: _backToGames,
          onLevelTap: _openLevel,
        ),
      },
    );
  }
}

class _GamesGradeSelection extends StatelessWidget {
  const _GamesGradeSelection({
    super.key,
    required this.grades,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onSelected,
  });

  final List<GradeModel> grades;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<GradeModel> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final visibleGrades =
        grades.where((grade) => grade.label?.trim().isNotEmpty == true).toList()
          ..sort(
            (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
          );
    final kindergartenGrade = visibleGrades
        .where((grade) => _isKindergartenLabel(grade.label))
        .firstOrNull;
    final pathGrades = <GradeModel>[
      kindergartenGrade ?? _kindergartenGrade,
      ...visibleGrades.where((grade) => !_isKindergartenLabel(grade.label)),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: ColoredBox(
        color: colors.pageBackground,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const sourceSize = Size(593, 1280);
            final fittedSizes = applyBoxFit(
              BoxFit.cover,
              sourceSize,
              constraints.biggest,
            );
            final imageScale =
                fittedSizes.destination.width / fittedSizes.source.width;
            final renderedImageWidth = sourceSize.width * imageScale;
            final imageOffsetX =
                (constraints.maxWidth - renderedImageWidth) / 2;

            return ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/game-grade-selection-background.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  if (isLoading)
                    Positioned(
                      top: 350 * imageScale,
                      left: 0,
                      right: 0,
                      child: const Center(child: _GradePathLoading()),
                    )
                  else if (errorMessage != null)
                    Positioned(
                      top: 240 * imageScale,
                      left: 24,
                      right: 24,
                      child: AppStaggeredEntrance(
                        order: 0,
                        child: _GamesMessageCard(
                          icon: Icons.cloud_off_rounded,
                          message: errorMessage!,
                          actionLabel: context.getText(AppKeys.retryUpper),
                          onAction: onRetry,
                        ),
                      ),
                    )
                  else if (visibleGrades.isEmpty)
                    Positioned(
                      top: 240 * imageScale,
                      left: 24,
                      right: 24,
                      child: AppStaggeredEntrance(
                        order: 0,
                        child: _GamesMessageCard(
                          icon: Icons.school_outlined,
                          message: context.getText(AppKeys.noGrades),
                          actionLabel: context.getText(AppKeys.retryUpper),
                          onAction: onRetry,
                        ),
                      ),
                    )
                  else
                    for (
                      var index = 0;
                      index <
                          math.min(pathGrades.length, _gradePathStops.length);
                      index++
                    )
                      _GradePathPositionedButton(
                        stop: _gradePathStops[index],
                        scale: imageScale,
                        offsetX: imageOffsetX,
                        order: index,
                        child: _GamesGradeCard(
                          grade: pathGrades[index],
                          index: math.max(0, index - 1),
                          onTap: () => onSelected(pathGrades[index]),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const _kindergartenGrade = GradeModel(
  label: 'Mẫu giáo',
  description: 'Mẫu giáo',
  displayOrder: 0,
);

bool _isKindergartenLabel(String? label) {
  final normalized = label?.trim().toLowerCase() ?? '';
  return normalized.contains('mẫu giáo') || normalized.contains('kindergarten');
}

const _gradePathStops = <_GradePathStop>[
  _GradePathStop(x: 194, y: 1056, width: 126),
  _GradePathStop(x: 389, y: 874, width: 118),
  _GradePathStop(x: 242, y: 752, width: 110),
  _GradePathStop(x: 402, y: 657, width: 102),
  _GradePathStop(x: 289, y: 562, width: 94),
  _GradePathStop(x: 411, y: 491, width: 84),
];

class _GradePathStop {
  const _GradePathStop({required this.x, required this.y, required this.width});

  final double x;
  final double y;
  final double width;
}

class _GradePathPositionedButton extends StatelessWidget {
  const _GradePathPositionedButton({
    required this.stop,
    required this.scale,
    required this.offsetX,
    required this.order,
    required this.child,
  });

  final _GradePathStop stop;
  final double scale;
  final double offsetX;
  final int order;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = stop.width * scale;
    final height = width / 0.72;
    return Positioned(
      left: offsetX + (stop.x * scale) - (width / 2),
      top: (stop.y * scale) - (height * 0.868),
      width: width,
      height: height,
      child: AppStaggeredEntrance(order: order, child: child),
    );
  }
}

class _GradePathLoading extends StatelessWidget {
  const _GradePathLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D155A54),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircularProgressIndicator(
        color: colors.brandStrong,
        strokeWidth: 3,
      ),
    );
  }
}

class _GamesCatalog extends StatelessWidget {
  const _GamesCatalog({
    super.key,
    required this.selectedGrade,
    required this.bottomPadding,
    required this.onChangeGrade,
    required this.onSelected,
  });

  final GradeModel selectedGrade;
  final double bottomPadding;
  final VoidCallback onChangeGrade;
  final ValueChanged<_GamePreview> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final games = _gamePreviews(context, selectedGrade);
    return ColoredBox(
      color: colors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(
                child: AppStaggeredEntrance(
                  order: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _GamesEyebrow(
                              label: context.getText(AppKeys.navGames),
                            ),
                          ),
                          _GradeChip(
                            label: selectedGrade.label?.trim() ?? '',
                            onTap: onChangeGrade,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        context.getText(AppKeys.gamesChooseTitle),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        context.getText(AppKeys.gamesChooseSubtitle),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: FontSize.normal,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
              sliver: SliverList.separated(
                itemCount: games.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) => AppStaggeredEntrance(
                  order: index + 1,
                  child: _GamePreviewCard(
                    game: games[index],
                    onTap: () => onSelected(games[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesMap extends StatelessWidget {
  const _GamesMap({
    super.key,
    required this.game,
    required this.grade,
    required this.completedStages,
    required this.bottomPadding,
    required this.onBack,
    required this.onLevelTap,
  });

  final _GamePreview game;
  final GradeModel grade;
  final int completedStages;
  final double bottomPadding;
  final VoidCallback onBack;
  final ValueChanged<PracticeLesson> onLevelTap;

  @override
  Widget build(BuildContext context) {
    final lessons = List.generate(
      game.levelCount,
      (index) => PracticeLesson(
        number: index + 1,
        title: game.levelTitleKeys == null
            ? context.formatText(AppKeys.gamesLevelLabel, {'level': index + 1})
            : context.getText(game.levelTitleKeys![index]),
      ),
    );
    final chapter = PracticeChapter(
      id: 'game-${game.id}',
      number: 1,
      title: game.title,
      description: grade.label,
      lessons: lessons,
      completedLessons: completedStages,
      icon: game.id == 'math-squadron' ? '🚀' : '🎮',
    );

    return PracticeChapterScreen(
      chapter: chapter,
      embedded: true,
      bottomPadding: bottomPadding,
      onLessonTap: onLevelTap,
      onEmbeddedBack: onBack,
      showEmbeddedChapterLabel: false,
    );
  }
}

class _GamesEyebrow extends StatelessWidget {
  const _GamesEyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: colors.brandStrong,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _GamesGradeCard extends StatelessWidget {
  const _GamesGradeCard({
    required this.grade,
    required this.index,
    required this.onTap,
  });

  final GradeModel grade;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const kindergartenPalette = _GradePlaquePalette(
      top: Color(0xFFFFDB3D),
      bottom: Color(0xFFFFA51F),
      edge: Color(0xFFE06B08),
      flag: Color(0xFFFFB622),
      ornament: Color(0xFFFFF6DE),
    );
    const palettes = <_GradePlaquePalette>[
      _GradePlaquePalette(
        top: Color(0xFFFFBE30),
        bottom: Color(0xFFFF7A12),
        edge: Color(0xFFD94B0A),
        flag: Color(0xFFFF7414),
        ornament: Color(0xFFFFD523),
      ),
      _GradePlaquePalette(
        top: Color(0xFFFF5C91),
        bottom: Color(0xFFE91D68),
        edge: Color(0xFFB10B4A),
        flag: Color(0xFFF53B6C),
        ornament: Color(0xFFFF648D),
      ),
      _GradePlaquePalette(
        top: Color(0xFFAC5AF2),
        bottom: Color(0xFF7026D5),
        edge: Color(0xFF4E17A8),
        flag: Color(0xFF8D36E8),
        ornament: Color(0xFFB767F5),
      ),
      _GradePlaquePalette(
        top: Color(0xFF43BDF4),
        bottom: Color(0xFF1478DF),
        edge: Color(0xFF0754B2),
        flag: Color(0xFF238DEA),
        ornament: Color(0xFF42C8FF),
      ),
      _GradePlaquePalette(
        top: Color(0xFF9DDF2D),
        bottom: Color(0xFF4EBA1E),
        edge: Color(0xFF288812),
        flag: Color(0xFF58C723),
        ornament: Color(0xFFFFC928),
      ),
    ];
    final label = grade.label?.trim() ?? '';
    final isKindergarten = _isKindergartenLabel(label);
    final display = _GradeDisplay.fromGrade(grade);
    final palette = isKindergarten
        ? kindergartenPalette
        : palettes[index % palettes.length];

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _GradePlaqueArtwork(
              display: display,
              palette: palette,
              ornament: _gradeOrnament(index),
              isKindergarten: isKindergarten,
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(36),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(36),
                  splashColor: Colors.white24,
                  highlightColor: Colors.white10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradePlaqueArtwork extends StatelessWidget {
  const _GradePlaqueArtwork({
    required this.display,
    required this.palette,
    required this.ornament,
    required this.isKindergarten,
  });

  final _GradeDisplay display;
  final _GradePlaquePalette palette;
  final IconData ornament;
  final bool isKindergarten;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final ornamentSize = width * 0.27;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (isKindergarten)
              Positioned(
                top: height * 0.005,
                child: CustomPaint(
                  size: Size.square(width * 0.37),
                  painter: const _KindergartenStarPainter(),
                ),
              )
            else
              Positioned(
                top: 0,
                left: width * 0.43,
                child: CustomPaint(
                  size: Size(width * 0.43, height * 0.26),
                  painter: _GradeFlagPainter(palette),
                ),
              ),
            Positioned(
              top: height * 0.13,
              left: width * 0.06,
              right: width * 0.06,
              bottom: height * 0.08,
              child: CustomPaint(painter: _GradePlaquePainter(palette)),
            ),
            Positioned(
              top: height * 0.29,
              left: width * 0.16,
              right: width * 0.16,
              bottom: height * 0.18,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OutlinedGradeText(
                    display.caption,
                    fontSize: width * (display.number == null ? 0.225 : 0.155),
                    outlineColor: palette.edge,
                    maxLines: display.number == null ? 2 : 1,
                  ),
                  if (display.number != null) ...[
                    SizedBox(height: height * 0.01),
                    _OutlinedGradeText(
                      display.number!,
                      fontSize: width * 0.43,
                      outlineColor: palette.edge,
                    ),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: height * 0.07,
              child: _GradeLeaves(size: width * 0.37),
            ),
            Positioned(
              right: 0,
              bottom: height * 0.07,
              child: _GradeLeaves(size: width * 0.37, mirrored: true),
            ),
            Positioned(
              bottom: height * 0.035,
              child: isKindergarten
                  ? CustomPaint(
                      size: Size.square(ornamentSize),
                      painter: const _KindergartenFlowerPainter(),
                    )
                  : Container(
                      width: ornamentSize,
                      height: ornamentSize,
                      decoration: BoxDecoration(
                        color: palette.ornament,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white70,
                          width: math.max(1, width * 0.013),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x520B5B1C),
                            blurRadius: 7,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        ornament,
                        color: palette.edge,
                        size: ornamentSize * 0.65,
                      ),
                    ),
            ),
            Positioned(
              top: height * 0.16,
              right: width * 0.03,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: const Color(0xFFFFE166),
                size: width * 0.12,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KindergartenStarPainter extends CustomPainter {
  const _KindergartenStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final star = Path();
    for (var point = 0; point < 10; point++) {
      final radius = point.isEven ? size.width * 0.48 : size.width * 0.25;
      final angle = -math.pi / 2 + point * math.pi / 5;
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (point == 0) {
        star.moveTo(offset.dx, offset.dy);
      } else {
        star.lineTo(offset.dx, offset.dy);
      }
    }
    star.close();

    canvas.drawShadow(
      star,
      const Color(0x660D4831),
      math.max(1.5, size.width * 0.08),
      true,
    );
    canvas.drawPath(
      star,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF163), Color(0xFFFFBE18)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      star,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, size.width * 0.06)
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.9),
    );

    final facePaint = Paint()
      ..color = const Color(0xFF7A4900)
      ..strokeCap = StrokeCap.round;
    final eyeRadius = size.width * 0.035;
    canvas.drawCircle(
      Offset(center.dx - size.width * 0.11, center.dy - size.height * 0.015),
      eyeRadius,
      facePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.11, center.dy - size.height * 0.015),
      eyeRadius,
      facePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.015),
        width: size.width * 0.27,
        height: size.height * 0.2,
      ),
      0.18,
      math.pi - 0.36,
      false,
      facePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, size.width * 0.045),
    );
  }

  @override
  bool shouldRepaint(_KindergartenStarPainter oldDelegate) => false;
}

class _KindergartenFlowerPainter extends CustomPainter {
  const _KindergartenFlowerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final petalRadius = size.width * 0.17;
    final petalDistance = size.width * 0.23;
    final flower = Path();
    for (var petal = 0; petal < 6; petal++) {
      final angle = -math.pi / 2 + petal * math.pi / 3;
      flower.addOval(
        Rect.fromCircle(
          center: Offset(
            center.dx + math.cos(angle) * petalDistance,
            center.dy + math.sin(angle) * petalDistance,
          ),
          radius: petalRadius,
        ),
      );
    }
    canvas.drawShadow(
      flower,
      const Color(0x590D4831),
      math.max(1, size.width * 0.08),
      true,
    );
    canvas.drawPath(flower, Paint()..color = const Color(0xFFFFFBF4));
    canvas.drawPath(
      flower,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, size.width * 0.03)
        ..color = const Color(0xFFE7DED0),
    );
    canvas.drawCircle(
      center,
      size.width * 0.16,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFFFFEA55), Color(0xFFFFA818)],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * 0.16),
            ),
    );
  }

  @override
  bool shouldRepaint(_KindergartenFlowerPainter oldDelegate) => false;
}

class _OutlinedGradeText extends StatelessWidget {
  const _OutlinedGradeText(
    this.text, {
    required this.fontSize,
    required this.outlineColor,
    this.maxLines = 1,
  });

  final String text;
  final double fontSize;
  final Color outlineColor;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.95,
      letterSpacing: -0.8,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            text.toUpperCase(),
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = math.max(1.3, fontSize * 0.12)
                ..strokeJoin = StrokeJoin.round
                ..color = outlineColor,
            ),
          ),
          Text(
            text.toUpperCase(),
            maxLines: maxLines,
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Color(0x4D411300),
                  offset: Offset(0, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeLeaves extends StatelessWidget {
  const _GradeLeaves({required this.size, this.mirrored = false});

  final double size;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final leaves = SizedBox(
      width: size,
      height: size * 0.78,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.58,
              child: Icon(
                Icons.eco_rounded,
                color: const Color(0xFF257F19),
                size: size * 0.67,
              ),
            ),
          ),
          Positioned(
            left: size * 0.33,
            bottom: size * 0.07,
            child: Transform.rotate(
              angle: -0.28,
              child: Icon(
                Icons.eco_rounded,
                color: const Color(0xFF65B91F),
                size: size * 0.62,
              ),
            ),
          ),
          Positioned(
            left: size * 0.62,
            bottom: size * 0.13,
            child: Transform.rotate(
              angle: -0.05,
              child: Icon(
                Icons.eco_rounded,
                color: const Color(0xFF8AD42A),
                size: size * 0.51,
              ),
            ),
          ),
        ],
      ),
    );

    return Transform.flip(flipX: mirrored, child: leaves);
  }
}

class _GradePlaquePainter extends CustomPainter {
  const _GradePlaquePainter(this.palette);

  final _GradePlaquePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final plaque = _plaquePath(rect);
    canvas.drawShadow(
      plaque,
      const Color(0x730D4831),
      math.max(2, size.width * 0.06),
      true,
    );

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [palette.top, palette.bottom],
      ).createShader(rect);
    canvas.drawPath(plaque, fill);
    canvas.drawPath(
      plaque,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, size.width * 0.027)
        ..color = palette.edge,
    );
    canvas.drawPath(
      plaque,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, size.width * 0.013)
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    final stitchedPath = _plaquePath(rect.deflate(size.width * 0.053));
    final stitchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.65, size.width * 0.011)
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.62);
    final dash = math.max(2.5, size.width * 0.04);
    final stride = math.max(4.5, size.width * 0.073);
    for (final metric in stitchedPath.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += stride) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            math.min(distance + dash, metric.length),
          ),
          stitchPaint,
        );
      }
    }
  }

  Path _plaquePath(Rect rect) {
    final width = rect.width;
    final height = rect.height;
    final shoulder = rect.top + height * 0.28;
    final radius = math.min(22.0, width * 0.14);
    return Path()
      ..moveTo(rect.left, shoulder)
      ..cubicTo(
        rect.left,
        rect.top + height * 0.08,
        rect.left + width * 0.2,
        rect.top,
        rect.center.dx,
        rect.top,
      )
      ..cubicTo(
        rect.right - width * 0.2,
        rect.top,
        rect.right,
        rect.top + height * 0.08,
        rect.right,
        shoulder,
      )
      ..lineTo(rect.right, rect.bottom - radius)
      ..quadraticBezierTo(
        rect.right,
        rect.bottom,
        rect.right - radius,
        rect.bottom,
      )
      ..lineTo(rect.left + radius, rect.bottom)
      ..quadraticBezierTo(
        rect.left,
        rect.bottom,
        rect.left,
        rect.bottom - radius,
      )
      ..close();
  }

  @override
  bool shouldRepaint(_GradePlaquePainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _GradeFlagPainter extends CustomPainter {
  const _GradeFlagPainter(this.palette);

  final _GradePlaquePalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final poleX = size.width * 0.14;
    final poleWidth = math.max(1.2, size.width * 0.08);
    final capRadius = math.max(1.5, size.width * 0.08);
    canvas.drawLine(
      Offset(poleX, capRadius),
      Offset(poleX, size.height),
      Paint()
        ..color = palette.edge
        ..strokeWidth = poleWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(poleX, capRadius),
      capRadius,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0xFFFFE1A0), Color(0xFF854014)],
            ).createShader(
              Rect.fromCircle(
                center: Offset(poleX, capRadius),
                radius: capRadius,
              ),
            ),
    );

    final flag = Path()
      ..moveTo(poleX + (poleWidth * 0.5), size.height * 0.17)
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.04,
        size.width * 0.62,
        size.height * 0.17,
        size.width * 0.94,
        size.height * 0.12,
      )
      ..cubicTo(
        size.width * 0.77,
        size.height * 0.45,
        size.width * 0.53,
        size.height * 0.32,
        poleX + 3,
        size.height * 0.45,
      )
      ..close();
    canvas.drawShadow(
      flag,
      const Color(0x55000000),
      math.max(1, size.width * 0.06),
      true,
    );
    canvas.drawPath(
      flag,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.flag.withValues(alpha: 0.72), palette.flag],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      flag,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.65, size.width * 0.025)
        ..color = Colors.white70,
    );
  }

  @override
  bool shouldRepaint(_GradeFlagPainter oldDelegate) =>
      oldDelegate.palette != palette;
}

class _GradePlaquePalette {
  const _GradePlaquePalette({
    required this.top,
    required this.bottom,
    required this.edge,
    required this.flag,
    required this.ornament,
  });

  final Color top;
  final Color bottom;
  final Color edge;
  final Color flag;
  final Color ornament;
}

class _GradeDisplay {
  const _GradeDisplay({required this.caption, this.number});

  factory _GradeDisplay.fromGrade(GradeModel grade) {
    final label = grade.label?.trim() ?? '';
    final numberMatch = RegExp(r'\d+').firstMatch(label);
    if (numberMatch == null) {
      return _GradeDisplay(caption: label.replaceFirst(RegExp(r'\s+'), '\n'));
    }

    final caption = label
        .replaceRange(numberMatch.start, numberMatch.end, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return _GradeDisplay(
      caption: caption.isEmpty ? label : caption,
      number: numberMatch.group(0),
    );
  }

  final String caption;
  final String? number;
}

IconData _gradeOrnament(int index) => switch (index % 5) {
  0 => Icons.star_rounded,
  1 => Icons.local_florist_rounded,
  2 => Icons.auto_awesome_rounded,
  3 => Icons.diamond_rounded,
  _ => Icons.workspace_premium_rounded,
};

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Material(
      color: colors.elevatedSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, color: colors.brandStrong, size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colors.brandStrong,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamePreviewCard extends StatelessWidget {
  const _GamePreviewCard({required this.game, required this.onTap});

  final _GamePreview game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final background = Theme.of(context).brightness == Brightness.dark
        ? colors.elevatedSurface
        : game.background;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          constraints: const BoxConstraints(minHeight: 158),
          padding: const EdgeInsets.fromLTRB(20, 20, 14, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: game.accent.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.74),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.getText(AppKeys.gamesPrototype),
                        style: TextStyle(
                          color: game.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.formatText(AppKeys.gamesLevelCount, {
                        'count': game.levelCount,
                      }),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 104,
                height: 112,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: game.id == 'math-squadron'
                      ? const _MathSquadronPreviewArtwork()
                      : Image.asset(game.assetPath, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamesMessageCard extends StatelessWidget {
  const _GamesMessageCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.infoSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.info, size: 34),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _GamePreview {
  const _GamePreview({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.background,
    required this.accent,
    this.levelCount = 5,
    this.levelTitleKeys,
  });

  final String id;
  final String title;
  final String assetPath;
  final Color background;
  final Color accent;
  final int levelCount;
  final List<String>? levelTitleKeys;
}

List<_GamePreview> _gamePreviews(
  BuildContext context,
  GradeModel selectedGrade,
) {
  final gradeNumber = _selectedGradeNumber(selectedGrade);
  if (gradeNumber == 3) {
    return [
      _GamePreview(
        id: 'math-squadron',
        title: context.getText(AppKeys.gamesSquadronTitle),
        assetPath: '',
        background: const Color(0xFFDDEBFF),
        accent: const Color(0xFF335BC5),
        levelCount: mathSquadronLevels.length,
        levelTitleKeys: mathSquadronLevels
            .map((level) => level.titleKey)
            .toList(growable: false),
      ),
      _GamePreview(
        id: 'journey-2',
        title: context.getText(AppKeys.gamesJourneyTwo),
        assetPath: 'assets/images/parent-home-race.png',
        background: _gamesCream,
        accent: const Color(0xFFA86700),
      ),
      _GamePreview(
        id: 'journey-3',
        title: context.getText(AppKeys.gamesJourneyThree),
        assetPath: 'assets/images/parent-home-shop.png',
        background: const Color(0xFFFFE5DD),
        accent: _gamesOrange,
      ),
    ];
  }
  return [
    _GamePreview(
      id: 'journey-1',
      title: context.getText(AppKeys.gamesJourneyOne),
      assetPath: 'assets/images/game-numi-farm-banner.png',
      background: const Color(0xFFDDF3EE),
      accent: _gamesTeal,
    ),
    _GamePreview(
      id: 'journey-2',
      title: context.getText(AppKeys.gamesJourneyTwo),
      assetPath: 'assets/images/parent-home-race.png',
      background: _gamesCream,
      accent: const Color(0xFFA86700),
    ),
    _GamePreview(
      id: 'journey-3',
      title: context.getText(AppKeys.gamesJourneyThree),
      assetPath: 'assets/images/parent-home-shop.png',
      background: const Color(0xFFFFE5DD),
      accent: _gamesOrange,
    ),
  ];
}

int? _selectedGradeNumber(GradeModel grade) {
  final match = RegExp(r'\d+').firstMatch(grade.label ?? '');
  if (match != null) {
    return int.tryParse(match.group(0)!);
  }
  final order = grade.displayOrder;
  return order != null && order >= 1 && order <= 12 ? order : null;
}

class _MathSquadronPreviewArtwork extends StatelessWidget {
  const _MathSquadronPreviewArtwork();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111C4B), Color(0xFF335BC5)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 10,
            right: 12,
            child: Icon(Icons.star_rounded, color: Color(0xFFFFD95A), size: 15),
          ),
          const Positioned(
            top: 28,
            left: 12,
            child: Icon(Icons.circle, color: Colors.white24, size: 6),
          ),
          Positioned(
            top: 13,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFF625F),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x99FF625F), blurRadius: 14),
                ],
              ),
              child: const Center(
                child: Text(
                  '× 7',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 12,
            child: Icon(
              Icons.flight_rounded,
              color: Color(0xFF61DAFF),
              size: 45,
            ),
          ),
          Positioned(
            bottom: 48,
            child: Container(
              width: 3,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF61DAFF),
                borderRadius: BorderRadius.circular(99),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF61DAFF), blurRadius: 9),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
