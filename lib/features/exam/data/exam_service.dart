import 'package:numi/features/exam/models/exam.dart';

const examPurposeAssessment = 'ASSESSMENT';
const examPurposePractice = 'PRACTICE';
const examTypeGeneral = 'GENERAL';
const examTypeReinforcement = 'REINFORCEMENT';
const assessmentExamType = examPurposeAssessment;

abstract interface class ExamService {
  Future<GeneratedExam> generateAssessmentExam({
    String purpose = examPurposeAssessment,
    String typeOfExam = examTypeGeneral,
    String? gradeLabel,
    int? previousExamId,
    List<String>? chapters,
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

  Future<GeneratedExam> getExamDetail(int examId, {int? profileId});
}

abstract interface class ExamStatsService {
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examPurposeAssessment,
  });
}
