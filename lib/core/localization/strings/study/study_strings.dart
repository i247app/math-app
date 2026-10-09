import '../../app_keys.dart';

const studyStrings = <String, Map<String, String>>{
  'vi': {
    AppKeys.exercises: 'Bài tập',
    AppKeys.test: 'Kiểm tra',
    AppKeys.searchHint: 'Tìm kiếm ...',
    AppKeys.historyLoadFailed: 'Tải lịch sử thất bại.',
    AppKeys.historyLoadErrorTitle: 'Chưa tải được lịch sử',
    AppKeys.noHistoryTitle: 'Chưa có bài phù hợp',
    AppKeys.noHistoryMessage: 'Đổi từ khóa để xem các bài khác.',
    AppKeys.missingExamId: 'Bài kiểm tra này thiếu exam_id.',
    AppKeys.teacherStudyTitle: 'Học',
    AppKeys.teacherStudyAllClasses: 'Tất cả',
    AppKeys.teacherStudyLoadFailed:
        'Tải danh sách bài tập và đánh giá thất bại.',
    AppKeys.teacherStudyNoResults: 'Không tìm thấy nội dung phù hợp.',
    AppKeys.teacherStudyShowMore: 'Xem thêm {count} bài',
    AppKeys.teacherStudyDueDate: 'Hạn nộp: {date}',
    AppKeys.teacherStudyMonth: 'TH{month}',
    AppKeys.testAgainCreateFailed: 'Không thể tạo bài mới. Vui lòng thử lại.',
    AppKeys.testAgainDialogTitle: 'Tạo bài mới thất bại',
    AppKeys.missingUserOrProfileForHistory:
        'Thiếu user hoặc profile để tải lịch sử.',
    AppKeys.missingExamIdShort: 'Thiếu exam ID.',
  },
  'en': {
    AppKeys.exercises: 'Exercises',
    AppKeys.test: 'Test',
    AppKeys.searchHint: 'Search ...',
    AppKeys.historyLoadFailed: 'Failed to load history.',
    AppKeys.historyLoadErrorTitle: 'Could not load history',
    AppKeys.noHistoryTitle: 'No matching items',
    AppKeys.noHistoryMessage: 'Change the keyword to view other items.',
    AppKeys.missingExamId: 'This test is missing exam_id.',
    AppKeys.teacherStudyTitle: 'Study',
    AppKeys.teacherStudyAllClasses: 'All',
    AppKeys.teacherStudyLoadFailed:
        'Failed to load assignments and assessments.',
    AppKeys.teacherStudyNoResults: 'No matching content found.',
    AppKeys.teacherStudyShowMore: 'Show {count} more',
    AppKeys.teacherStudyDueDate: 'Due: {date}',
    AppKeys.teacherStudyMonth: 'M{month}',
    AppKeys.testAgainCreateFailed:
        'Could not create a new test. Please try again.',
    AppKeys.testAgainDialogTitle: 'New test failed',
    AppKeys.missingUserOrProfileForHistory:
        'Missing user or profile to load history.',
    AppKeys.missingExamIdShort: 'Missing exam ID.',
  },
};
