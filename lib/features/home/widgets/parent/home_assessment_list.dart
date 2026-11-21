import 'package:material_ui/material_ui.dart';

import 'animated_home_assessment_items.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_active_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_list_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_pagination.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_state_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';

class HomeAssessmentList extends StatefulWidget {
  const HomeAssessmentList({
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
  State<HomeAssessmentList> createState() => _HomeAssessmentListState();
}

class _HomeAssessmentListState extends State<HomeAssessmentList> {
  static const _pageSize = 5;

  int _page = 1;
  late bool _hasLoaded;

  @override
  void initState() {
    super.initState();
    _hasLoaded =
        !widget.isLoading ||
        widget.assessments.isNotEmpty ||
        widget.activeAssessment != null;
  }

  @override
  void didUpdateWidget(covariant HomeAssessmentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading) _hasLoaded = true;
  }

  String _examKey(GeneratedExam exam) =>
      '${exam.examType}:${exam.userExamId ?? exam.examId ?? exam.userAiExamId ?? exam.id ?? '${exam.createDt}:${exam.title}'}';

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
        if (widget.isLoading && !_hasLoaded)
          const ParentAssessmentListSkeleton()
        else ...[
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
            ),
          AnimatedHomeAssessmentItems(
            key: const ValueKey('learning-exam-items'),
            items: [
              if (widget.activeAssessment case final active?)
                Padding(
                  key: ValueKey('learning-active-${_examKey(active)}'),
                  padding: EdgeInsets.only(
                    bottom: widget.assessments.isNotEmpty ? 14 : 0,
                  ),
                  child: ParentAssessmentActiveCard(
                    isLoading: widget.isOpeningActiveAssessment,
                    onTap: widget.onResumeExam,
                  ),
                ),
              for (final exam in visible)
                Padding(
                  key: ValueKey('learning-exam-${_examKey(exam)}'),
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AssessmentResultListItemCard(
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
                ),
            ],
          ),
          if (totalPages > 1)
            ParentAssessmentPagination(
              currentPage: currentPage,
              totalPages: totalPages,
              hasPrevious: currentPage > 1,
              hasNext: currentPage < totalPages,
              isLoading: false,
              onPageSelected: (page) => setState(() => _page = page),
            ),
        ],
      ],
    );
  }
}
