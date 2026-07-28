import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_chart_card.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_date_filter_dialog.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_filter_control.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_insight_card.dart';
import 'package:numi/shared/layouts/page_header.dart';

class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({super.key, required this.entries});

  final List<ParentAssessmentEntry> entries;

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> {
  DateTimeRange? _dateRange;

  List<ParentAssessmentEntry> get _orderedEntries {
    final entries = List<ParentAssessmentEntry>.of(widget.entries);
    entries.sort((a, b) => quizDate(a.quiz).compareTo(quizDate(b.quiz)));
    return entries;
  }

  List<ParentAssessmentEntry> get _filteredEntries {
    final entries = _orderedEntries;
    final range = _dateRange;
    if (range == null) {
      return entries;
    }
    final start = _startOfDay(range.start);
    final endExclusive = _startOfDay(range.end).add(const Duration(days: 1));
    return entries
        .where((entry) {
          final date = quizDate(entry.quiz).toLocal();
          return !date.isBefore(start) && date.isBefore(endExclusive);
        })
        .toList(growable: false);
  }

  DateTimeRange _initialDialogRange() {
    final selected = _dateRange;
    if (selected != null) {
      return selected;
    }
    final validDates = _orderedEntries
        .map((entry) => quizDate(entry.quiz).toLocal())
        .where((date) => date.millisecondsSinceEpoch != 0)
        .toList(growable: false);
    if (validDates.isNotEmpty) {
      return DateTimeRange(
        start: _startOfDay(validDates.first),
        end: _startOfDay(validDates.last),
      );
    }
    final today = _startOfDay(DateTime.now());
    return DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    );
  }

  Future<void> _showDateFilter() async {
    HapticFeedback.selectionClick();
    final initialRange = _initialDialogRange();
    final today = _startOfDay(DateTime.now());
    final firstDate = initialRange.start.isBefore(DateTime(2000))
        ? initialRange.start
        : DateTime(2000);
    final lastDate = initialRange.end.isAfter(today) ? initialRange.end : today;
    final result = await showDialog<LearningProgressDateFilterResult>(
      context: context,
      barrierColor: context.themeColors.scrim,
      builder: (dialogContext) {
        return LearningProgressDateFilterDialog(
          initialRange: initialRange,
          firstDate: firstDate,
          lastDate: lastDate,
        );
      },
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() => _dateRange = result.range);
  }

  Future<void> _shareProgress() async {
    HapticFeedback.selectionClick();
    final entries = _filteredEntries;
    final average = entries.isEmpty
        ? 0.0
        : entries.map(_score).reduce((value, score) => value + score) /
              entries.length;
    final summary = <String>[
      context.getText(AppKeys.learningProgressTitle),
      context.formatText(AppKeys.learningProgressAssessmentCount, {
        'count': entries.length,
      }),
      if (entries.isNotEmpty)
        context.formatText(AppKeys.learningProgressAverageScore, {
          'score': average.toStringAsFixed(1),
        }),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: summary));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.getText(AppKeys.learningProgressShared)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final entries = _filteredEntries;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: Column(
        children: [
          PageHeader(
            title: context.getText(AppKeys.learningProgressTitle),
            actionWidth: 52,
            horizontalPadding: 12,
            titleFontSize: FontSize.xxxl,
            leading: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: colors.brandStrong,
              tooltip: context.getText(AppKeys.back),
            ),
            trailing: IconButton(
              onPressed: _shareProgress,
              icon: const Icon(Icons.ios_share_rounded),
              color: colors.brandStrong,
              tooltip: context.getText(AppKeys.learningProgressShare),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 18, 16, 24 + bottomInset),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: LearningProgressFilterControl(
                              icon: Icons.calendar_month_outlined,
                              label: context.getText(
                                AppKeys.learningProgressAllAssessments,
                              ),
                              color: AppColors.textTeal,
                            ),
                          ),
                          Expanded(
                            child: LearningProgressFilterControl(
                              icon: Icons.date_range_outlined,
                              label: _dateRange == null
                                  ? context.getText(
                                      AppKeys.learningProgressFilterTime,
                                    )
                                  : '${_dateLabel(_dateRange!.start)} – '
                                        '${_dateLabel(_dateRange!.end)}',
                              color: AppColors.textTeal,
                              onTap: _showDateFilter,
                            ),
                          ),
                        ],
                      ),
                      LearningProgressChartCard(
                        entries: entries,
                        onFilter: _showDateFilter,
                      ),
                      LearningProgressInsightCard(entries: entries),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _score(ParentAssessmentEntry entry) {
    return ((entry.quiz.grading?.scorePercentage ?? 0) / 10).clamp(0, 10);
  }
}
