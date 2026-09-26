import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_exception.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/profile/models/semester.dart';
import 'package:numi/features/profile/widgets/profile_form_panel.dart';
import 'package:numi/features/session/data/passcode_service.dart';
import 'package:numi/features/settings/data/settings_profile_form_service.dart';
import 'package:numi/features/settings/models/settings_profile_form.dart';
import 'package:numi/features/settings/screens/setting_tab.dart';

void main() {
  late _Profiles profiles;
  late _Grades grades;
  late _Schools schools;
  late SettingsProfileFormService service;

  setUp(() {
    ProfileOptionsCache.instance.clear();
    profiles = _Profiles();
    grades = _Grades();
    schools = _Schools();
    service = SettingsProfileFormService(
      profileService: profiles,
      gradeService: grades,
      schoolService: schools,
    );
  });
  tearDown(() => ProfileOptionsCache.instance.clear());

  test(
    'loads options concurrently and caches correctly named results',
    () async {
      final schoolResult = Completer<List<SchoolModel>>();
      final gradeResult = Completer<List<GradeModel>>();
      final programResult = Completer<List<ProgramModel>>();
      final semesterResult = Completer<List<SemesterModel>>();
      schools.result = schoolResult.future;
      grades.result = gradeResult.future;
      profiles.programs = programResult.future;
      profiles.semesters = semesterResult.future;

      final pending = service.loadOptions(7);
      expect(schools.calls, 1);
      expect(grades.users, [7]);
      expect(profiles.programUsers, [7]);
      expect(profiles.semesterUsers, [7]);
      // Complete in a different order from the request order.
      semesterResult.complete(const [SemesterModel(semesterId: 4)]);
      programResult.complete(const [ProgramModel(programId: 3)]);
      gradeResult.complete(const [GradeModel(gradeId: 2)]);
      schoolResult.complete(const [SchoolModel(schoolId: 1)]);
      final options = await pending;
      expect(options.schools.single.schoolId, 1);
      expect(options.grades.single.gradeId, 2);
      expect(options.programs.single.programId, 3);
      expect(options.semesters.single.semesterId, 4);
      expect(() => options.schools.clear(), throwsUnsupportedError);
      expect(await service.loadOptions(7), same(options));
      expect(schools.calls, 1);

      await service.loadOptions(8);
      expect(schools.calls, 2);
      expect(grades.users, [7, 8]);
    },
  );

  test(
    'option failure retains the API error and never caches partial data',
    () async {
      const error = SchoolException('Schools unavailable');
      schools.result = Future.error(error);
      await expectLater(service.loadOptions(7), throwsA(same(error)));
      expect(service.cachedOptions(7), isNull);
      schools.result = Future.value(const [SchoolModel(schoolId: 1)]);
      expect((await service.loadOptions(7)).schools.single.schoolId, 1);
      expect(schools.calls, 2);
    },
  );

  test('rejects a missing account before loading options', () async {
    await expectLater(
      service.loadOptions(0),
      throwsA(
        isA<SettingsProfileValidationException>().having(
          (error) => error.errorKey,
          'errorKey',
          AppKeys.profileOptionsMissingAccount,
        ),
      ),
    );
    expect(schools.calls, 0);
    expect(grades.users, isEmpty);
  });

  test(
    'creates and activates a student with all selected option IDs',
    () async {
      final result = await service.save(
        const SettingsProfileDraft(
          user: LoginUser(id: 7, role: 'PARENT'),
          name: '  Student  ',
          hasProfiles: false,
          schoolId: 1,
          gradeId: 2,
          programId: 3,
          semesterId: 4,
          avatarKey: 'avatar-1',
          identifier: '  student-id  ',
        ),
      );
      expect(profiles.calls.single.memberName, #createProfile);
      final args = profiles.calls.single.namedArguments;
      expect(args, containsPair(#userId, 7));
      expect(args, containsPair(#name, 'Student'));
      expect(args, containsPair(#schoolId, 1));
      expect(args, containsPair(#gradeId, 2));
      expect(args, containsPair(#programId, 3));
      expect(args, containsPair(#semesterId, 4));
      expect(args, containsPair(#isDefault, true));
      expect(args, containsPair(#role, 'STUDENT'));
      expect(args, containsPair(#avatarKey, 'avatar-1'));
      expect(args, containsPair(#idType, 'MOET'));
      expect(args, containsPair(#studentId, 'student-id'));
      expect(args, containsPair(#teacherId, null));
      expect(result.profileToActivate, same(profiles.savedProfile));
      expect(result.requiresProfileRefresh, isFalse);
    },
  );

  test('creates teachers without student-only selections', () async {
    final result = await service.save(
      const SettingsProfileDraft(
        user: LoginUser(id: 7, role: 'TEACHER'),
        name: 'Teacher',
        hasProfiles: true,
        schoolId: 1,
        gradeId: 2,
        programId: 3,
        semesterId: 4,
        idType: ' public_id ',
        identifier: '  teacher-id  ',
      ),
    );
    final args = profiles.calls.single.namedArguments;
    expect(args, containsPair(#role, 'TEACHER'));
    expect(args, containsPair(#isDefault, false));
    expect(args, containsPair(#gradeId, null));
    expect(args, containsPair(#programId, null));
    expect(args, containsPair(#semesterId, null));
    expect(args, containsPair(#studentId, null));
    expect(args, containsPair(#idType, 'PUBLIC_ID'));
    expect(args, containsPair(#teacherId, 'teacher-id'));
    expect(result.profileToActivate, isNull);
  });

  test(
    'activates the first teacher profile, but not a response without an ID',
    () async {
      const draft = SettingsProfileDraft(
        user: LoginUser(id: 7, role: 'TEACHER'),
        name: 'Teacher',
        hasProfiles: false,
        schoolId: 1,
      );
      expect(
        (await service.save(draft)).profileToActivate,
        same(profiles.savedProfile),
      );
      profiles.savedProfile = const StudentProfile(name: 'No ID');
      expect((await service.save(draft)).profileToActivate, isNull);
    },
  );

  test('updates a parent using only the editable name and avatar', () async {
    final result = await service.save(
      const SettingsProfileDraft(
        user: LoginUser(id: 7, role: 'PARENT'),
        name: ' Parent ',
        hasProfiles: true,
        editingProfile: StudentProfile(profileId: 19, role: 'PARENT'),
        avatarKey: 'new-avatar',
        identifier: 'unused',
      ),
    );
    final args = profiles.calls.single.namedArguments;
    expect(profiles.calls.single.memberName, #updateProfile);
    expect(args, containsPair(#profileId, 19));
    expect(args, containsPair(#name, 'Parent'));
    expect(args, containsPair(#avatarKey, 'new-avatar'));
    for (final key in [
      #schoolId,
      #gradeId,
      #programId,
      #semesterId,
      #role,
      #idType,
      #studentId,
      #teacherId,
    ]) {
      expect(args[key], isNull);
    }
    expect(result.requiresProfileRefresh, isTrue);
    expect(result.profileToActivate, isNull);
  });

  test('updates student metadata without overwriting an empty name', () async {
    await service.save(
      const SettingsProfileDraft(
        user: LoginUser(id: 7, role: 'PARENT'),
        name: ' ',
        hasProfiles: true,
        editingProfile: StudentProfile(
          profileId: 19,
          role: 'STUDENT',
          isDefault: true,
          dob: '2020-01-02T08:00:00',
        ),
        schoolId: 1,
        gradeId: 2,
        programId: 3,
        semesterId: 4,
        avatarKey: 'new-avatar',
        identifier: ' new-student-id ',
      ),
    );
    final args = profiles.calls.single.namedArguments;
    expect(args, containsPair(#name, null));
    expect(args, containsPair(#role, 'STUDENT'));
    expect(args, containsPair(#schoolId, 1));
    expect(args, containsPair(#gradeId, 2));
    expect(args, containsPair(#programId, 3));
    expect(args, containsPair(#semesterId, 4));
    expect(args, containsPair(#isDefault, true));
    expect(args, containsPair(#dob, '2020-01-02'));
    expect(args, containsPair(#studentId, 'new-student-id'));
  });

  test(
    'validation rejects invalid drafts without calling persistence',
    () async {
      final cases = <(SettingsProfileDraft, String)>[
        (
          const SettingsProfileDraft(
            user: null,
            name: 'Name',
            hasProfiles: false,
          ),
          AppKeys.missingAccount,
        ),
        (
          const SettingsProfileDraft(
            user: LoginUser(id: 7),
            name: ' ',
            hasProfiles: false,
          ),
          AppKeys.missingProfileName,
        ),
        (
          const SettingsProfileDraft(
            user: LoginUser(id: 7),
            name: 'Name',
            hasProfiles: false,
          ),
          AppKeys.missingProfileSelections,
        ),
        (
          const SettingsProfileDraft(
            user: LoginUser(id: 7),
            name: 'Name',
            hasProfiles: false,
            schoolId: 1,
            gradeId: 2,
            programId: 3,
          ),
          AppKeys.missingProfileSelections,
        ),
        (
          const SettingsProfileDraft(
            user: LoginUser(id: 7, role: 'TEACHER'),
            name: 'Name',
            hasProfiles: false,
            schoolId: 1,
            identifier: 'ID',
          ),
          AppKeys.missingProfileSelections,
        ),
        (
          const SettingsProfileDraft(
            user: LoginUser(id: 7),
            name: 'Name',
            hasProfiles: true,
            editingProfile: StudentProfile(role: 'PARENT'),
          ),
          AppKeys.missingProfileId,
        ),
      ];
      for (final (draft, errorKey) in cases) {
        await expectLater(
          service.save(draft),
          throwsA(
            isA<SettingsProfileValidationException>().having(
              (error) => error.errorKey,
              'errorKey',
              errorKey,
            ),
          ),
        );
      }
      expect(profiles.calls, isEmpty);
    },
  );

  test('retains the save-button readiness rules for each role', () {
    const student = SettingsProfileDraft(
      user: LoginUser(id: 7),
      name: 'Student',
      hasProfiles: false,
      schoolId: 1,
      gradeId: 2,
      programId: 3,
    );
    expect(student.canSave, isTrue);
    expect(student.validationErrorKey, AppKeys.missingProfileSelections);
    expect(
      const SettingsProfileDraft(
        user: LoginUser(id: 7, role: 'TEACHER'),
        name: 'Teacher',
        hasProfiles: false,
        schoolId: 1,
      ).canSave,
      isTrue,
    );
    expect(
      const SettingsProfileDraft(
        user: LoginUser(id: 7),
        name: 'Parent',
        hasProfiles: true,
        editingProfile: StudentProfile(profileId: 19, role: 'PARENT'),
      ).canSave,
      isTrue,
    );
  });

  test('persistence errors retain their server message', () async {
    const error = ProfileException('Profile update rejected', status: 409);
    profiles.saveError = error;
    await expectLater(
      service.save(
        const SettingsProfileDraft(
          user: LoginUser(id: 7),
          name: 'Parent',
          hasProfiles: true,
          editingProfile: StudentProfile(profileId: 19, role: 'PARENT'),
        ),
      ),
      throwsA(same(error)),
    );
  });

  testWidgets('form activates a newly created student before reporting saved', (
    tester,
  ) async {
    final events = <String>[];
    await _pumpForm(
      tester,
      profiles,
      grades,
      schools,
      onActivate: (profile) async => events.add('activate:${profile.stableId}'),
      onRefresh: () async => events.add('refresh'),
      onSaved: () => events.add('saved'),
    );
    var panel = tester.widget<AddProfilePanel>(find.byType(AddProfilePanel));
    expect(panel.schools.single.schoolId, 1);
    panel.nameController.text = 'Student';
    panel.onSchoolChanged(panel.schools.single);
    panel.onGradeChanged(panel.grades.single);
    panel.onProgramChanged(panel.programs.single);
    await tester.pump();
    panel = tester.widget<AddProfilePanel>(find.byType(AddProfilePanel));
    expect(panel.canSave, isTrue);
    panel.onSave();
    await tester.pumpAndSettle();
    expect(events, ['activate:91', 'saved']);
    expect(profiles.calls.single.memberName, #createProfile);
    expect(profiles.calls.single.namedArguments, containsPair(#semesterId, 4));
    expect(
      tester.widget<AddProfilePanel>(find.byType(AddProfilePanel)).isSaving,
      isFalse,
    );
  });

  testWidgets('parent edit waits for profile refresh before reporting saved', (
    tester,
  ) async {
    final events = <String>[];
    final refresh = Completer<void>();
    await _pumpForm(
      tester,
      profiles,
      grades,
      schools,
      editingProfile: const StudentProfile(
        profileId: 19,
        role: 'PARENT',
        name: 'Parent',
      ),
      onActivate: (_) async => events.add('activate'),
      onRefresh: () {
        events.add('refresh');
        return refresh.future;
      },
      onSaved: () => events.add('saved'),
    );
    expect(schools.calls, 0);
    final panel = tester.widget<AddProfilePanel>(find.byType(AddProfilePanel));
    panel.nameController.text = 'Updated parent';
    panel.onSave();
    await tester.pump();
    expect(events, ['refresh']);
    expect(
      tester.widget<AddProfilePanel>(find.byType(AddProfilePanel)).isSaving,
      isTrue,
    );
    refresh.complete();
    await tester.pumpAndSettle();
    expect(events, ['refresh', 'saved']);
    expect(profiles.calls.single.memberName, #updateProfile);
    expect(
      profiles.calls.single.namedArguments,
      containsPair(#name, 'Updated parent'),
    );
    expect(
      tester.widget<AddProfilePanel>(find.byType(AddProfilePanel)).isSaving,
      isFalse,
    );
  });

  testWidgets(
    'failed save displays the API message and leaves the form editable',
    (tester) async {
      profiles.saveError = const ProfileException(
        'Server rejected the profile',
      );
      var saves = 0;
      await _pumpForm(
        tester,
        profiles,
        grades,
        schools,
        editingProfile: const StudentProfile(
          profileId: 19,
          role: 'PARENT',
          name: 'Parent',
        ),
        onSaved: () => saves++,
      );
      tester.widget<AddProfilePanel>(find.byType(AddProfilePanel)).onSave();
      await tester.pumpAndSettle();
      final panel = tester.widget<AddProfilePanel>(
        find.byType(AddProfilePanel),
      );
      expect(panel.errorMessage, 'Server rejected the profile');
      expect(panel.isSaving, isFalse);
      expect(panel.canSave, isTrue);
      expect(saves, 0);
    },
  );
}

Future<void> _pumpForm(
  WidgetTester tester,
  _Profiles profiles,
  _Grades grades,
  _Schools schools, {
  StudentProfile? editingProfile,
  Future<void> Function(StudentProfile)? onActivate,
  Future<void> Function()? onRefresh,
  VoidCallback? onSaved,
}) async {
  final lingo = LingoProvider();
  addTearDown(lingo.dispose);
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProfileService>.value(value: profiles),
        RepositoryProvider<GradeService>.value(value: grades),
        RepositoryProvider<SchoolService>.value(value: schools),
        RepositoryProvider<PasscodeService>.value(value: _Passcodes()),
      ],
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SettingTab.page(
              user: const LoginUser(id: 7, role: 'PARENT'),
              profiles: editingProfile == null ? const [] : [editingProfile],
              activeProfile: editingProfile,
              profileLoadError: null,
              onLogout: () {},
              onActivateProfile: onActivate ?? (_) async {},
              onRefreshProfiles: onRefresh,
              onProfileSaved: onSaved,
              bottomPadding: 0,
              initialView: SettingPageView.addProfile,
              initialEditingProfile: editingProfile,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _Passcodes implements PasscodeService {
  @override
  Future<bool> hasPasscode(int userId) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profiles implements ProfileService {
  Future<List<ProgramModel>>? programs;
  Future<List<SemesterModel>>? semesters;
  final programUsers = <int>[];
  final semesterUsers = <int>[];
  final calls = <Invocation>[];
  StudentProfile? savedProfile = const StudentProfile(profileId: 91);
  Object? saveError;

  @override
  Future<List<ProgramModel>> listPrograms({required int userId}) {
    programUsers.add(userId);
    return programs ?? Future.value(const [ProgramModel(programId: 3)]);
  }

  @override
  Future<List<SemesterModel>> listSemesters({required int userId}) {
    semesterUsers.add(userId);
    return semesters ?? Future.value(const [SemesterModel(semesterId: 4)]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #createProfile ||
        invocation.memberName == #updateProfile) {
      calls.add(invocation);
      final error = saveError;
      return error == null
          ? Future<StudentProfile?>.value(savedProfile)
          : Future<StudentProfile?>.error(error);
    }
    return super.noSuchMethod(invocation);
  }
}

class _Grades implements GradeService {
  Future<List<GradeModel>>? result;
  final users = <int>[];

  @override
  Future<List<GradeModel>> listGrades({required int userId}) {
    users.add(userId);
    return result ?? Future.value(const [GradeModel(gradeId: 2)]);
  }
}

class _Schools implements SchoolService {
  Future<List<SchoolModel>>? result;
  int calls = 0;

  @override
  Future<List<SchoolModel>> listSchools() {
    calls++;
    return result ?? Future.value(const [SchoolModel(schoolId: 1)]);
  }
}
