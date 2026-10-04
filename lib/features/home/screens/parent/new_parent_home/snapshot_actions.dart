part of '../new_parent_home_tab.dart';

extension _ParentHomeSnapshotActions on NewParentHomeContentState {
  Future<void> _refreshAssessmentsInBackground({
    required int requestId,
    required int profileId,
  }) async {
    try {
      final stats = await widget.examService.getExamStats(
        profileId: profileId,
        examTypes: widget.showAssessmentList
            ? const [examTypeGrade, examTypeAssessment]
            : const [examTypeAssessment],
      );
      if (!mounted || requestId != _assessmentLoadRequestId) {
        return;
      }

      final listExams =
          stats
              .where(isCompletedAssessmentStats)
              .map(
                (entry) =>
                    completedAssessmentFromStats(entry, profileId: profileId),
              )
              .toList(growable: false)
            ..sort((a, b) => examDate(b).compareTo(examDate(a)));
      final assessmentStats = stats.where(
        (entry) =>
            (entry.examType ?? examTypeAssessment).trim().toUpperCase() ==
            examTypeAssessment,
      );
      final assessments = listExams
          .where(
            (exam) =>
                (exam.examType ?? '').trim().toUpperCase() ==
                examTypeAssessment,
          )
          .toList(growable: false);
      final resumableAssessment = latestActiveAssessmentExam(assessmentStats);
      final layout = homeLayout;
      _updateState(() {
        _lastAppliedAssessmentLoadRequestId = requestId;
        completedAssessments = assessments;
        learningListExams = listExams;
        activeAssessment = resumableAssessment;
        isLoadingAssessments = false;
        assessmentLoadError = null;
        if (widget.useActiveStudentProfileData && layout != null) {
          childSummaries = _studentSummariesFromLayout(layout, assessments);
        }
      });
      if (layout != null && _cacheScope.isCurrent) {
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
      if (!mounted || requestId != _assessmentLoadRequestId) return;
      _updateState(() {
        isLoadingAssessments = false;
        assessmentLoadError = context.readText(AppKeys.parentExamLoadFailed);
      });
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
