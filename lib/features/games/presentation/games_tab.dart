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
          bottomPadding: widget.bottomPadding,
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
    required this.bottomPadding,
    required this.onRetry,
    required this.onSelected,
  });

  final List<GradeModel> grades;
  final bool isLoading;
  final String? errorMessage;
  final double bottomPadding;
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

    return ColoredBox(
      color: colors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 32, 24, bottomPadding + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GamesEntrance(
                order: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GamesEyebrow(label: context.getText(AppKeys.navGames)),
                    const SizedBox(height: 16),
                    Text(
                      context.getText(AppKeys.gamesGradeTitle),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.getText(AppKeys.gamesGradeSubtitle),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: FontSize.normal,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              if (isLoading)
                const _GamesGradeLoading()
              else if (errorMessage != null)
                _GamesEntrance(
                  order: 1,
                  child: _GamesMessageCard(
                    icon: Icons.cloud_off_rounded,
                    message: errorMessage!,
                    actionLabel: context.getText(AppKeys.retryUpper),
                    onAction: onRetry,
                  ),
                )
              else if (visibleGrades.isEmpty)
                _GamesEntrance(
                  order: 1,
                  child: _GamesMessageCard(
                    icon: Icons.school_outlined,
                    message: context.getText(AppKeys.noGrades),
                    actionLabel: context.getText(AppKeys.retryUpper),
                    onAction: onRetry,
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleGrades.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) => _GamesEntrance(
                    order: index + 1,
                    child: _GamesGradeCard(
                      grade: visibleGrades[index],
                      index: index,
                      onTap: () => onSelected(visibleGrades[index]),
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
                child: _GamesEntrance(
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
                itemBuilder: (context, index) => _GamesEntrance(
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
    final colors = context.themeColors;
    const palettes = <_GradeNumberPalette>[
      _GradeNumberPalette(
        top: Color(0xFFFFDA17),
        bottom: Color(0xFFFFA800),
        depth: Color(0xFFF06B17),
        shadow: Color(0x55384350),
      ),
      _GradeNumberPalette(
        top: Color(0xFFA9DD35),
        bottom: Color(0xFF71BD26),
        depth: Color(0xFF2A8B22),
        shadow: Color(0x55384350),
      ),
      _GradeNumberPalette(
        top: Color(0xFF20C8ED),
        bottom: Color(0xFF0794D3),
        depth: Color(0xFF075FB3),
        shadow: Color(0x55384350),
      ),
      _GradeNumberPalette(
        top: Color(0xFFFF514B),
        bottom: Color(0xFFF01422),
        depth: Color(0xFFB8071C),
        shadow: Color(0x55384350),
      ),
      _GradeNumberPalette(
        top: Color(0xFF76DCCB),
        bottom: Color(0xFF3DB9A5),
        depth: Color(0xFF168A7C),
        shadow: Color(0x55384350),
      ),
    ];
    final label = grade.label?.trim() ?? '';
    final number = _gradeNumber(grade, index);
    final palette = palettes[index % palettes.length];

    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.22),
              blurRadius: 18,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: _ThreeDimensionalNumber(
                  number: number,
                  palette: palette,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreeDimensionalNumber extends StatelessWidget {
  const _ThreeDimensionalNumber({required this.number, required this.palette});

  final String number;
  final _GradeNumberPalette palette;

  TextStyle get _numberStyle => const TextStyle(
    fontSize: 76,
    fontWeight: FontWeight.w900,
    height: 1,
    letterSpacing: -3,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 98,
      height: 104,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(7, 12),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: palette.shadow),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 9),
            child: Text(
              number,
              style: _numberStyle.copyWith(
                color: palette.depth,
                shadows: [
                  Shadow(
                    color: palette.shadow,
                    offset: const Offset(3, 4),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.top, palette.bottom],
              stops: const [0.12, 0.88],
            ).createShader(bounds),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeNumberPalette {
  const _GradeNumberPalette({
    required this.top,
    required this.bottom,
    required this.depth,
    required this.shadow,
  });

  final Color top;
  final Color bottom;
  final Color depth;
  final Color shadow;
}

String _gradeNumber(GradeModel grade, int index) {
  final match = RegExp(r'\d+').firstMatch(grade.label ?? '');
  return match?.group(0) ?? '${grade.displayOrder ?? index + 1}';
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

class _GamesGradeLoading extends StatelessWidget {
  const _GamesGradeLoading();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: colors.elevatedSurface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(28),
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

class _GamesEntrance extends StatefulWidget {
  const _GamesEntrance({required this.order, required this.child});

  final int order;
  final Widget child;

  @override
  State<_GamesEntrance> createState() => _GamesEntranceState();
}

class _GamesEntranceState extends State<_GamesEntrance> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(
        Duration(milliseconds: 55 * widget.order.clamp(0, 8)),
      );
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : const Offset(0, 0.055),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isVisible ? 1 : 0.94,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
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
        assetPath: 'assets/images/parent_home_race.png',
        background: _gamesCream,
        accent: const Color(0xFFA86700),
      ),
      _GamePreview(
        id: 'journey-3',
        title: context.getText(AppKeys.gamesJourneyThree),
        assetPath: 'assets/images/parent_home_shop.png',
        background: const Color(0xFFFFE5DD),
        accent: _gamesOrange,
      ),
    ];
  }
  return [
    _GamePreview(
      id: 'journey-1',
      title: context.getText(AppKeys.gamesJourneyOne),
      assetPath: 'assets/images/game_numi_farm_banner.png',
      background: const Color(0xFFDDF3EE),
      accent: _gamesTeal,
    ),
    _GamePreview(
      id: 'journey-2',
      title: context.getText(AppKeys.gamesJourneyTwo),
      assetPath: 'assets/images/parent_home_race.png',
      background: _gamesCream,
      accent: const Color(0xFFA86700),
    ),
    _GamePreview(
      id: 'journey-3',
      title: context.getText(AppKeys.gamesJourneyThree),
      assetPath: 'assets/images/parent_home_shop.png',
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
