import 'app_language.dart';
import 'strings/auth_strings.dart';
import 'strings/common_strings.dart';
import 'strings/network_strings.dart';
import 'strings/welcome/welcome_strings.dart';
import 'strings/games_strings.dart';
import 'strings/home/home_common_strings.dart';
import 'strings/home/parent_home_strings.dart';
import 'strings/home/student_home_strings.dart';
import 'strings/home/teacher_home_strings.dart';
import 'strings/classroom/student_classroom_strings.dart';
import 'strings/classroom/teacher_classroom_strings.dart';
import 'strings/homework/student_homework_strings.dart';
import 'strings/homework/teacher_homework_strings.dart';
import 'strings/profile/profile_strings.dart';
import 'strings/settings/settings_strings.dart';
import 'strings/study/study_strings.dart';
import 'strings/quiz/quiz_strings.dart';

class AppStrings {
  static final Map<String, Map<String, String>> _localizedValues = {
    'vi': {
      ...authStrings['vi']!,
      ...commonStrings['vi']!,
      ...networkStrings['vi']!,
      ...welcomeStrings['vi']!,
      ...gamesStrings['vi']!,
      ...homeCommonStrings['vi']!,
      ...parentHomeStrings['vi']!,
      ...studentHomeStrings['vi']!,
      ...teacherHomeStrings['vi']!,
      ...studentClassroomStrings['vi']!,
      ...teacherClassroomStrings['vi']!,
      ...studentHomeworkStrings['vi']!,
      ...teacherHomeworkStrings['vi']!,
      ...profileStrings['vi']!,
      ...settingsStrings['vi']!,
      ...studyStrings['vi']!,
      ...quizStrings['vi']!,
    },
    'en': {
      ...authStrings['en']!,
      ...commonStrings['en']!,
      ...networkStrings['en']!,
      ...welcomeStrings['en']!,
      ...gamesStrings['en']!,
      ...homeCommonStrings['en']!,
      ...parentHomeStrings['en']!,
      ...studentHomeStrings['en']!,
      ...teacherHomeStrings['en']!,
      ...studentClassroomStrings['en']!,
      ...teacherClassroomStrings['en']!,
      ...studentHomeworkStrings['en']!,
      ...teacherHomeworkStrings['en']!,
      ...profileStrings['en']!,
      ...settingsStrings['en']!,
      ...studyStrings['en']!,
      ...quizStrings['en']!,
    },
  };

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
