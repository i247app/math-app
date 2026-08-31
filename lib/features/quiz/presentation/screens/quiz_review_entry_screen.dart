import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/quiz/data/dto/quiz_models.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/presentation/screens/quiz_review_screen.dart';

/// Quiz-specific route into the shared review-detail layout.
class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.quizId, this.initialQuiz});

  final int quizId;
  final GeneratedQuiz? initialQuiz;

  @override
  Widget build(BuildContext context) {
    return ReviewDetailScreen(
      detailId: quizId,
      detailLoader: context.read<QuizService>().getQuizDetail,
      initialDetail: initialQuiz,
    );
  }
}
