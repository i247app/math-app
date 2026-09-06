import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/notifications/data/notification_cache.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';

class AppSessionDataCleaner implements SessionDataCleaner {
  const AppSessionDataCleaner();

  @override
  void clear() {
    HomeProfileCache.instance.invalidateAll();
    NotificationCache.invalidate();
    QuizCache.invalidateLists();
  }
}
