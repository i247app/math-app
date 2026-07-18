import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/quiz/widgets/history_detail/history_open_homework_result.dart';
import 'package:numi/features/quiz/widgets/history_detail/history_open_quiz_review.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_filter.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_homework_card.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_loading_state.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_message_state.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_quiz_card.dart';

class HistoryBody extends StatelessWidget {
  const HistoryBody({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedFilter,
    required this.selectedItemsCount,
    required this.quizzes,
    required this.homeworkExercises,
    required this.profileId,
    required this.exerciseService,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final HistoryFilter selectedFilter;
  final int selectedItemsCount;
  final List<GeneratedQuiz> quizzes;
  final List<ClassroomExercise> homeworkExercises;
  final int? profileId;
  final ClassroomExerciseService exerciseService;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && selectedItemsCount == 0) {
      return const HistoryLoadingState();
    }

    if (errorMessage != null && selectedItemsCount == 0) {
      return HistoryMessageState(
        icon: Icons.cloud_off_rounded,
        title: context.getText(AppKeys.historyLoadErrorTitle),
        subtitle: errorMessage!,
        actionLabel: context.getText(AppKeys.retry).toUpperCase(),
        onAction: onRetry,
      );
    }

    if (selectedItemsCount == 0) {
      return HistoryMessageState(
        icon: Icons.history_toggle_off_rounded,
        title: context.getText(AppKeys.noHistoryTitle),
        subtitle: context.getText(AppKeys.noHistoryMessage),
      );
    }

    return switch (selectedFilter) {
      HistoryFilter.homework => Column(
        spacing: 14,
        children: homeworkExercises
            .map(
              (exercise) => HistoryHomeworkCard(
                exercise: exercise,
                onTap: () => historyOpenHomeworkResult(
                  context,
                  exercise,
                  profileId: profileId,
                  exerciseService: exerciseService,
                ),
              ),
            )
            .toList(growable: false),
      ),
      HistoryFilter.assessment => Column(
        spacing: 14,
        children: quizzes
            .map(
              (quiz) => HistoryQuizCard(
                quiz: quiz,
                onTap: () => historyOpenQuizReview(context, quiz),
              ),
            )
            .toList(growable: false),
      ),
    };
  }
}
