import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';

void main() {
  const storage = FlutterSecureStorage();
  const store = SecureProfileGradeProgressStore(storage: storage);

  setUp(() {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  test('stores progress independently for each profile', () async {
    await store.saveIfHigher(
      11,
      const ProfileGradeProgress(grade: 2, level: 4),
    );
    await store.saveIfHigher(
      12,
      const ProfileGradeProgress(grade: 5, level: 1),
    );

    expect((await store.read(11)).grade, 2);
    expect((await store.read(11)).level, 4);
    expect((await store.read(12)).grade, 5);
    expect((await store.read(12)).level, 1);
  });

  test('never replaces progress with a lower result', () async {
    await store.saveIfHigher(
      11,
      const ProfileGradeProgress(grade: 3, level: 7),
    );
    final retained = await store.saveIfHigher(
      11,
      const ProfileGradeProgress(grade: 2, level: 10),
    );

    expect(retained.grade, 3);
    expect(retained.level, 7);
    expect((await store.read(11)).grade, 3);
    expect((await store.read(11)).level, 7);
  });

  test('saves an explicit downgraded result for the profile', () async {
    await store.saveIfHigher(
      11,
      const ProfileGradeProgress(grade: 3, level: 7),
    );
    await store.save(11, const ProfileGradeProgress(grade: 3, level: 6));

    final downgraded = await store.read(11);
    expect(downgraded.grade, 3);
    expect(downgraded.level, 6);
    expect(downgraded.highestUnlockedGrade, 3);
    expect(downgraded.highestUnlockedLevel, 7);
  });

  test('reads legacy progress as the highest unlocked checkpoint', () async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{
      'profile_grade_progress_v1': '{"11":{"grade":2,"level":5}}',
    });

    final progress = await store.read(11);

    expect(progress.highestUnlockedGrade, 2);
    expect(progress.highestUnlockedLevel, 5);
  });
}
