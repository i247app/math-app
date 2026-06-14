import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/homework/presentation/student_homework_attempt_screen.dart';

const _studentHomeworkBg = Color(0xFFF6FFFF);
const _studentHomeworkTeal = Color(0xFF38898C);
const _studentHomeworkActive = Color(0xFF2E6F70);
const _studentHomeworkInk = Color(0xFF001741);
const _studentHomeworkMuted = Color(0xFF444650);

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];
  _HomeworkFilter _activeFilter = _HomeworkFilter.notSubmitted;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 420), () {
      _loadExercises(search: value);
    });
  }

  void _setFilter(_HomeworkFilter filter) {
    if (_activeFilter == filter) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _activeFilter = filter);
    _loadExercises(search: _searchController.text);
  }

  Future<void> _loadExercises({String? search}) async {
    final normalizedSearch = search?.trim() ?? _searchController.text.trim();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        search: normalizedSearch.isEmpty ? null : normalizedSearch,
        visibility: 'PUBLIC',
        submissionStatus: _activeFilter.submissionStatus,
      );
      if (!mounted || _searchController.text.trim() != normalizedSearch) {
        return;
      }
      setState(() => _exercises = exercises);
    } on ClassroomExerciseException catch (error) {
      if (!mounted || _searchController.text.trim() != normalizedSearch) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted && _searchController.text.trim() == normalizedSearch) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openExercise(ClassroomExercise exercise) async {
    if (_studentHomeworkIsSubmitted(exercise)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.getText(AppKeys.studentHomeworkAlreadySubmitted),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1400),
          ),
        );
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content:
                Text(context.getText(AppKeys.studentHomeworkMissingExercise)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1400),
          ),
        );
      return;
    }

    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: widget.profileId,
          initialExercise: exercise,
          exerciseService: _exerciseService,
        ),
      ),
    );
    if (submitted == true) {
      _loadExercises(search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleExercises = _filteredExercises(_exercises, _activeFilter);
    return Scaffold(
      backgroundColor: _studentHomeworkBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _StudentHomeworkTopBar(
              title: context.getText(AppKeys.studentHomework),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  28,
                  20,
                  MediaQuery.paddingOf(context).bottom + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeworkSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) => _loadExercises(search: value),
                    ),
                    const SizedBox(height: 17),
                    _HomeworkFilterTabs(
                      activeFilter: _activeFilter,
                      onFilterSelected: _setFilter,
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _studentHomeworkTeal,
                          ),
                        ),
                      )
                    else if (_error != null)
                      _StudentHomeworkMessage(message: _error!)
                    else if (_exercises.isEmpty)
                      _StudentHomeworkMessage(
                        message:
                            context.getText(AppKeys.studentNoHomeworkMessage),
                      )
                    else if (visibleExercises.isEmpty)
                      _StudentHomeworkMessage(
                        message:
                            context.getText(AppKeys.studentNoHomeworkMessage),
                      )
                    else
                      for (var index = 0;
                          index < visibleExercises.length;
                          index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index == visibleExercises.length - 1 ? 0 : 14,
                          ),
                          child: _HomeworkAssignmentCard(
                            exercise: visibleExercises[index],
                            onTap: () => _openExercise(visibleExercises[index]),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentHomeworkMessage extends StatelessWidget {
  const _StudentHomeworkMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: _studentHomeworkMuted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 22 / 15,
        ),
      ),
    );
  }
}

class _StudentHomeworkTopBar extends StatelessWidget {
  const _StudentHomeworkTopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/student_join_back.svg',
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: _studentHomeworkTeal,
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 34 / 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkSearchField extends StatelessWidget {
  const _HomeworkSearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: GoogleFonts.andika(
        color: _studentHomeworkInk,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
      decoration: InputDecoration(
        hintText: context.getText(AppKeys.studentHomeworkSearchHint),
        hintStyle: GoogleFonts.andika(
          color: const Color(0xFF515F54).withValues(alpha: 0.7),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        filled: true,
        fillColor: const Color(0xFFEBEEF1),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 19,
          vertical: 12,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 19, right: 9),
          child: Image.asset(
            'assets/images/student_homework_search.png',
            width: 19,
            height: 19,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 47,
          minHeight: 19,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: _studentHomeworkMuted,
                  size: 18,
                ),
              ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: _studentHomeworkTeal.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

class _HomeworkFilterTabs extends StatelessWidget {
  const _HomeworkFilterTabs({
    required this.activeFilter,
    required this.onFilterSelected,
  });

  final _HomeworkFilter activeFilter;
  final ValueChanged<_HomeworkFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final filter in _HomeworkFilter.values) ...[
            _HomeworkFilterChip(
              label: context.getText(filter.labelKey),
              selected: filter == activeFilter,
              onTap: () => onFilterSelected(filter),
            ),
            if (filter != _HomeworkFilter.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

enum _HomeworkFilter {
  notSubmitted(AppKeys.studentHomeworkNotSubmitted, 'NOT_SUBMITTED'),
  submitted(AppKeys.studentHomeworkSubmitted, 'SUBMITTED'),
  overdue(AppKeys.studentHomeworkOverdue, 'NOT_SUBMITTED');

  const _HomeworkFilter(this.labelKey, this.submissionStatus);

  final String labelKey;
  final String? submissionStatus;
}

class _HomeworkFilterChip extends StatelessWidget {
  const _HomeworkFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _studentHomeworkActive : const Color(0xFFE5E8EB),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.andika(
                color: selected ? Colors.white : _studentHomeworkMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkAssignmentCard extends StatelessWidget {
  const _HomeworkAssignmentCard({
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _studentHomeworkCreatedDate(exercise),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: _studentHomeworkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HomeworkStatusBadge(exercise: exercise),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _studentHomeworkTitle(exercise),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _studentHomeworkInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _studentHomeworkQuestionCount(context, exercise),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _studentHomeworkMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 20 / 14,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 17),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFC4C6D2).withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/student_homework_calendar.svg',
                      width: 12,
                      height: 13.33,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _studentHomeworkDueDate(context, exercise),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _studentHomeworkMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeworkStatusBadge extends StatelessWidget {
  const _HomeworkStatusBadge({required this.exercise});

  final ClassroomExercise exercise;

  @override
  Widget build(BuildContext context) {
    final submitted = _studentHomeworkIsSubmitted(exercise);
    final overdue = _studentHomeworkIsOverdue(exercise);
    final labelKey = submitted
        ? AppKeys.studentHomeworkSubmitted
        : overdue
            ? AppKeys.studentHomeworkOverdue
            : AppKeys.studentHomeworkNotSubmitted;
    final color = submitted
        ? const Color(0xFF2E7D32)
        : overdue
            ? const Color(0xFFC2410C)
            : _studentHomeworkTeal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          context.getText(labelKey),
          maxLines: 1,
          style: GoogleFonts.andika(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}

String _studentHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise.stableId;
  return id == null ? '' : 'ID: $id';
}

String _studentHomeworkQuestionCount(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final count = exercise.numQuestions ?? exercise.questions.length;
  if (count > 0) {
    return context.formatText(
      AppKeys.teacherAssignmentQuestionCountFormat,
      {'count': count},
    );
  }
  return '';
}

String _studentHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentHomeworkDateLabel(exercise.endDate);
  if (date == null) {
    return '';
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String _studentHomeworkCreatedDate(ClassroomExercise exercise) {
  return _studentHomeworkDateLabel(exercise.createDt) ?? '';
}

String? _studentHomeworkDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_studentHomeworkTwoDigits(local.hour)}:'
      '${_studentHomeworkTwoDigits(local.minute)} '
      '${_studentHomeworkTwoDigits(local.day)}/'
      '${_studentHomeworkTwoDigits(local.month)}/${local.year}';
}

String _studentHomeworkTwoDigits(int value) => value.toString().padLeft(2, '0');

List<ClassroomExercise> _filteredExercises(
  List<ClassroomExercise> exercises,
  _HomeworkFilter filter,
) {
  return exercises.where((exercise) {
    final submitted = _studentHomeworkIsSubmitted(exercise);
    final overdue = _studentHomeworkIsOverdue(exercise);
    return switch (filter) {
      _HomeworkFilter.notSubmitted => !submitted && !overdue,
      _HomeworkFilter.submitted => submitted,
      _HomeworkFilter.overdue => overdue,
    };
  }).toList(growable: false);
}

bool _studentHomeworkIsSubmitted(ClassroomExercise exercise) {
  return exercise.submissionStatus?.trim().toUpperCase() == 'SUBMITTED';
}

bool _studentHomeworkIsOverdue(ClassroomExercise exercise) {
  if (_studentHomeworkIsSubmitted(exercise)) {
    return false;
  }
  final parsed = DateTime.tryParse(exercise.endDate?.trim() ?? '');
  if (parsed == null) {
    return false;
  }
  return parsed.toLocal().isBefore(DateTime.now());
}
