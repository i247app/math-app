import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/features/classroom/data/student_class_search_filter_cache.dart';
import 'package:numi/features/classroom/data/teacher_classroom_lookup_cache.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/teacher_classroom_exercise_cache.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_history_classroom_exercise_cache.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/notifications/data/notification_cache.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';

class AppSessionDataCleaner implements SessionDataCleaner {
  const AppSessionDataCleaner();

  @override
  void clear() {
    SessionCacheScope.reset();
    HomeProfileCache.instance.invalidateAll();
    NotificationCache.invalidate();
    ExamCache.clear();
    StudentClassroomExerciseCache.clear();
    TeacherClassroomExerciseCache.clear();
    ExamHistoryClassroomExerciseCache.clear();
    TeacherClassroomLookupCache.shared.clear();
    StudentClassSearchFilterCache.shared.clear();
    ProfileOptionsCache.instance.clear();
  }
}
