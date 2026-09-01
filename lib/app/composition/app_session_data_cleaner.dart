import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/notifications/data/cache/notification_cache.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';

class AppSessionDataCleaner implements SessionDataCleaner {
  const AppSessionDataCleaner();

  @override
  void clear() {
    HomeProfileCache.instance.invalidateAll();
    NotificationCache.invalidate();
    QuizCache.invalidateLists();
  }
}
