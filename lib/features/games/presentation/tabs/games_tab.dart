import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/games/domain/models/monster_rescue/monster_rescue_data.dart';
import 'package:numi/features/games/presentation/screens/monster_rescue_stage_screen.dart';
import 'package:numi/features/games/presentation/screens/numi_farm_stage_screen.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/errors/grade_exception.dart';
import 'package:numi/features/practice/domain/models/practice_catalog.dart';
import 'package:numi/features/practice/presentation/screens/practice_chapter_screen.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';

part 'games_tab/grade_selection.dart';
part 'games_tab/catalog.dart';
part 'games_tab/grade_widgets.dart';
part 'games_tab/preview_widgets.dart';

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
