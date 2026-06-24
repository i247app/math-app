part of '../home_screen.dart';

extension _StudentHomeModeThreeView on _StudentHomeContentState {
  Widget _buildStudentModeThree() {
    final classroom = _classrooms.first;
    final exercises = _modeHomeworkExercises.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentModeEntrance(
          order: 0,
          child: _StudentModeThreeClassCard(
            classroom: classroom,
            onTap: () => _openClassDetail(classroom),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingModeHomework && exercises.isEmpty)
          const _StudentHomeSectionsLoading()
        else ...[
          for (var index = 0; index < 2; index++) ...[
            _studentModeEntrance(
              order: 1 + index,
              child: _StudentModeThreeHomeworkCard(
                exercise: index < exercises.length ? exercises[index] : null,
                classroom: classroom,
                index: index,
                onTap: index < exercises.length
                    ? () => _openModeHomework(exercises[index])
                    : widget.onOpenClassroomTab,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
        _studentModeEntrance(
          order: 3,
          markOnEnd: true,
          child: _StudentModeThreeGamesSection(
            onViewAll: () => context.read<StudentHomeCubit>().selectTab(3),
          ),
        ),
      ],
    );
  }

  Future<void> _openModeHomework(ClassroomExercise exercise) async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final exerciseId = exercise.stableId;
    if (profileId == null || profileId <= 0 || exerciseId == null) {
      return;
    }

    HapticFeedback.selectionClick();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentHomeworkAttemptScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          exerciseService: _assignmentService,
        ),
      ),
    );

    if (mounted) {
      await _loadHomeLayout();
    }
  }
}

class _StudentModeThreeClassCard extends StatelessWidget {
  const _StudentModeThreeClassCard({
    required this.classroom,
    required this.onTap,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final className = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final teacherName = classroom.teacherName?.trim().isNotEmpty == true
        ? classroom.teacherName!.trim()
        : context.getText(AppKeys.teacherFallback);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 144,
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFDDF8EE),
                Color(0xFFD7E8FF),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -88,
                top: 29,
                child: SizedBox(
                  width: 244,
                  height: 244,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9ECFF).withValues(alpha: 0.56),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3265E6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  context.getText(AppKeys.studentClassroom),
                                  style: const TextStyle(
                                    color: Color(0xFF34495B),
                                    fontSize: FontSize.normal,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              className,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF14358A),
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              teacherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5C666C),
                                fontSize: FontSize.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentModeThreeHomeworkCard extends StatelessWidget {
  const _StudentModeThreeHomeworkCard({
    required this.exercise,
    required this.classroom,
    required this.index,
    required this.onTap,
  });

  final ClassroomExercise? exercise;
  final ClassroomModel classroom;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent =
        index.isEven ? const Color(0xFFC12A73) : const Color(0xFFD33A82);
    final badgeColor =
        index.isEven ? const Color(0xFFFFDDE6) : const Color(0xFFDDF4F8);
    final badgeTextColor =
        index.isEven ? const Color(0xFFC12A73) : const Color(0xFF32868A);
    final title = exercise == null
        ? context.getText(AppKeys.studentNoHomeworkTitle)
        : _studentModeHomeworkTitle(exercise!);
    final className = classroom.name?.trim().isNotEmpty == true
        ? classroom.name!.trim()
        : context.getText(AppKeys.teacherClassFallback);
    final dueText = exercise == null
        ? context.getText(AppKeys.studentNoHomeworkMessage)
        : _studentModeHomeworkDueDate(context, exercise!);

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E5969).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(5, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.90),
            blurRadius: 1,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise == null
                                  ? ''
                                  : _studentModeHomeworkCreatedDate(exercise!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B5C62),
                                fontSize: FontSize.caption * 0.82,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _StudentModeChip(
                            label: className,
                            color: const Color(0xFFF2F4F6),
                            textColor: const Color(0xFF4F5960),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF121B42),
                                fontSize: FontSize.normal,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                          ),
                          _StudentModeChip(
                            label: exercise?.purpose?.trim().isNotEmpty == true
                                ? _studentModePurposeLabel(exercise!.purpose!)
                                : context.getText(AppKeys.studentHomework),
                            color: badgeColor,
                            textColor: badgeTextColor,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF5D5D5D),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dueText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF5D5D5D),
                                fontSize: FontSize.caption,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _StudentModeThreeGamesSection extends StatelessWidget {
  const _StudentModeThreeGamesSection({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: Color(0xFF2D7BEA),
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.getText(AppKeys.navGames),
                style: const TextStyle(
                  color: Color(0xFF202328),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.getText(AppKeys.viewAll)),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _StudentGamePreviewCard(
                asset: 'assets/images/game_numi_farm_banner.png',
                background: Color(0xFFDDF3EE),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _StudentGamePreviewCard(
                background: Color(0xFF111C4B),
                child: _StudentMathSquadronPreviewArtwork(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StudentGamePreviewCard extends StatelessWidget {
  const _StudentGamePreviewCard({
    required this.background,
    this.asset,
    this.child,
  });

  final String? asset;
  final Color background;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ColoredBox(
        color: background,
        child: child ??
            Image.asset(
              asset!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
      ),
    );
  }
}

class _StudentMathSquadronPreviewArtwork extends StatelessWidget {
  const _StudentMathSquadronPreviewArtwork();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111C4B), Color(0xFF335BC5)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            right: 12,
            child: Icon(
              Icons.star_rounded,
              color: Color(0xFFFFD95A),
              size: 15,
            ),
          ),
          Positioned(
            top: 28,
            left: 12,
            child: Icon(Icons.circle, color: Colors.white24, size: 6),
          ),
          Positioned(
            top: 13,
            child: _StudentMathSquadronTarget(),
          ),
          Positioned(
            bottom: 12,
            child: Icon(
              Icons.flight_rounded,
              color: Color(0xFF61DAFF),
              size: 45,
            ),
          ),
          Positioned(
            bottom: 48,
            child: _StudentMathSquadronLaser(),
          ),
        ],
      ),
    );
  }
}

class _StudentMathSquadronTarget extends StatelessWidget {
  const _StudentMathSquadronTarget();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _StudentMathSquadronLaser extends StatelessWidget {
  const _StudentMathSquadronLaser();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 25,
      decoration: BoxDecoration(
        color: const Color(0xFF61DAFF),
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(color: Color(0xFF61DAFF), blurRadius: 9),
        ],
      ),
    );
  }
}

class _StudentModeChip extends StatelessWidget {
  const _StudentModeChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: FontSize.caption * 0.68,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

DateTime _studentModeDate(String? value) {
  return DateTime.tryParse(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _studentModeHomeworkTitle(ClassroomExercise exercise) {
  final title = exercise.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  return exercise.purpose == classroomExercisePurposeQuiz
      ? 'Bài Tập Ôn Luyện'
      : 'Bài Tập Ôn Luyện';
}

String _studentModeHomeworkCreatedDate(ClassroomExercise exercise) {
  return _studentModeDateLabel(exercise.createDt ?? exercise.startDate) ?? '';
}

String _studentModeHomeworkDueDate(
  BuildContext context,
  ClassroomExercise exercise,
) {
  final date = _studentModeDateLabel(exercise.endDate);
  if (date == null) {
    return context.getText(AppKeys.teacherAssignmentDueLabel);
  }
  return '${context.getText(AppKeys.teacherAssignmentDueLabel)}: $date';
}

String? _studentModeDateLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(local.hour)}:${twoDigits(local.minute)} '
      '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
}

String _studentModePurposeLabel(String purpose) {
  final normalized = purpose.trim().toUpperCase();
  if (normalized == classroomExercisePurposeQuiz ||
      normalized == classroomExercisePurposeExam) {
    return 'Kiểm Tra';
  }
  return 'Bài Tập';
}
