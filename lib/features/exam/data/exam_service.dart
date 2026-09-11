import 'package:numi/features/exam/models/exam.dart';

const examTypeAssessment = 'ASSESSMENT';
const examTypePractice = 'PRACTICE';

abstract interface class ExamService {
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? profileId,
  });

  Future<List<GeneratedExam>> listExams({int? userId, int? profileId});

  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  });

  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  });

  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  });

  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  });

  Future<GeneratedExam> getExamDetail(int examId, {int? profileId});
}

abstract interface class ExamStatsService {
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  });
}
