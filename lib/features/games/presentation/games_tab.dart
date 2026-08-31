import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/games/monster_rescue/monster_rescue_data.dart';
import 'package:numi/features/games/presentation/monster_rescue_stage_screen.dart';
import 'package:numi/features/games/presentation/numi_farm_stage_screen.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/errors/grade_exception.dart';
import 'package:numi/features/practice/practice_catalog.dart';
import 'package:numi/features/practice/presentation/practice_chapter_screen.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';

const _gamesTeal = Color(0xFF006762);

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
  int _rescueCompletedStages = 0;

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
      _rescueCompletedStages = 0;
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
      _rescueCompletedStages = 0;
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

    if (_selectedGame?.id == 'monster-rescue' &&
        lesson.number >= 1 &&
        lesson.number <= monsterRescueLevels.length) {
      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => MonsterRescueStageScreen(level: lesson.number),
        ),
      );
      if (completed == true &&
          mounted &&
          _rescueCompletedStages < lesson.number) {
        setState(() => _rescueCompletedStages = lesson.number);
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
            'games-map-${_selectedGame!.id}-$_farmCompletedStages-$_rescueCompletedStages',
          ),
          game: _selectedGame!,
          grade: _selectedGrade!,
          completedStages: switch (_selectedGame!.id) {
            'journey-1' => _farmCompletedStages,
            'monster-rescue' => _rescueCompletedStages,
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
            const sourceSize = Size(853, 1844);
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
                    'assets/images/game-grade-selection-road-map.png',
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
                          index: index,
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

bool _isKindergartenLabel(String? label) {
  final normalized = label?.trim().toLowerCase() ?? '';
  return normalized.contains('mẫu giáo') || normalized.contains('kindergarten');
}

const _kindergartenGrade = GradeModel(
  label: 'Mẫu giáo',
  description: 'Mẫu giáo',
  displayOrder: 0,
);

const _gradePathStops = <_GradePathStop>[
  // Measured from the six inner cream circles in the 853 x 1844 artwork.
  // Stops run from the bottom pedestal (kindergarten) to grade 5 at the top.
  _GradePathStop(x: 440, y: 1512, width: 151, height: 142),
  _GradePathStop(x: 412, y: 1241, width: 149, height: 137),
  _GradePathStop(x: 450, y: 970, width: 143, height: 131),
  _GradePathStop(x: 423, y: 728, width: 144, height: 127),
  _GradePathStop(x: 454, y: 486, width: 138, height: 120),
  _GradePathStop(x: 416, y: 258, width: 137, height: 120),
];

class _GradePathStop {
  const _GradePathStop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;
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
    final height = stop.height * scale;
    return Positioned(
      left: offsetX + (stop.x * scale) - (width / 2),
      top: (stop.y * scale) - (height / 2),
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
    final games = _gamePreviews(context);
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
      icon: game.id == 'monster-rescue' ? '🐾' : '🎮',
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
    final label = grade.label?.trim() ?? '';
    final isKindergarten = _isKindergartenLabel(label);
    final display = _GradeDisplay.fromGrade(grade);
    final palette = _GradeCirclePalette.forGrade(
      display.number,
      fallbackIndex: index,
      isKindergarten: isKindergarten,
    );

    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: _GradeOvalButton(
          display: display,
          palette: palette,
          isKindergarten: isKindergarten,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _GradeOvalButton extends StatelessWidget {
  const _GradeOvalButton({
    required this.display,
    required this.palette,
    required this.isKindergarten,
    required this.onTap,
  });

  final _GradeDisplay display;
  final _GradeCirclePalette palette;
  final bool isKindergarten;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final buttonWidth = width;
        final buttonHeight = height;
        final contentSize = math.min(buttonWidth, buttonHeight);
        final buttonBorderRadius = BorderRadius.all(
          Radius.elliptical(buttonWidth / 2, buttonHeight / 2),
        );
        final buttonShape = RoundedRectangleBorder(
          borderRadius: buttonBorderRadius,
        );
        final button = Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            borderRadius: buttonBorderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.highlight, palette.top, palette.bottom],
              stops: const [0, 0.43, 1],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
              width: math.max(1.5, contentSize * 0.018),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.edge,
                offset: Offset(0, buttonHeight * 0.052),
                blurRadius: 0,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0x59052F3B),
                offset: Offset(0, buttonHeight * 0.085),
                blurRadius: contentSize * 0.08,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                offset: Offset(-buttonWidth * 0.025, -buttonHeight * 0.025),
                blurRadius: contentSize * 0.045,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: buttonHeight * 0.07,
                left: buttonWidth * 0.16,
                right: buttonWidth * 0.16,
                height: buttonHeight * 0.24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: buttonBorderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.32),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    buttonWidth * 0.1,
                    buttonHeight * 0.09,
                    buttonWidth * 0.1,
                    buttonHeight * 0.08,
                  ),
                  child: isKindergarten
                      ? _KindergartenButtonContent(
                          caption: display.caption,
                          size: contentSize,
                        )
                      : _GradeButtonContent(
                          display: display,
                          size: contentSize,
                        ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  shape: buttonShape,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    customBorder: buttonShape,
                    splashColor: Colors.white24,
                    highlightColor: Colors.white10,
                  ),
                ),
              ),
            ],
          ),
        );

        return button;
      },
    );
  }
}

class _GradeButtonContent extends StatelessWidget {
  const _GradeButtonContent({required this.display, required this.size});

  final _GradeDisplay display;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _OutlinedGradeText(
          display.number ?? '',
          fontSize: size * 0.55,
          outlineColor: const Color(0x4D173E62),
        ),
        SizedBox(height: size * 0.005),
        _OutlinedGradeText(
          '${display.caption} ${display.number ?? ''}'.trim(),
          fontSize: size * 0.15,
          outlineColor: const Color(0x66173E62),
        ),
      ],
    );
  }
}

class _KindergartenButtonContent extends StatelessWidget {
  const _KindergartenButtonContent({required this.caption, required this.size});

  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: size * 0.31,
          shadows: const [
            Shadow(
              color: Color(0x5C6A2600),
              offset: Offset(0, 3),
              blurRadius: 2,
            ),
          ],
        ),
        SizedBox(height: size * 0.035),
        _OutlinedGradeText(
          caption,
          fontSize: size * 0.145,
          outlineColor: const Color(0x667C2F00),
          maxLines: 2,
        ),
      ],
    );
  }
}

class _GradeCirclePalette {
  const _GradeCirclePalette({
    required this.highlight,
    required this.top,
    required this.bottom,
    required this.edge,
  });

  factory _GradeCirclePalette.forGrade(
    String? number, {
    required int fallbackIndex,
    required bool isKindergarten,
  }) {
    if (isKindergarten) {
      return palettes.first;
    }
    final gradeNumber = int.tryParse(number ?? '');
    final paletteIndex = gradeNumber == null
        ? 1 + (fallbackIndex % (palettes.length - 1))
        : gradeNumber.clamp(1, 5);
    return palettes[paletteIndex];
  }

  static const palettes = <_GradeCirclePalette>[
    _GradeCirclePalette(
      highlight: Color(0xFFFFCE3E),
      top: Color(0xFFFFA91F),
      bottom: Color(0xFFF07808),
      edge: Color(0xFFD95704),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFB8F33B),
      top: Color(0xFF7ED321),
      bottom: Color(0xFF45AC13),
      edge: Color(0xFF2B8810),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFF5ED1FF),
      top: Color(0xFF20A5E9),
      bottom: Color(0xFF0873C6),
      edge: Color(0xFF07569F),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFC879F4),
      top: Color(0xFF9850D7),
      bottom: Color(0xFF6425B4),
      edge: Color(0xFF46168A),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFFFF89B4),
      top: Color(0xFFF25994),
      bottom: Color(0xFFC92369),
      edge: Color(0xFF9C164F),
    ),
    _GradeCirclePalette(
      highlight: Color(0xFF68E9E7),
      top: Color(0xFF28C7C8),
      bottom: Color(0xFF0795A4),
      edge: Color(0xFF057581),
    ),
  ];

  final Color highlight;
  final Color top;
  final Color bottom;
  final Color edge;
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
                  child: Image.asset(game.assetPath, fit: BoxFit.cover),
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

List<_GamePreview> _gamePreviews(BuildContext context) {
  return [
    _GamePreview(
      id: 'journey-1',
      title: context.getText(AppKeys.gamesJourneyOne),
      assetPath: 'assets/images/game-numi-farm-banner.png',
      background: const Color(0xFFDDF3EE),
      accent: _gamesTeal,
    ),
    _GamePreview(
      id: 'monster-rescue',
      title: context.getText(AppKeys.gamesRescueTitle),
      assetPath: 'assets/images/game-numi-electric-rescue.png',
      background: const Color(0xFFDDF6E7),
      accent: const Color(0xFF007D77),
      levelCount: monsterRescueLevels.length,
      levelTitleKeys: monsterRescueLevels
          .map((level) => level.titleKey)
          .toList(growable: false),
    ),
  ];
}
