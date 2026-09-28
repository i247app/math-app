import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_active_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';

class NewHomeAssessmentList extends StatefulWidget {
  const NewHomeAssessmentList({
    super.key,
    required this.assessments,
    required this.activeAssessment,
    required this.isLoading,
    required this.isOpeningActiveAssessment,
    required this.errorMessage,
    required this.onOpenExam,
    required this.onResumeExam,
    required this.onRetry,
  });

  final List<GeneratedExam> assessments;
  final GeneratedExam? activeAssessment;
  final bool isLoading;
  final bool isOpeningActiveAssessment;
  final String? errorMessage;
  final ValueChanged<GeneratedExam> onOpenExam;
  final VoidCallback onResumeExam;
  final VoidCallback onRetry;

  @override
  State<NewHomeAssessmentList> createState() => _NewHomeAssessmentListState();
}

class _NewHomeAssessmentListState extends State<NewHomeAssessmentList> {
  static const _pageSize = 5;

  int _page = 1;

  @override
  Widget build(BuildContext context) {
    final totalPages = widget.assessments.isEmpty
        ? 1
        : (widget.assessments.length + _pageSize - 1) ~/ _pageSize;
    final currentPage = _page.clamp(1, totalPages);
    final visible = widget.assessments
        .skip((currentPage - 1) * _pageSize)
        .take(_pageSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isLoading)
          const ParentAssessmentListSkeleton()
        else ...[
          if (widget.activeAssessment != null) ...[
            ParentAssessmentActiveCard(
              isLoading: widget.isOpeningActiveAssessment,
              onTap: widget.onResumeExam,
            ),
            if (widget.assessments.isNotEmpty) const SizedBox(height: 14),
          ],
          if (widget.errorMessage != null &&
              widget.assessments.isEmpty &&
              widget.activeAssessment == null)
            ParentAssessmentStateCard(
              icon: Icons.cloud_off_rounded,
              title: context.getText(AppKeys.historyLoadErrorTitle),
              message: widget.errorMessage!,
              onTap: widget.onRetry,
            )
          else if (widget.assessments.isEmpty &&
              widget.activeAssessment == null)
            ParentAssessmentStateCard(
              icon: Icons.assignment_turned_in_outlined,
              title: context.getText(AppKeys.noHistoryTitle),
              message: context.getText(AppKeys.noHistoryMessage),
              onTap: widget.onRetry,
            )
          else ...[
            for (final exam in visible) ...[
              AssessmentResultListItemCard(
                exam: exam,
                onTap:
                    (exam.userExamId ??
                            exam.examId ??
                            exam.userAiExamId ??
                            exam.id) ==
                        null
                    ? null
                    : () => widget.onOpenExam(exam),
              ),
              const SizedBox(height: 14),
            ],
            if (totalPages > 1)
              ParentAssessmentPagination(
                currentPage: currentPage,
                totalPages: totalPages,
                hasPrevious: currentPage > 1,
                hasNext: currentPage < totalPages,
                isLoading: widget.isLoading,
                onPageSelected: (page) => setState(() => _page = page),
              ),
          ],
        ],
      ],
    );
  }
}
