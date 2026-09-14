import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PendingAssessmentCompletion {
  const PendingAssessmentCompletion({
    required this.userExamId,
    required this.profileId,
  });

  final int userExamId;
  final int profileId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user_exam_id': userExamId,
    'profile_id': profileId,
  };

  static PendingAssessmentCompletion? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final userExamId = _positiveInt(value['user_exam_id']);
    final profileId = _positiveInt(value['profile_id']);
    if (userExamId == null || profileId == null) {
      return null;
    }
    return PendingAssessmentCompletion(
      userExamId: userExamId,
      profileId: profileId,
    );
  }
}

abstract interface class PendingAssessmentCompletionStore {
  Future<List<PendingAssessmentCompletion>> readAll();

  Future<void> markPending({required int userExamId, required int profileId});

  Future<void> remove(int userExamId);
}

class SecurePendingAssessmentCompletionStore
    implements PendingAssessmentCompletionStore {
  const SecurePendingAssessmentCompletionStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _storageKey = 'pending_assessment_completions_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<PendingAssessmentCompletion>> readAll() async {
    final encoded = await _storage.read(key: _storageKey);
    if (encoded == null || encoded.trim().isEmpty) {
      return const <PendingAssessmentCompletion>[];
    }
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        return const <PendingAssessmentCompletion>[];
      }
      return decoded
          .map(PendingAssessmentCompletion.fromJson)
          .whereType<PendingAssessmentCompletion>()
          .toList(growable: false);
    } on FormatException {
      return const <PendingAssessmentCompletion>[];
    }
  }

  @override
  Future<void> markPending({
    required int userExamId,
    required int profileId,
  }) async {
    if (userExamId <= 0 || profileId <= 0) {
      return;
    }
    final pending = await readAll();
    final updated = <PendingAssessmentCompletion>[
      for (final item in pending)
        if (item.userExamId != userExamId) item,
      PendingAssessmentCompletion(userExamId: userExamId, profileId: profileId),
    ];
    await _write(updated);
  }

  @override
  Future<void> remove(int userExamId) async {
    if (userExamId <= 0) {
      return;
    }
    final pending = await readAll();
    final updated = pending
        .where((item) => item.userExamId != userExamId)
        .toList(growable: false);
    if (updated.length == pending.length) {
      return;
    }
    await _write(updated);
  }

  Future<void> _write(List<PendingAssessmentCompletion> pending) async {
    if (pending.isEmpty) {
      await _storage.delete(key: _storageKey);
      return;
    }
    await _storage.write(
      key: _storageKey,
      value: jsonEncode(pending.map((item) => item.toJson()).toList()),
    );
  }
}

int? _positiveInt(Object? value) {
  final parsed = value is int
      ? value
      : value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '');
  return parsed != null && parsed > 0 ? parsed : null;
}
