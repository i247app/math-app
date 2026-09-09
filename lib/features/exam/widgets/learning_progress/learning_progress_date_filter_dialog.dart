import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class LearningProgressDateFilterResult {
  const LearningProgressDateFilterResult(this.range);

  final DateTimeRange? range;
}

class LearningProgressDateFilterDialog extends StatefulWidget {
  const LearningProgressDateFilterDialog({
    super.key,
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<LearningProgressDateFilterDialog> createState() =>
      _LearningProgressDateFilterDialogState();
}

class _LearningProgressDateFilterDialogState
    extends State<LearningProgressDateFilterDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;
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
            spacing: 14,
            children: [
              _DialogHeader(
                title: context.getText(AppKeys.learningProgressFilterTime),
              ),
              _ProgressDateField(
                label: context.getText(AppKeys.learningProgressFromDate),
                value: _dateLabel(_startDate),
                onTap: _pickStartDate,
              ),
              _ProgressDateField(
                label: context.getText(AppKeys.learningProgressToDate),
                value: _dateLabel(_endDate),
                onTap: _pickEndDate,
              ),
              Column(
                spacing: 4,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      LearningProgressDateFilterResult(
                        DateTimeRange(start: _startDate, end: _endDate),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
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
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const LearningProgressDateFilterResult(null)),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
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
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ),
      ],
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
    final radius = BorderRadius.circular(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 7,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: FontSize.caption,
            fontWeight: FontWeight.w700,
          ),
        ),
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
                spacing: 12,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.brandTealSolid,
                    size: 21,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textPrimary,
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

String _dateLabel(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
