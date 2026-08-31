import 'package:numi/features/home/parent/data/cache/parent_home_snapshot.dart';
import 'package:numi/features/home/teacher/data/cache/teacher_home_snapshot.dart';
import 'package:numi/features/home/data/dto/home_layout_models.dart';

/// In-memory, per-session cache for home-screen data indexed by profile ID.
///
/// Implements a stale-while-revalidate strategy:
/// - On profile switch → check cache → show cached data immediately (if any)
/// - If snapshot [isStale] → background refresh while user sees cached content
/// - If no cache → show skeleton → load → cache result
///
/// Lifetime: tied to the [DashboardScreen] widget (create in [_DashboardScreenState],
/// pass down to tabs via [HomeProfileCache.instance] or constructor injection).
///
/// Call [invalidateAll] on logout.
class HomeProfileCache {
  HomeProfileCache._();

  static final HomeProfileCache instance = HomeProfileCache._();

  final Map<int, ParentHomeSnapshot> _parent = {};
  final Map<int, TeacherHomeSnapshot> _teacher = {};
  final Map<int, Future<HomeLayout>> _pendingLayouts = {};

  /// Joins concurrent home-layout requests for the same profile.
  ///
  /// Home, room, and role dashboards can request the same endpoint during a
  /// rapid tab switch. Sharing the in-flight request prevents a cold cache
  /// from creating duplicate network work.
  Future<HomeLayout> loadLayout({
    required int profileId,
    required Future<HomeLayout> Function() loader,
  }) {
    final pending = _pendingLayouts[profileId];
    if (pending != null) {
      return pending;
    }

    late final Future<HomeLayout> request;
    request = loader().whenComplete(() {
      if (identical(_pendingLayouts[profileId], request)) {
        _pendingLayouts.remove(profileId);
      }
    });
    _pendingLayouts[profileId] = request;
    return request;
  }

  // ── Parent ──────────────────────────────────────────────────────────────────

  ParentHomeSnapshot? getParent(int profileId) => _parent[profileId];

  void putParent(ParentHomeSnapshot snapshot) {
    _parent[snapshot.profileId] = snapshot;
  }

  // ── Teacher ─────────────────────────────────────────────────────────────────

  TeacherHomeSnapshot? getTeacher(int profileId) => _teacher[profileId];

  void putTeacher(TeacherHomeSnapshot snapshot) {
    _teacher[snapshot.profileId] = snapshot;
  }

  // ── Invalidation ────────────────────────────────────────────────────────────

  /// Removes all cached snapshots. Call this on logout.
  void invalidateAll() {
    _parent.clear();
    _teacher.clear();
    _pendingLayouts.clear();
  }

  /// Removes cached data for a single profile across all roles.
  void invalidateProfile(int profileId) {
    _parent.remove(profileId);
    _teacher.remove(profileId);
    _pendingLayouts.remove(profileId);
  }
}
