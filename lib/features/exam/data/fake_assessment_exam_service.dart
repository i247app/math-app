import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Temporary local assessment data used while AI generation is unavailable.
///
/// The generated attempt and its grading stay local; list and progress reads
/// still use the real service so this wrapper remains isolated to the flow
/// that explicitly opts into it.
class FakeAssessmentExamService implements ExamService {
  FakeAssessmentExamService({required ExamService delegate})
    : _delegate = delegate;

  final ExamService _delegate;
  final Map<int, GeneratedExam> _fakeExams = <int, GeneratedExam>{};
  int _nextExamId = 900000;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String purpose = examPurposeAssessment,
    String typeOfExam = examTypeGeneral,
    String? gradeLabel,
    int? previousExamId,
    List<String>? chapters,
    int? profileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final examId = _nextExamId++;
    final now = DateTime.now().toIso8601String();
    final grade = _gradeFromLabel(gradeLabel);
    final exam = GeneratedExam(
      id: examId,
      examId: examId,
      previousExamId: previousExamId,
      profileId: profileId,
      examStatus: 'IN_PROGRESS',
      purpose: purpose,
      type: purpose,
      typeOfExam: typeOfExam,
      title: 'Đánh giá Toán học',
      shortText: 'Bài đánh giá mẫu',
      createDt: now,
      modifyDt: now,
      grade: grade,
      level: grade,
      numQuestions: _questions.length,
      startedDt: now,
      questions: _questions,
    );
    _fakeExams[examId] = exam;
    return exam;
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    final source = _fakeExams[examId];
    if (source == null) {
      return _delegate.submitExam(
        examId: examId,
        answers: answers,
        profileId: profileId,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));
    final correctNumber = _correctAnswerCount(source.questions, answers);
    final totalQuestions = source.questions.length;
    final scorePercentage = totalQuestions == 0
        ? 0
        : (correctNumber * 100 / totalQuestions).round();
    final submittedAt = DateTime.now().toIso8601String();
    final submitted = GeneratedExam(
      id: source.id,
      examId: source.examId,
      previousExamId: source.previousExamId,
      profileId: profileId ?? source.profileId,
      examStatus: 'SUBMITTED',
      purpose: source.purpose,
      typeOfExam: source.typeOfExam,
      type: source.type,
      title: source.title,
      shortText: source.shortText,
      userId: source.userId,
      createDt: source.createDt,
      modifyDt: submittedAt,
      aiExamId: source.aiExamId,
      userAiExamId: source.userAiExamId,
      grade: source.grade,
      level: source.level,
      numQuestions: source.numQuestions,
      startedDt: source.startedDt,
      submittedDt: submittedAt,
      grading: ExamGrading(
        aiDetectGrade: source.grade == null ? null : 'Lớp ${source.grade}',
        aiReview: _reviewForScore(scorePercentage),
        correctNumber: correctNumber,
        scorePercentage: scorePercentage,
        totalQuestions: totalQuestions,
      ),
      answers: List<SubmitExamAnswer>.unmodifiable(answers),
      questions: source.questions,
    );
    _fakeExams[examId] = submitted;
    return submitted;
  }

  @override
  Future<GeneratedExam> getExamDetail(int examId, {int? profileId}) {
    final fakeExam = _fakeExams[examId];
    return fakeExam != null
        ? Future<GeneratedExam>.value(fakeExam)
        : _delegate.getExamDetail(examId, profileId: profileId);
  }

  @override
  Future<List<GeneratedExam>> listExams({int? userId, int? profileId}) {
    return _delegate.listExams(userId: userId, profileId: profileId);
  }

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) {
    return _delegate.listExamPage(
      userId: userId,
      profileId: profileId,
      page: page,
      size: size,
      takeAll: takeAll,
    );
  }

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
  }) {
    return _delegate.getExamProgress(
      profileId: profileId,
      fromDt: fromDt,
      toDt: toDt,
    );
  }
}

int _correctAnswerCount(
  List<ExamQuestion> questions,
  List<SubmitExamAnswer> answers,
) {
  final answerByQuestion = <int, String>{
    for (final answer in answers)
      answer.questionNumber: answer.label.trim().toUpperCase(),
  };
  return questions.where((question) {
    final selected = answerByQuestion[question.questionNumber];
    final correct = question.rightAnswer?.trim().toUpperCase();
    return selected != null && correct != null && selected == correct;
  }).length;
}

int? _gradeFromLabel(String? label) {
  final match = RegExp(r'\d+').firstMatch(label?.trim() ?? '');
  return int.tryParse(match?.group(0) ?? '');
}

String _reviewForScore(int scorePercentage) {
  if (scorePercentage >= 80) {
    return 'Con làm rất tốt! Hãy tiếp tục phát huy nhé.';
  }
  if (scorePercentage >= 50) {
    return 'Con đã nắm được phần lớn kiến thức. Hãy luyện thêm một chút nhé.';
  }
  return 'Con hãy ôn lại các dạng bài và thử sức thêm lần nữa nhé.';
}

const _questions = <ExamQuestion>[
  ExamQuestion(
    questionName: '12 + 8 = ?',
    questionNumber: 1,
    rightAnswer: 'C',
    topic: 'Phép cộng',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '18'),
      ExamAnswer(label: 'B', content: '19'),
      ExamAnswer(label: 'C', content: '20'),
      ExamAnswer(label: 'D', content: '21'),
    ],
  ),
  ExamQuestion(
    questionName: '35 - 17 = ?',
    questionNumber: 2,
    rightAnswer: 'B',
    topic: 'Phép trừ',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '16'),
      ExamAnswer(label: 'B', content: '18'),
      ExamAnswer(label: 'C', content: '20'),
      ExamAnswer(label: 'D', content: '22'),
    ],
  ),
  ExamQuestion(
    questionName: '6 × 7 = ?',
    questionNumber: 3,
    rightAnswer: 'D',
    topic: 'Phép nhân',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '36'),
      ExamAnswer(label: 'B', content: '40'),
      ExamAnswer(label: 'C', content: '41'),
      ExamAnswer(label: 'D', content: '42'),
    ],
  ),
  ExamQuestion(
    questionName: '48 ÷ 6 = ?',
    questionNumber: 4,
    rightAnswer: 'A',
    topic: 'Phép chia',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '8'),
      ExamAnswer(label: 'B', content: '7'),
      ExamAnswer(label: 'C', content: '6'),
      ExamAnswer(label: 'D', content: '9'),
    ],
  ),
  ExamQuestion(
    questionName: 'Số nào lớn nhất?',
    questionNumber: 5,
    rightAnswer: 'C',
    topic: 'So sánh số',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '129'),
      ExamAnswer(label: 'B', content: '192'),
      ExamAnswer(label: 'C', content: '219'),
      ExamAnswer(label: 'D', content: '209'),
    ],
  ),
  ExamQuestion(
    questionName: 'Một hình vuông có cạnh 5 cm. Chu vi bằng bao nhiêu?',
    questionNumber: 6,
    rightAnswer: 'B',
    topic: 'Hình học',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '10 cm'),
      ExamAnswer(label: 'B', content: '20 cm'),
      ExamAnswer(label: 'C', content: '25 cm'),
      ExamAnswer(label: 'D', content: '15 cm'),
    ],
  ),
  ExamQuestion(
    questionName: 'Một giờ có bao nhiêu phút?',
    questionNumber: 7,
    rightAnswer: 'D',
    topic: 'Thời gian',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '30 phút'),
      ExamAnswer(label: 'B', content: '45 phút'),
      ExamAnswer(label: 'C', content: '50 phút'),
      ExamAnswer(label: 'D', content: '60 phút'),
    ],
  ),
  ExamQuestion(
    questionName: '1 mét bằng bao nhiêu xăng-ti-mét?',
    questionNumber: 8,
    rightAnswer: 'C',
    topic: 'Đo độ dài',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '10 cm'),
      ExamAnswer(label: 'B', content: '50 cm'),
      ExamAnswer(label: 'C', content: '100 cm'),
      ExamAnswer(label: 'D', content: '1000 cm'),
    ],
  ),
  ExamQuestion(
    questionName: 'Số tiếp theo của dãy 2, 4, 6, 8 là số nào?',
    questionNumber: 9,
    rightAnswer: 'A',
    topic: 'Dãy số',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '10'),
      ExamAnswer(label: 'B', content: '11'),
      ExamAnswer(label: 'C', content: '12'),
      ExamAnswer(label: 'D', content: '14'),
    ],
  ),
  ExamQuestion(
    questionName: 'Có 24 quả cam chia đều vào 4 giỏ. Mỗi giỏ có bao nhiêu quả?',
    questionNumber: 10,
    rightAnswer: 'B',
    topic: 'Bài toán có lời văn',
    answers: <ExamAnswer>[
      ExamAnswer(label: 'A', content: '4 quả'),
      ExamAnswer(label: 'B', content: '6 quả'),
      ExamAnswer(label: 'C', content: '8 quả'),
      ExamAnswer(label: 'D', content: '10 quả'),
    ],
  ),
];
