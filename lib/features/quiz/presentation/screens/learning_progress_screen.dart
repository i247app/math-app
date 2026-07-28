import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_quiz_helpers.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_chart.dart';
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

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
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
    final result = await showDialog<_DateFilterResult>(
      context: context,
      barrierColor: context.themeColors.scrim,
      builder: (dialogContext) {
        return _LearningProgressDateFilterDialog(
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

  double _score(ParentAssessmentEntry entry) {
    return ((entry.quiz.grading?.scorePercentage ?? 0) / 10).clamp(0, 10);
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
            titleFontSize: 24,
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
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressFilterControl(
                              icon: Icons.calendar_month_outlined,
                              label: context.getText(
                                AppKeys.learningProgressAllAssessments,
                              ),
                              color: AppColors.textTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProgressFilterControl(
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
                      const SizedBox(height: 18),
                      _ProgressChartCard(
                        entries: entries,
                        onFilter: _showDateFilter,
                      ),
                      const SizedBox(height: 16),
                      _ProgressInsightCard(entries: entries),
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
}

class _DateFilterResult {
  const _DateFilterResult(this.range);

  final DateTimeRange? range;
}

class _LearningProgressDateFilterDialog extends StatefulWidget {
  const _LearningProgressDateFilterDialog({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_LearningProgressDateFilterDialog> createState() =>
      _LearningProgressDateFilterDialogState();
}

class _LearningProgressDateFilterDialogState
    extends State<_LearningProgressDateFilterDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<DateTime?> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: widget.lastDate,
      builder: (pickerContext, child) {
        final theme = Theme.of(pickerContext);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.brandTealSolid,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await _pickDate(
      initialDate: _startDate,
      firstDate: widget.firstDate,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _startDate = picked;
      if (_endDate.isBefore(picked)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await _pickDate(
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final primaryText = Theme.of(context).brightness == Brightness.dark
        ? AppColors.white87
        : AppColors.black87;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      backgroundColor: colors.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 44),
                    child: Text(
                      context.getText(AppKeys.learningProgressFilterTime),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: FontSize.large,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: colors.textSecondary,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ProgressDateField(
                label: context.getText(AppKeys.learningProgressFromDate),
                value: _dateLabel(_startDate),
                onTap: _pickStartDate,
              ),
              const SizedBox(height: 14),
              _ProgressDateField(
                label: context.getText(AppKeys.learningProgressToDate),
                value: _dateLabel(_endDate),
                onTap: _pickEndDate,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      _DateFilterResult(
                        DateTimeRange(start: _startDate, end: _endDate),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandTealSolid,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(
                    context.getText(AppKeys.learningProgressApplyFilter),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(const _DateFilterResult(null));
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textTeal,
                  textStyle: const TextStyle(
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(
                  context.getText(AppKeys.learningProgressClearFilter),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDateField extends StatelessWidget {
  const _ProgressDateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final primaryText = Theme.of(context).brightness == Brightness.dark
        ? AppColors.white87
        : AppColors.black87;
    final radius = BorderRadius.circular(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: primaryText,
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Material(
          color: colors.inputSurface,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.brandTealSolid,
                    size: 21,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    value,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: FontSize.small,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressFilterControl extends StatelessWidget {
  const _ProgressFilterControl({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(14);
    return Material(
      color: colors.elevatedSurface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: FontSize.small,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressChartCard extends StatelessWidget {
  const _ProgressChartCard({required this.entries, required this.onFilter});

  final List<ParentAssessmentEntry> entries;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AppColors.white87 : AppColors.black87;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 14),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.getText(AppKeys.learningProgressScoreTitle),
                            style: TextStyle(
                              color: primaryText,
                              fontSize: FontSize.large,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          Icons.info_outline_rounded,
                          color: colors.textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.formatText(
                        AppKeys.learningProgressAssessmentCount,
                        {'count': entries.length},
                      ),
                      style: const TextStyle(
                        color: AppColors.textTeal,
                        fontSize: FontSize.small,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onFilter,
                icon: const Icon(Icons.tune_rounded, size: 20),
                label: Text(context.getText(AppKeys.learningProgressFilter)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            SizedBox(
              height: 280,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    context.getText(AppKeys.learningProgressNoData),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: FontSize.medium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            LearningProgressChart(entries: entries),
        ],
      ),
    );
  }
}

class _ProgressInsightCard extends StatelessWidget {
  const _ProgressInsightCard({required this.entries});

  final List<ParentAssessmentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trend = _trendFor(entries);
    final titleKey = trend.direction > 0
        ? AppKeys.learningProgressImprovingTitle
        : trend.direction < 0
        ? AppKeys.learningProgressDecliningTitle
        : AppKeys.learningProgressStableTitle;
    final message = trend.direction > 0
        ? context.formatText(AppKeys.learningProgressImprovingMessage, {
            'delta': trend.delta.abs().toStringAsFixed(1),
          })
        : trend.direction < 0
        ? context.formatText(AppKeys.learningProgressDecliningMessage, {
            'delta': trend.delta.abs().toStringAsFixed(1),
          })
        : context.getText(AppKeys.learningProgressStableMessage);
    final accent = isDark ? AppColors.brandTeal : AppColors.textTeal;
    const iconBackground = AppColors.brandTealSolid;
    final icon = trend.direction > 0
        ? Icons.star_rounded
        : trend.direction < 0
        ? Icons.trending_down_rounded
        : Icons.horizontal_rule_rounded;
    final iconColor = trend.direction > 0
        ? (isDark ? AppColors.neonGreen : AppColors.limeGreen)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.getText(titleKey),
                  style: TextStyle(
                    color: accent,
                    fontSize: FontSize.medium,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.brandTeal,
            size: 26,
          ),
        ],
      ),
    );
  }

  ({int direction, double delta}) _trendFor(
    List<ParentAssessmentEntry> entries,
  ) {
    if (entries.length < 2) {
      return (direction: 0, delta: 0);
    }
    final midpoint = math.max(1, entries.length ~/ 2);
    final previous = entries.take(midpoint).map(_score).toList();
    final recent = entries.skip(midpoint).map(_score).toList();
    if (recent.isEmpty) {
      return (direction: 0, delta: 0);
    }
    final previousAverage =
        previous.reduce((value, score) => value + score) / previous.length;
    final recentAverage =
        recent.reduce((value, score) => value + score) / recent.length;
    final delta = recentAverage - previousAverage;
    return (
      direction: delta > 0.05
          ? 1
          : delta < -0.05
          ? -1
          : 0,
      delta: delta,
    );
  }

  double _score(ParentAssessmentEntry entry) {
    return ((entry.quiz.grading?.scorePercentage ?? 0) / 10).clamp(0, 10);
  }
}
