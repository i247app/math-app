import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/helpers/parent_assessment_helpers.dart';
import 'package:numi/features/quiz/models/parent_assessment_entry.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_chart_card.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_date_filter_dialog.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_filter_control.dart';
import 'package:numi/features/quiz/widgets/learning_progress/learning_progress_insight_card.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';

class LearningProgressScreen extends StatefulWidget {
  const LearningProgressScreen({
    super.key,
    required this.profileId,
    required this.quizService,
    this.initialEntries = const <ParentAssessmentEntry>[],
  });

  final int? profileId;
  final QuizService quizService;
  final List<ParentAssessmentEntry> initialEntries;

  @override
  State<LearningProgressScreen> createState() => _LearningProgressScreenState();
}

class _LearningProgressScreenState extends State<LearningProgressScreen> {
  DateTimeRange? _dateRange;
  QuizProgressResponse? _progress;
  bool _isLoading = true;
  String? _errorMessage;
  int _requestId = 0;

  List<ParentAssessmentEntry> get _orderedInitialEntries {
    final entries = List<ParentAssessmentEntry>.of(widget.initialEntries);
    entries.sort((a, b) => quizDate(a.quiz).compareTo(quizDate(b.quiz)));
    return entries;
  }

  List<QuizProgressPoint> get _points {
    final points = List<QuizProgressPoint>.of(
      _progress?.series ?? const <QuizProgressPoint>[],
    );
    points.sort((a, b) {
      final sequenceComparison = a.sequence.compareTo(b.sequence);
      return sequenceComparison != 0
          ? sequenceComparison
          : a.completedDt.compareTo(b.completedDt);
    });
    return points;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProgress();
    });
  }

  @override
  void didUpdateWidget(covariant LearningProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileId != widget.profileId ||
        oldWidget.quizService != widget.quizService) {
      _progress = null;
      _loadProgress();
    }
  }

  DateTimeRange _initialDialogRange() {
    final selected = _dateRange;
    if (selected != null) {
      return selected;
    }
    return _defaultRange();
  }

  DateTimeRange _defaultRange() {
    final validDates = _orderedInitialEntries
        .map((entry) => quizDate(entry.quiz).toLocal())
        .where((date) => date.millisecondsSinceEpoch != 0)
        .toList(growable: false);
    final today = _startOfDay(DateTime.now());
    if (validDates.isNotEmpty) {
      return DateTimeRange(
        start: _startOfDay(validDates.first),
        end: validDates.last.isAfter(today)
            ? _startOfDay(validDates.last)
            : today,
      );
    }
    return DateTimeRange(
      start: DateTime(today.year - 1, today.month, today.day),
      end: today,
    );
  }

  Future<void> _loadProgress() async {
    final requestId = ++_requestId;
    final profileId = widget.profileId;
    if (profileId == null || profileId <= 0) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = context.getText(AppKeys.learningProgressLoadFailed);
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final range = _dateRange ?? _defaultRange();
    final fromDt = _startOfDay(range.start);
    final toDt = _startOfDay(
      range.end,
    ).add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    try {
      final progress = await widget.quizService.getQuizProgress(
        profileId: profileId,
        fromDt: fromDt,
        toDt: toDt,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      final message = error.toString().trim();
      setState(() {
        _isLoading = false;
        _errorMessage = message.isEmpty
            ? context.getText(AppKeys.learningProgressLoadFailed)
            : message;
      });
    }
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
    await _loadProgress();
  }

  Future<void> _shareProgress() async {
    HapticFeedback.selectionClick();
    final points = _points;
    final average =
        _progress?.summary?.averageScore ??
        (points.isEmpty
            ? 0.0
            : points.map((point) => point.score).reduce((a, b) => a + b) /
                  points.length);
    final count = _progress?.summary?.count ?? points.length;
    final summary = <String>[
      context.getText(AppKeys.learningProgressTitle),
      context.formatText(AppKeys.learningProgressAssessmentCount, {
        'count': count,
      }),
      if (points.isNotEmpty)
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
    final points = _points;
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
              onPressed: _progress == null ? null : _shareProgress,
              icon: const Icon(Icons.ios_share_rounded),
              color: colors.brandStrong,
              tooltip: context.getText(AppKeys.learningProgressShare),
            ),
          ),
          Expanded(
            child: _isLoading && _progress == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 18, 16, 24 + bottomInset),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 16,
                          children: [
                            if (_isLoading) const LinearProgressIndicator(),
                            if (_errorMessage != null)
                              AppRetryPanel(
                                message: _errorMessage!,
                                onRetry: _loadProgress,
                                filledAction: true,
                              ),
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
                              points: points,
                              entryCount: _progress?.summary?.count,
                              onFilter: _showDateFilter,
                            ),
                            if (points.isNotEmpty)
                              LearningProgressInsightCard(
                                points: points,
                                summary: _progress?.summary,
                              ),
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
}
