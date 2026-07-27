import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/app_strings.dart';

void main() {
  test('teacher tab headers capitalize each word in Vietnamese', () {
    final strings = AppStrings.getAll(AppLanguage.vi);

    expect(strings[AppKeys.teacherClassroomTitle], 'Lớp Học');
    expect(strings[AppKeys.teacherStudyTitle], 'Học');
    expect(strings[AppKeys.teacherMembersTitle], 'Thành Viên');
    expect(strings[AppKeys.settingsTitle], 'Cài Đặt');
  });

  test('teacher tab headers avoid all caps in English', () {
    final strings = AppStrings.getAll(AppLanguage.en);

    expect(strings[AppKeys.teacherClassroomTitle], 'Classroom');
    expect(strings[AppKeys.teacherStudyTitle], 'Study');
    expect(strings[AppKeys.teacherMembersTitle], 'Members');
    expect(strings[AppKeys.settingsTitle], 'Settings');
  });
}
