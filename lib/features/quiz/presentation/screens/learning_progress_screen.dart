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

enum LearningProgressPeriod { all, last30Days, last90Days }

class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({super.key, required this.entries});

  final List<ParentAssessmentEntry> entries;

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> {
  LearningProgressPeriod _period = LearningProgressPeriod.all;

  List<ParentAssessmentEntry> get _orderedEntries {
    final entries = List<ParentAssessmentEntry>.of(widget.entries);
    entries.sort((a, b) => quizDate(a.quiz).compareTo(quizDate(b.quiz)));
    return entries;
  }

  List<ParentAssessmentEntry> get _filteredEntries {
    final entries = _orderedEntries;
    final days = switch (_period) {
      LearningProgressPeriod.all => null,
      LearningProgressPeriod.last30Days => 30,
      LearningProgressPeriod.last90Days => 90,
    };
    if (days == null) {
      return entries;
    }
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries
        .where((entry) => !quizDate(entry.quiz).isBefore(cutoff))
        .toList(growable: false);
  }

  String _periodLabel(BuildContext context, LearningProgressPeriod period) {
    final key = switch (period) {
      LearningProgressPeriod.all => AppKeys.learningProgressPeriodAll,
      LearningProgressPeriod.last30Days => AppKeys.learningProgressPeriod30Days,
      LearningProgressPeriod.last90Days => AppKeys.learningProgressPeriod90Days,
    };
    return context.getText(key);
  }

  Future<void> _choosePeriod() async {
    HapticFeedback.selectionClick();
    final selected = await showModalBottomSheet<LearningProgressPeriod>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.themeColors.elevatedSurface,
      builder: (sheetContext) {
        final colors = sheetContext.themeColors;
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final period in LearningProgressPeriod.values)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Icon(
                    period == _period
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: period == _period
                        ? AppColors.brandTeal
                        : colors.textMuted,
                  ),
                  title: Text(
                    _periodLabel(sheetContext, period),
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: period == _period
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(period),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null || selected == _period) {
      return;
    }
    setState(() => _period = selected);
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
                              label: _period == LearningProgressPeriod.all
                                  ? context.getText(
                                      AppKeys.learningProgressFilterTime,
                                    )
                                  : _periodLabel(context, _period),
                              color: AppColors.textTeal,
                              onTap: _choosePeriod,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _ProgressChartCard(
                        entries: entries,
                        onFilter: _choosePeriod,
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
