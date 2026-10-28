import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

const examTypeAssessment = 'ASSESSMENT';
const examTypePractice = 'PRACTICE';
const examTypeGrade = 'GRADE';

abstract interface class ExamService {
  /// For GRADE, [level] is the progress level (1-10); the API sends 0-9.
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  });

  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  });

  Future<List<ExamStats>> getExamStats({
    required int profileId,
    List<String> examTypes = const [examTypeAssessment],
  });

  Future<GradeLevels> getGradeLevels({
    required int profileId,
    required int grade,
  });

  Future<List<ExamStats>> getGradeRoadmap({
    required int profileId,
    required int grade,
  });

  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  });

  Future<void> updateUserExamStatus({
    int? userExamId,
    required String status,
    int? profileId,
    bool? esessFlag,
  });

  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  });

  Future<ExamStats?> generateExamSessionAiReview({
    required int profileId,
    required int userExamId,
  });
}
