import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/models/exam.dart';

enum ActiveAssessmentDialogAction { canceled, resume }

class ActiveAssessmentDialogResult {
  const ActiveAssessmentDialogResult.canceled()
    : action = ActiveAssessmentDialogAction.canceled,
      exam = null;

  const ActiveAssessmentDialogResult.resume(GeneratedExam this.exam)
    : action = ActiveAssessmentDialogAction.resume;

  final ActiveAssessmentDialogAction action;
  final GeneratedExam? exam;
}

Future<ActiveAssessmentDialogResult?> showActiveAssessmentDialog(
  BuildContext context, {
  required Future<void> Function() onCancel,
  required Future<GeneratedExam> Function() onContinue,
}) {
  return showDialog<ActiveAssessmentDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _ActiveAssessmentDialog(onCancel: onCancel, onContinue: onContinue),
  );
}

class _ActiveAssessmentDialog extends StatefulWidget {
  const _ActiveAssessmentDialog({
    required this.onCancel,
    required this.onContinue,
  });

  final Future<void> Function() onCancel;
  final Future<GeneratedExam> Function() onContinue;

  @override
  State<_ActiveAssessmentDialog> createState() =>
      _ActiveAssessmentDialogState();
}

class _ActiveAssessmentDialogState extends State<_ActiveAssessmentDialog> {
  ActiveAssessmentDialogAction? _loadingAction;
  String? _errorMessage;

  bool get _isLoading => _loadingAction != null;

  Future<void> _cancelAssessment() async {
    if (_isLoading) return;
    _startLoading(ActiveAssessmentDialogAction.canceled);
    try {
      await widget.onCancel();
      if (mounted) {
        Navigator.of(
          context,
        ).pop(const ActiveAssessmentDialogResult.canceled());
      }
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _continueAssessment() async {
    if (_isLoading) return;
    _startLoading(ActiveAssessmentDialogAction.resume);
    try {
      final exam = await widget.onContinue();
      if (mounted) {
        Navigator.of(context).pop(ActiveAssessmentDialogResult.resume(exam));
      }
    } catch (error) {
      _showError(error);
    }
  }

  void _startLoading(ActiveAssessmentDialogAction action) {
    setState(() {
      _loadingAction = action;
      _errorMessage = null;
    });
  }

  void _showError(Object error) {
    if (!mounted) return;
    setState(() {
      _loadingAction = null;
      _errorMessage = error is ExamException
          ? error.message
          : context.getText(AppKeys.examDetailLoadFailed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return PopScope<void>(
      canPop: !_isLoading,
      child: AlertDialog(
        key: const ValueKey('active-assessment-dialog'),
        backgroundColor: colors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(16, 12, 10, 0),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            key: const ValueKey('active-assessment-dialog-close'),
            tooltip: context.getText(AppKeys.close),
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: colors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 148,
                child: Image.asset(
                  'assets/images/assessment-active-mascot.png',
                  fit: BoxFit.contain,
                  cacheWidth: 360,
                  cacheHeight: 360,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentStrong.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      context.getText(AppKeys.parentAssessmentActiveBadge),
                      style: TextStyle(
                        color: colors.accentStrong,
                        fontSize: FontSize.xxs,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.getText(AppKeys.parentAssessmentResumeTitle),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                context.getText(AppKeys.parentAssessmentResumeMessage),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: FontSize.small,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              if (_errorMessage case final message?) ...[
                const SizedBox(height: 10),
                Text(
                  message,
                  key: const ValueKey('active-assessment-dialog-error'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.error,
                    fontSize: FontSize.xxs,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      key: const ValueKey('active-assessment-cancel'),
                      label: context.getText(
                        AppKeys.parentAssessmentCancelActive,
                      ),
                      color: colors.textSecondary,
                      outlined: true,
                      isLoading:
                          _loadingAction ==
                          ActiveAssessmentDialogAction.canceled,
                      onPressed: _isLoading ? null : _cancelAssessment,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogButton(
                      key: const ValueKey('active-assessment-continue'),
                      label: context.getText(AppKeys.continueLabel),
                      color: colors.accentStrong,
                      icon: Icons.arrow_forward_rounded,
                      isLoading:
                          _loadingAction == ActiveAssessmentDialogAction.resume,
                      onPressed: _isLoading ? null : _continueAssessment,
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

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    super.key,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final child = isLoading
        ? SizedBox.square(
            dimension: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? color : colors.onAccent,
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: FontSize.xs,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (icon case final buttonIcon?) ...[
                  const SizedBox(width: 5),
                  Icon(buttonIcon, size: 17),
                ],
              ],
            ),
          );

    return SizedBox(
      height: 44,
      child: outlined
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                side: BorderSide(color: colors.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: onPressed,
              child: child,
            )
          : FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: colors.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}
