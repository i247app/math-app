abstract interface class ExamShakeService {
  Future<void> aiShake();
}

class NoopExamShakeService implements ExamShakeService {
  const NoopExamShakeService();

  @override
  Future<void> aiShake() async {}
}
