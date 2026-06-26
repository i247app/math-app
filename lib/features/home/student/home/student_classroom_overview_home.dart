part of '../../home_screen.dart';

extension _StudentClassroomOverviewHomeView on _StudentHomeContentState {
  Widget _buildStudentClassroomOverviewState() {
    final classroom = _classrooms.first;
    final exercises = _modeHomeworkExercises.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _studentClassroomOverviewEntrance(
          order: 0,
          child: _StudentClassSummaryCard(
            classroom: classroom,
            onTap: () => _openClassDetail(classroom),
          ),
        ),
        const SizedBox(height: 14),
        if (_isLoadingModeHomework && exercises.isEmpty)
          const _StudentHomeSectionsLoading()
        else ...[
          for (var index = 0; index < 2; index++) ...[
            _studentClassroomOverviewEntrance(
              order: 1 + index,
              child: _StudentHomeworkPreviewCard(
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
        _studentClassroomOverviewEntrance(
          order: 3,
          markOnEnd: true,
          child: _StudentGameSuggestionsSection(
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
