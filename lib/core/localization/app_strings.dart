import 'app_language.dart';
import 'strings/auth_strings.dart';
import 'strings/classroom/student_classroom_strings.dart';
import 'strings/classroom/teacher_classroom_strings.dart';
import 'strings/classroom_exercise/student_classroom_exercise_strings.dart';
import 'strings/classroom_exercise/teacher_classroom_exercise_strings.dart';
import 'strings/common_strings.dart';
import 'strings/exam/exam_strings.dart';
import 'strings/games_strings.dart';
import 'strings/home/home_common_strings.dart';
import 'strings/home/parent_home_strings.dart';
import 'strings/home/student_home_strings.dart';
import 'strings/home/teacher_home_strings.dart';
import 'strings/network_strings.dart';
import 'strings/notification_strings.dart';
import 'strings/profile/profile_strings.dart';
import 'strings/settings/settings_strings.dart';
import 'strings/study/study_strings.dart';
import 'strings/welcome/welcome_strings.dart';

class AppStrings {
  static const _groups = [
    authStrings,
    commonStrings,
    networkStrings,
    welcomeStrings,
    gamesStrings,
    homeCommonStrings,
    parentHomeStrings,
    studentHomeStrings,
    teacherHomeStrings,
    studentClassroomStrings,
    teacherClassroomStrings,
    studentClassroomExerciseStrings,
    teacherClassroomExerciseStrings,
    notificationStrings,
    profileStrings,
    settingsStrings,
    studyStrings,
    examStrings,
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    for (final language in AppLanguage.values)
      language.lookupCode: _merge(language),
  };

  static Map<String, String> _merge(AppLanguage language) {
    final values = <String, String>{};
    for (final group in _groups) {
      final translations = group[language.lookupCode];
      if (translations == null) {
        throw StateError(
          'Missing localization group for ${language.lookupCode}',
        );
      }
      for (final entry in translations.entries) {
        if (values.containsKey(entry.key)) {
          throw StateError(
            'Duplicate localization key ${entry.key} for ${language.lookupCode}',
          );
        }
        values[entry.key] = entry.value;
      }
    }
    return values;
  }

  static Map<String, String> getAll(AppLanguage language) {
    return _localizedValues[language.lookupCode] ?? _localizedValues['vi']!;
  }

  static String current(String key) {
    return getAll(AppLanguageState.current)[key] ?? key;
  }

  static String currentFormat(String key, Map<String, Object?> values) {
    var text = current(key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value?.toString() ?? '');
    }
    return text;
  }
}
