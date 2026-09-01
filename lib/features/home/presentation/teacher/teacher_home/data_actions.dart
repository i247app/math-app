part of '../teacher_home_tab.dart';

extension _TeacherHomeDataActions on _TeacherRoleTabState {
  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId = profileStableId(widget.activeProfile);
    final requestId = ++_homeLayoutRequestId;
    if (profileId == null || profileId <= 0) {
      _updateState(() {
        _loadedProfileId = profileId;
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = null;
      });
      return;
    }

    final cache = HomeProfileCache.instance;
    final cachedSnapshot = cache.getTeacher(profileId);
    if (!forceRefresh && cachedSnapshot != null) {
      _updateState(() => _applySnapshot(cachedSnapshot));
      if (!cachedSnapshot.isStale) {
        return;
      }
    }

    final hadRenderableContent =
        _hasLoadedHomeLayout && _loadedProfileId == profileId;
    _updateState(() {
      _isLoadingHomeLayout = true;
      _isLoadingAssignments = true;
      if (!hadRenderableContent) {
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _hasLoadedHomeLayout = false;
        _hasLoadedAssignments = false;
      }
      _homeLayoutError = null;
      _loadedProfileId = profileId;
    });

    try {
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _homeLayoutService.getLayout(profileId: profileId),
      );
      if (!mounted ||
          _loadedProfileId != profileId ||
          _homeLayoutRequestId != requestId) {
        return;
      }
      final teacher = layout.teacher;
      final classrooms = layout.rooms.isNotEmpty
          ? layout.rooms
                .map((classroom) => classroom.classroom)
                .toList(growable: false)
          : teacher?.classrooms
                    .map((classroom) => classroom.classroom)
                    .toList(growable: false) ??
                const <ClassroomModel>[];
      final layoutAssignments = layout.tasks
          .where((task) => task.isAssigned)
          .map((task) => task.exercise)
          .whereType<ClassroomExercise>()
          .toList(growable: false);
      final assignments = <ClassroomExercise>[
        if (layout.tasks.isNotEmpty)
          ...layoutAssignments
        else
          ...?teacher?.assignedExercises,
      ]..sort(compareRecentAssignments);

      _updateState(() {
        _layoutClassrooms = classrooms;
        _recentAssignments = assignments;
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = null;
      });
      cache.putTeacher(
        TeacherHomeSnapshot(
          profileId: profileId,
          layoutClassrooms: classrooms,
          recentAssignments: assignments,
          cachedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      if (!mounted ||
          _loadedProfileId != profileId ||
          _homeLayoutRequestId != requestId) {
        return;
      }
      final message = error is HomeLayoutException
          ? error.message
          : context.readText(AppKeys.teacherStudyLoadFailed);
      if (hadRenderableContent) {
        _updateState(() {
          _isLoadingHomeLayout = false;
          _isLoadingAssignments = false;
          _homeLayoutError = message;
        });
        return;
      }
      _updateState(() {
        _layoutClassrooms = const <ClassroomModel>[];
        _recentAssignments = const <ClassroomExercise>[];
        _isLoadingHomeLayout = false;
        _hasLoadedHomeLayout = true;
        _isLoadingAssignments = false;
        _hasLoadedAssignments = true;
        _homeLayoutError = message;
      });
    }
  }

  void _applySnapshot(TeacherHomeSnapshot snapshot) {
    _loadedProfileId = snapshot.profileId;
    _layoutClassrooms = snapshot.layoutClassrooms;
    _recentAssignments = snapshot.recentAssignments;
    _isLoadingHomeLayout = false;
    _hasLoadedHomeLayout = true;
    _isLoadingAssignments = false;
    _hasLoadedAssignments = true;
    _homeLayoutError = null;
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }
}
