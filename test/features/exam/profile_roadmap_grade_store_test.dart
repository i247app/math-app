import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/data/profile_roadmap_grade_store.dart';

void main() {
  const store = ProfileRoadmapGradeStore();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('new profiles have no selected grade', () async {
    expect(await store.read(11), isNull);
  });

  test(
    'remembers kindergarten and keeps profile selections separate',
    () async {
      await store.save(11, 0);
      await store.save(12, 3);

      expect(await store.read(11), 0);
      expect(await store.read(12), 3);
      expect(await store.read(13), isNull);
    },
  );

  test(
    'restores existing progress including kindergarten level zero',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'profile_grade_progress_v1':
            '{"11":{"grade":0,"level":0},"12":{"grade":4,"level":2}}',
      });

      expect(await store.read(11), 0);
      expect(await store.read(12), 4);
      expect(await store.read(13), isNull);
    },
  );

  test(
    'selected grade overrides progress without changing unlocked levels',
    () async {
      const progressStore = SecureProfileGradeProgressStore();
      await progressStore.save(
        11,
        const ProfileGradeProgress(grade: 4, level: 8),
      );
      await store.save(11, 0);

      expect(await store.read(11), 0);
      final progress = await progressStore.read(11);
      expect(progress.grade, 4);
      expect(progress.level, 8);
      expect(progress.highestUnlockedGrade, 4);
      expect(progress.highestUnlockedLevel, 8);
    },
  );
}
