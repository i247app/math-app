import 'package:flutter/material.dart';

import 'package:numi/features/profile/data/dto/grade_models.dart';
import 'package:numi/features/profile/data/dto/profile_models.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';

/// State snapshot for [DashboardProfileController].
class DashboardProfileState {
  const DashboardProfileState({
    this.isSwitchingProfile = false,
    this.isMenuOpen = false,
    this.prefetchedGrades = const <GradeModel>[],
    this.prefetchedGradeUserId,
    this.profileResetSignal = 0,
    this.openAddProfileRequestId = 0,
  });

  static const Object _unchanged = Object();

  /// True while [DashboardProfileController.switchProfile] is in progress.
  /// Used to disable double-tap (no overlay shown — skeleton handles feedback).
  final bool isSwitchingProfile;

  /// True while the profile switcher menu is open.
  final bool isMenuOpen;

  /// Grades pre-fetched for the current user, passed down as initial data.
  final List<GradeModel> prefetchedGrades;

  /// The userId whose grades are currently cached in [prefetchedGrades].
  final int? prefetchedGradeUserId;

  /// Increments every time a profile switch completes successfully.
  /// Replaces the `ValueKey` on `RoleTabHost` — tabs react to this
  /// signal instead of the entire subtree being recreated.
  final int profileResetSignal;

  /// Increments every time the user requests to open the Add Profile form.
  final int openAddProfileRequestId;

  DashboardProfileState copyWith({
    bool? isSwitchingProfile,
    bool? isMenuOpen,
    List<GradeModel>? prefetchedGrades,
    Object? prefetchedGradeUserId = _unchanged,
    int? profileResetSignal,
    int? openAddProfileRequestId,
  }) {
    return DashboardProfileState(
      isSwitchingProfile: isSwitchingProfile ?? this.isSwitchingProfile,
      isMenuOpen: isMenuOpen ?? this.isMenuOpen,
      prefetchedGrades: prefetchedGrades ?? this.prefetchedGrades,
      prefetchedGradeUserId: identical(prefetchedGradeUserId, _unchanged)
          ? this.prefetchedGradeUserId
          : prefetchedGradeUserId as int?,
      profileResetSignal: profileResetSignal ?? this.profileResetSignal,
      openAddProfileRequestId:
          openAddProfileRequestId ?? this.openAddProfileRequestId,
    );
  }
}

/// Manages profile-switching concerns for the home screen.
///
/// Responsibilities:
/// - [switchProfile]: calls [onActivateProfile], increments [DashboardProfileState.profileResetSignal]
/// - [prefetchGrades]: pre-loads grade list for current user
/// - [openMenu] / [closeMenu]: profile switcher menu visibility
/// - [requestAddProfile]: increments [DashboardProfileState.openAddProfileRequestId]
///
/// This is a [ChangeNotifier] so the UI rebuilds cheaply via [ListenableBuilder].
class DashboardProfileController extends ChangeNotifier {
  DashboardProfileController({required GradeService gradeService})
    : _gradeService = gradeService;

  final GradeService _gradeService;

  DashboardProfileState _state = const DashboardProfileState();
  DashboardProfileState get state => _state;

  bool _isPrefetchingGrades = false;
  bool _disposed = false;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Switches to [profile] by calling [onActivateProfile].
  /// Increments [DashboardProfileState.profileResetSignal] on success so that
  /// [RoleTabHost] resets its data without recreating the widget tree.
  Future<void> switchProfile(
    StudentProfile profile, {
    required StudentProfile? activeProfile,
    required Future<void> Function(StudentProfile) onActivateProfile,
    void Function(String message)? onError,
  }) async {
    if (_state.isSwitchingProfile) return;
    if (ActiveProfileSession.profileStableId(profile) ==
        ActiveProfileSession.profileStableId(activeProfile)) {
      return;
    }

    _update(_state.copyWith(isSwitchingProfile: true, isMenuOpen: false));

    try {
      await onActivateProfile(profile);
      if (_disposed) return;
      _update(
        _state.copyWith(
          isSwitchingProfile: false,
          profileResetSignal: _state.profileResetSignal + 1,
        ),
      );
    } catch (_) {
      if (_disposed) return;
      _update(_state.copyWith(isSwitchingProfile: false));
      onError?.call('profile_switch_failed');
    }
  }

  /// Opens the profile switcher menu if not already open.
  void openMenu() {
    if (_state.isMenuOpen) return;
    _update(_state.copyWith(isMenuOpen: true));
  }

  /// Closes the profile switcher menu.
  void closeMenu() {
    if (!_state.isMenuOpen) return;
    _update(_state.copyWith(isMenuOpen: false));
  }

  /// Toggles the profile switcher menu.
  void toggleMenu() {
    _update(_state.copyWith(isMenuOpen: !_state.isMenuOpen));
  }

  /// Increments [DashboardProfileState.openAddProfileRequestId] to signal that the
  /// Add Profile form should open.
  void requestAddProfile() {
    _update(
      _state.copyWith(
        openAddProfileRequestId: _state.openAddProfileRequestId + 1,
      ),
    );
  }

  /// Pre-fetches grades for [userId]. Guards against duplicate in-flight
  /// requests and stale responses if the user changes before the call returns.
  Future<void> prefetchGrades(int? userId) async {
    if (userId == null || userId <= 0) return;
    if (_isPrefetchingGrades) return;
    if (_state.prefetchedGradeUserId == userId &&
        _state.prefetchedGrades.isNotEmpty) {
      return;
    }

    _isPrefetchingGrades = true;

    try {
      final grades = await _gradeService.listGrades(userId: userId);
      if (_disposed) return;
      // Discard result if user changed while fetching.
      _update(
        _state.copyWith(
          prefetchedGrades: grades,
          prefetchedGradeUserId: userId,
        ),
      );
    } catch (_) {
      if (_disposed) return;
      _update(
        _state.copyWith(
          prefetchedGrades: const <GradeModel>[],
          prefetchedGradeUserId: userId,
        ),
      );
    } finally {
      _isPrefetchingGrades = false;
    }
  }

  /// Call when the user changes so that cached grades are invalidated.
  void invalidateGrades() {
    _update(
      _state.copyWith(
        prefetchedGrades: const <GradeModel>[],
        prefetchedGradeUserId: null,
      ),
    );
  }

  // ── Internals ───────────────────────────────────────────────────────────────

  void _update(DashboardProfileState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
