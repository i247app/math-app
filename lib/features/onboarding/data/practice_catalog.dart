class PracticeLesson {
  const PracticeLesson({
    required this.number,
    required this.title,
  });

  final int number;
  final String title;
}

class PracticeChapter {
  const PracticeChapter({
    required this.number,
    required this.title,
    required this.lessons,
    required this.completedLessons,
    required this.icon,
  });

  final int number;
  final String title;
  final List<PracticeLesson> lessons;
  final int completedLessons;
  final String icon;

  int get lessonCount => lessons.length;

  double get progress {
    if (lessons.isEmpty) {
      return 0;
    }
    return completedLessons.clamp(0, lessons.length) / lessons.length;
  }

  bool get isLocked => completedLessons == 0 && number > 2;
}

const gradeOnePracticeChapters = <PracticeChapter>[
  PracticeChapter(
    number: 1,
    title: 'CÁC SỐ ĐẾN 10. HÌNH PHẲNG',
    completedLessons: 17,
    icon: '🏆',
    lessons: [
      PracticeLesson(number: 1, title: 'Các số 1, 2, 3'),
      PracticeLesson(number: 2, title: 'Các số 4, 5, 6'),
      PracticeLesson(number: 3, title: 'Các số 7, 8, 9'),
      PracticeLesson(number: 4, title: 'Số 0'),
      PracticeLesson(number: 5, title: 'Số 10'),
      PracticeLesson(number: 6, title: 'Luyện tập'),
      PracticeLesson(number: 7, title: 'Nhiều hơn - Ít hơn - Bằng nhau'),
      PracticeLesson(
        number: 8,
        title: 'Lớn hơn, dấu > - Bé hơn, dấu < - Bằng nhau, dấu =',
      ),
      PracticeLesson(number: 9, title: 'Luyện tập'),
      PracticeLesson(
        number: 10,
        title: 'Mỗi số lớn hơn hay bé hơn các số còn lại trong nhóm?',
      ),
      PracticeLesson(number: 11, title: 'Thứ tự các số trong phạm vi 10'),
      PracticeLesson(number: 12, title: 'Luyện tập'),
      PracticeLesson(
        number: 13,
        title: 'Hình tròn - Hình tam giác - Hình vuông - Hình chữ nhật',
      ),
      PracticeLesson(number: 14, title: 'Khối lập phương - Khối hộp chữ nhật'),
      PracticeLesson(number: 15, title: 'Thực hành lắp ghép, xếp hình'),
      PracticeLesson(number: 16, title: 'Em vui học Toán'),
      PracticeLesson(number: 17, title: 'Ôn tập chủ đề 1'),
    ],
  ),
  PracticeChapter(
    number: 2,
    title: 'PHÉP CỘNG, PHÉP TRỪ TRONG PHẠM VI 10',
    completedLessons: 8,
    icon: '🎯',
    lessons: [
      PracticeLesson(number: 18, title: 'Phép cộng trong phạm vi 10'),
      PracticeLesson(
          number: 19, title: 'Phép cộng trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 20, title: 'Luyện tập'),
      PracticeLesson(
          number: 21, title: 'Phép cộng trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 22, title: 'Luyện tập'),
      PracticeLesson(
          number: 23, title: 'Phép cộng trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 24, title: 'Luyện tập'),
      PracticeLesson(number: 25, title: 'Bảng cộng trong phạm vi 10'),
      PracticeLesson(number: 26, title: 'Luyện tập'),
      PracticeLesson(number: 27, title: 'Phép trừ trong phạm vi 10'),
      PracticeLesson(
          number: 28, title: 'Phép trừ trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 29, title: 'Luyện tập'),
      PracticeLesson(
          number: 30, title: 'Phép trừ trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 31, title: 'Luyện tập'),
      PracticeLesson(
          number: 32, title: 'Phép trừ trong phạm vi 10 (tiếp theo)'),
      PracticeLesson(number: 33, title: 'Luyện tập'),
      PracticeLesson(number: 34, title: 'Bảng trừ trong phạm vi 10'),
      PracticeLesson(number: 35, title: 'Luyện tập'),
      PracticeLesson(number: 36, title: 'Luyện tập chung'),
      PracticeLesson(number: 37, title: 'Em vui học Toán'),
      PracticeLesson(number: 38, title: 'Ôn tập chủ đề 2'),
    ],
  ),
  PracticeChapter(
    number: 3,
    title: 'CÁC SỐ TRONG PHẠM VI 100. ĐO LƯỜNG',
    completedLessons: 0,
    icon: '🏆',
    lessons: [
      PracticeLesson(number: 39, title: 'Các số từ 11 đến 20'),
      PracticeLesson(
          number: 40, title: 'Ki-lô-mét (Giới thiệu đơn vị đo độ dài: cm)'),
      PracticeLesson(number: 41, title: 'Thực hành đo độ dài'),
      PracticeLesson(number: 42, title: 'Luyện tập'),
      PracticeLesson(number: 43, title: 'Các số tròn chục'),
      PracticeLesson(number: 44, title: 'Luyện tập'),
      PracticeLesson(number: 45, title: 'Các số có hai chữ số (từ 21 đến 70)'),
      PracticeLesson(number: 46, title: 'Các số có hai chữ số (từ 71 đến 99)'),
      PracticeLesson(number: 47, title: 'Các số đến 100'),
      PracticeLesson(number: 48, title: 'Luyện tập'),
      PracticeLesson(number: 49, title: 'Chục và đơn vị'),
      PracticeLesson(number: 50, title: 'Luyện tập'),
      PracticeLesson(number: 51, title: 'So sánh các số trong phạm vi 100'),
      PracticeLesson(number: 52, title: 'Luyện tập'),
      PracticeLesson(number: 53, title: 'Dài hơn - Ngắn hơn'),
      PracticeLesson(number: 54, title: 'Đo độ dài'),
      PracticeLesson(
          number: 55, title: 'Xăng-ti-mét. Đo độ dài theo đơn vị xăng-ti-mét'),
      PracticeLesson(number: 56, title: 'Em vui học Toán'),
      PracticeLesson(number: 57, title: 'Ôn tập chủ đề 3'),
    ],
  ),
  PracticeChapter(
    number: 4,
    title: 'PHÉP CỘNG, PHÉP TRỪ TRONG PHẠM VI 100',
    completedLessons: 0,
    icon: '🔥',
    lessons: [
      PracticeLesson(number: 58, title: 'Phép cộng dạng 14 + 3'),
      PracticeLesson(number: 59, title: 'Phép trừ dạng 17 - 3'),
      PracticeLesson(number: 60, title: 'Luyện tập'),
      PracticeLesson(number: 61, title: 'Cộng các số tròn chục'),
      PracticeLesson(number: 62, title: 'Trừ các số tròn chục'),
      PracticeLesson(number: 63, title: 'Luyện tập'),
      PracticeLesson(number: 64, title: 'Phép cộng dạng 25 + 14'),
      PracticeLesson(number: 65, title: 'Phép trừ dạng 39 - 15'),
      PracticeLesson(number: 66, title: 'Luyện tập'),
      PracticeLesson(number: 67, title: 'Phép cộng dạng 36 + 4, 36 + 24'),
      PracticeLesson(number: 68, title: 'Phép trừ dạng 40 - 4, 40 - 24'),
      PracticeLesson(number: 69, title: 'Luyện tập'),
      PracticeLesson(number: 70, title: 'Luyện tập chung'),
      PracticeLesson(number: 71, title: 'Các ngày trong tuần'),
      PracticeLesson(number: 72, title: 'Đồng hồ - Thời gian'),
      PracticeLesson(number: 73, title: 'Em vui học Toán'),
      PracticeLesson(number: 74, title: 'Ôn tập chủ đề 4'),
      PracticeLesson(number: 75, title: 'Ôn tập các số trong phạm vi 100'),
      PracticeLesson(
          number: 76, title: 'Ôn tập phép cộng, phép trừ trong phạm vi 100'),
      PracticeLesson(number: 77, title: 'Ôn tập về hình học và đo lường'),
      PracticeLesson(number: 78, title: 'Ôn tập chung'),
    ],
  ),
];
