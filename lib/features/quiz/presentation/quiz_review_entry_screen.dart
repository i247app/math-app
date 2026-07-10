part of 'quiz_review_screen.dart';

/// Quiz-specific route into the shared review-detail layout.
class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.quizId, this.initialQuiz});

  final int quizId;
  final GeneratedQuiz? initialQuiz;

  @override
  Widget build(BuildContext context) {
    return ReviewDetailScreen(
      detailId: quizId,
      detailLoader: QuizApi().getQuizDetail,
      initialDetail: initialQuiz,
    );
  }
}
