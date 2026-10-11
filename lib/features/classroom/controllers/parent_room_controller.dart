import 'package:flutter/foundation.dart';
import 'package:numi/core/data/app_failure.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/parent_home_snapshot.dart';
import 'package:numi/features/home/helpers/home_layout_helpers.dart';
import 'package:numi/features/home/models/home_layout.dart';

class ParentRoomController extends ChangeNotifier {
  ParentRoomController({
    required Future<HomeLayout> Function(int profileId) loadLayout,
  }) : _loadLayout = loadLayout;
  final Future<HomeLayout> Function(int profileId) _loadLayout;
  AsyncResource<HomeLayout> _state = const AsyncResource.idle();
  AsyncResource<HomeLayout> get state => _state;
  int? _profileId;
  int _revision = 0;
  bool _disposed = false;

  /// Drop the previous profile's data even while the tab is offstage.
  void selectProfile(int? profileId) {
    if (_disposed || profileId == _profileId) return;
    _profileId = profileId;
    _revision++;
    _state = const AsyncResource.idle();
    notifyListeners();
  }

  Future<void> load({
    required int? profileId,
    bool forceRefresh = false,
  }) async {
    if (_disposed) return;
    selectProfile(profileId);
    final revision = ++_revision;
    final scope = SessionCacheScope.current;
    if (profileId == null || profileId <= 0) {
      _state = AsyncResource.ready(
        const HomeLayout(),
        updatedAt: DateTime.now(),
      );
      notifyListeners();
      return;
    }
    final cache = HomeProfileCache.instance;
    final snapshot = cache.getParent(profileId);
    if (!forceRefresh && snapshot != null) {
      _state = AsyncResource.ready(
        snapshot.homeLayout,
        updatedAt: snapshot.cachedAt,
      );
      notifyListeners();
      if (!snapshot.isStale) return;
    }
    final previous = _state;
    _state = previous.refreshing();
    notifyListeners();
    bool current() => !_disposed && revision == _revision && scope.isCurrent;
    try {
      final layout = await cache.loadLayout(
        profileId: profileId,
        loader: () => _loadLayout(profileId),
      );
      if (!current()) return;
      final cachedAt = DateTime.now();
      _state = AsyncResource.ready(layout, updatedAt: cachedAt);
      cache.putParent(
        ParentHomeSnapshot(
          profileId: profileId,
          homeLayout: layout,
          completedAssessments: examsFromLayoutExams(layout.exams),
          cachedAt: cachedAt,
        ),
      );
    } catch (error) {
      if (!current()) return;
      _state = AsyncResource.failed(
        AppFailure.fromException(error),
        data: previous.data,
        hasData: previous.hasData,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    super.dispose();
  }
}
