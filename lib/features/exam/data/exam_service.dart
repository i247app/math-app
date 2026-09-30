import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

const examTypeAssessment = 'ASSESSMENT';
const examTypePractice = 'PRACTICE';
const examTypeGrade = 'GRADE';
// Passing this to getExamStats omits exam_type from the request.
const examTypeAll = '';

abstract interface class ExamService {
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
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
    String examType = examTypeAssessment,
  });

  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  });

  Future<GradeLevels> getGradeLevels({
    required int profileId,
    required int grade,
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

  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  });
}
