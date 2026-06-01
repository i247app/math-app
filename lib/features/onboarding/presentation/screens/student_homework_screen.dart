import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/classroom_exercise_models.dart';
import '../../data/classroom_exercise_api.dart';

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

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises({String? search}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        search: search,
        visibility: 'PUBLIC',
      );
      if (!mounted) {
        return;
      }
      setState(() => _exercises = exercises);
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const _HomeworkSearchField(),
                    const SizedBox(height: 17),
                    const _HomeworkFilterTabs(),
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
                    else
                      for (var index = 0; index < _exercises.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _exercises.length - 1 ? 0 : 14,
                          ),
                          child: _HomeworkAssignmentCard(
                            exercise: _exercises[index],
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
  const _HomeworkSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.fromLTRB(19, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEEF1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/student_homework_search.png',
            width: 19,
            height: 19,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              context.getText(AppKeys.studentHomeworkSearchHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF515F54).withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeworkFilterTabs extends StatelessWidget {
  const _HomeworkFilterTabs();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkNotSubmitted),
            selected: true,
          ),
          const SizedBox(width: 8),
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkSubmitted),
          ),
          const SizedBox(width: 8),
          _HomeworkFilterChip(
            label: context.getText(AppKeys.studentHomeworkOverdue),
          ),
        ],
      ),
    );
  }
}

class _HomeworkFilterChip extends StatelessWidget {
  const _HomeworkFilterChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? _studentHomeworkActive : const Color(0xFFE5E8EB),
        borderRadius: BorderRadius.circular(9999),
      ),
      alignment: Alignment.center,
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
    );
  }
}

class _HomeworkAssignmentCard extends StatelessWidget {
  const _HomeworkAssignmentCard({required this.exercise});

  final ClassroomExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(context.getText(AppKeys.studentClassComingSoon)),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1400),
              ),
            );
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
              Text(
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
