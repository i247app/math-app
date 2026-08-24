import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/data/dto/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/data/cache/teacher_homework_cache.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_detail_helpers.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_assignment_info_card.dart';
import 'package:numi/features/homework/widgets/teacher_detail/teacher_question_card.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_copy.dart';

class TeacherHomeworkDetailScreen extends StatefulWidget {
  const TeacherHomeworkDetailScreen({
    super.key,
    required this.exerciseId,
    required this.profileId,
    this.initialExercise,
    this.purpose = classroomExercisePurposeHomework,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int exerciseId;
  final int profileId;
  final ClassroomExercise? initialExercise;
  final String purpose;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherHomeworkDetailScreen> createState() =>
      _TeacherHomeworkDetailScreenState();
}

class _TeacherHomeworkDetailScreenState
    extends State<TeacherHomeworkDetailScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  ClassroomExercise? _exercise;
  String? _savedVisibility;
  String? _editingVisibility;

  String get _effectivePurpose => _exercise?.purpose?.trim().isNotEmpty == true
      ? _exercise!.purpose!.trim()
      : widget.initialExercise?.purpose?.trim().isNotEmpty == true
      ? widget.initialExercise!.purpose!.trim()
      : widget.purpose;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
    final visibility = normalizeExerciseVisibility(_exercise?.visibility);
    _savedVisibility = visibility;
    _editingVisibility = visibility;
    _loadDetail();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedExercise = TeacherHomeworkCache.peekDetail(
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
      );
      if (cachedExercise != null) {
        final visibility = normalizeExerciseVisibility(
          cachedExercise.visibility,
        );
        setState(() {
          _exercise = cachedExercise;
          _savedVisibility = visibility;
          _editingVisibility = visibility;
          _isLoading = true;
          _error = null;
        });
        await _loadDetail(forceRefresh: true);
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercise = await TeacherHomeworkCache.loadDetail(
        service: _exerciseService,
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      final visibility = normalizeExerciseVisibility(exercise?.visibility);
      setState(() {
        _exercise = exercise ?? _exercise;
        _savedVisibility = visibility;
        if (!_hasVisibilityChange) {
          _editingVisibility = visibility;
        }
      });
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message.trim().isEmpty
            ? context.readText(
                teacherExerciseCopy(_effectivePurpose).detailLoadFailedKey,
              )
            : error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _hasVisibilityChange =>
      _editingVisibility != null && _editingVisibility != _savedVisibility;

  Future<void> _saveVisibility() async {
    final visibility = _editingVisibility;
    final exerciseId = _exercise?.stableId ?? widget.exerciseId;
    if (_isSaving || visibility == null || !_hasVisibilityChange) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final updated = await _exerciseService.updateExerciseVisibility(
        profileId: widget.profileId,
        classroomExerciseId: exerciseId,
        visibility: visibility,
        purpose: _effectivePurpose,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _exercise = updated ?? _exercise;
        _savedVisibility =
            normalizeExerciseVisibility(updated?.visibility) ?? visibility;
        _editingVisibility = _savedVisibility;
      });
      if (updated != null) {
        TeacherHomeworkCache.replaceDetail(
          profileId: widget.profileId,
          exercise: updated,
        );
      }
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(
        error.message.trim().isEmpty
            ? context.readText(
                teacherExerciseCopy(_effectivePurpose).createFailedKey,
              )
            : error.message,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    final questions =
        exercise?.questions ?? const <ClassroomExerciseQuestion>[];
    final colors = context.themeColors;
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenAppBar(
              backIconAsset: 'assets/icons/teacher-class-back.svg',
              title: context.getText(
                teacherExerciseCopy(_effectivePurpose).titleKey,
              ),
              onBack: () => Navigator.of(context).maybePop(),
              action: _hasVisibilityChange
                  ? TextButton(
                      onPressed: _isSaving ? null : _saveVisibility,
                      child: _isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.brandStrong,
                              ),
                            )
                          : Text(
                              context.getText(AppKeys.save),
                              style: GoogleFonts.andika(
                                color: colors.brandStrong,
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    )
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.brandStrong,
                onRefresh: () => _loadDetail(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    17,
                    14,
                    18,
                    MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading && exercise == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.teal520,
                            ),
                          ),
                        )
                      else if (_error != null && exercise == null)
                        AppRetryPanel(message: _error!, onRetry: _loadDetail)
                      else ...[
                        TeacherAssignmentInfoCard(
                          exercise: exercise,
                          visibility: _editingVisibility,
                          onVisibilityChanged: (visibility) {
                            setState(() => _editingVisibility = visibility);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 13, left: 7),
                          child: Text(
                            context.getText(
                              AppKeys.teacherAssignmentQuestionContent,
                            ),
                            style: GoogleFonts.andika(
                              color: AppColors.navy900,
                              fontSize: FontSize.large,
                              fontWeight: FontWeight.w700,
                              height: 32 / 18,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            spacing: 15,
                            children: [
                              for (
                                var index = 0;
                                index < questions.length;
                                index++
                              )
                                TeacherQuestionCard(
                                  questionNumber:
                                      questions[index].questionNumber ??
                                      index + 1,
                                  question: questions[index],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
