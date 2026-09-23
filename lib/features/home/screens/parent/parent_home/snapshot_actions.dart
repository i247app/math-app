part of '../parent_home_tab.dart';

extension _ParentHomeSnapshotActions on ParentHomeContentState {
  Future<void> _refreshAssessmentsInBackground({
    required int requestId,
    required int profileId,
  }) async {
    try {
      final stats = await widget.examService.getExamStats(
        profileId: profileId,
        examType: examTypeAssessment,
      );
      if (!mounted || requestId != _assessmentLoadRequestId) {
        return;
      }

      final assessments =
          stats
              .where(isCompletedAssessmentStats)
              .map(
                (entry) =>
                    completedAssessmentFromStats(entry, profileId: profileId),
              )
              .toList(growable: false)
            ..sort((a, b) => examDate(b).compareTo(examDate(a)));
      final layout = homeLayout;
      _updateState(() {
        _lastAppliedAssessmentLoadRequestId = requestId;
        completedAssessments = assessments;
        if (widget.useActiveStudentProfileData && layout != null) {
          childSummaries = _studentSummariesFromLayout(layout, assessments);
        }
      });
      if (layout != null) {
        HomeProfileCache.instance.putParent(
          ParentHomeSnapshot(
            profileId: profileId,
            homeLayout: layout,
            completedAssessments: assessments,
            cachedAt: DateTime.now(),
          ),
        );
      }
      widget.onParentAssessmentStateChanged(assessments.isNotEmpty);
    } catch (_) {
      // Home layout remains the fallback when the background refresh fails.
    }
  }

  void _applySnapshot(ParentHomeSnapshot snapshot) {
    final parent = snapshot.homeLayout.parent;
    isLoading = false;
    hasLoadedHome = true;
    errorMessage = null;
    homeLayout = snapshot.homeLayout;
    childSummaries = widget.useActiveStudentProfileData
        ? _studentSummariesFromLayout(
            snapshot.homeLayout,
            snapshot.completedAssessments,
          )
        : summariesFromLayout(parent);
    completedAssessments = snapshot.completedAssessments;
  }

  List<ParentChildSummary> _studentSummariesFromLayout(
    HomeLayout layout,
    List<GeneratedExam> assessments,
  ) {
    final profile = layout.profile ?? widget.activeProfile;
    if (profile == null) {
      return const <ParentChildSummary>[];
    }

    final classrooms = layout.rooms.isNotEmpty
        ? layout.rooms
        : layout.student?.classrooms ?? const <HomeLayoutClassroom>[];
    return <ParentChildSummary>[
      ParentChildSummary(
        profile: profile,
        classroom: classrooms.isEmpty ? null : classrooms.first.classroom,
        classrooms: [for (final classroom in classrooms) classroom.classroom],
        assessments: assessments,
      ),
    ];
  }
}
