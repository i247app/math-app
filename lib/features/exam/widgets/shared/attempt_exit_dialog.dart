import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';

const assessmentCanceledStatus = 'CANCEL';
const assessmentActiveStatus = 'ACTIVE';

Future<bool> showAttemptExitDialog(BuildContext context) async {
  return showExitConfirmationDialog(
    context,
    titleKey: AppKeys.attemptExitTitle,
    messageKey: AppKeys.attemptExitMessage,
    stayActionKey: AppKeys.continueUpper,
    exitActionKey: AppKeys.exitUpper,
  );
}

Future<bool> showAssessmentExitDialog(
  BuildContext context, {
  required Future<void> Function(String status) onUpdateStatus,
}) async {
  final shouldExit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AssessmentExitDialog(onUpdateStatus: onUpdateStatus),
  );
  return shouldExit ?? false;
}

class _AssessmentExitDialog extends StatefulWidget {
  const _AssessmentExitDialog({required this.onUpdateStatus});

  final Future<void> Function(String status) onUpdateStatus;

  @override
  State<_AssessmentExitDialog> createState() => _AssessmentExitDialogState();
}

class _AssessmentExitDialogState extends State<_AssessmentExitDialog> {
  String? _updatingStatus;
  String? _errorMessage;

  bool get _isUpdating => _updatingStatus != null;

  Future<void> _updateAndExit(String status) async {
    if (_isUpdating) {
      return;
    }
    setState(() {
      _updatingStatus = status;
      _errorMessage = null;
    });

    try {
      await widget.onUpdateStatus(status);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ExamException catch (error) {
      if (mounted) {
        setState(() {
          _updatingStatus = null;
          _errorMessage = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _updatingStatus = null;
          _errorMessage = context.getText(AppKeys.assessmentStatusUpdateFailed);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textStyles = context.textStyles;

    return PopScope<void>(
      canPop: !_isUpdating,
      child: AlertDialog(
        key: const ValueKey('assessment-exit-dialog'),
        backgroundColor: colors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.getText(AppKeys.assessmentExitTitle),
                  style: textStyles.titleLarge?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('assessment-exit-dialog-close'),
              tooltip: context.getText(AppKeys.close),
              onPressed: _isUpdating
                  ? null
                  : () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close_rounded),
              color: colors.textSecondary,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.getText(AppKeys.assessmentExitMessage),
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _AssessmentExitButton(
                      buttonKey: const ValueKey('assessment-cancel-attempt'),
                      label: context.getText(AppKeys.assessmentCancelAttempt),
                      icon: Icons.delete_outline_rounded,
                      color: colors.error,
                      outlined: true,
                      isLoading: _updatingStatus == assessmentCanceledStatus,
                      onPressed: _isUpdating
                          ? null
                          : () => _updateAndExit(assessmentCanceledStatus),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AssessmentExitButton(
                      buttonKey: const ValueKey('assessment-leave-active'),
                      label: context.getText(AppKeys.assessmentLeaveAttempt),
                      icon: Icons.logout_rounded,
                      color: colors.brandStrong,
                      isLoading: _updatingStatus == assessmentActiveStatus,
                      onPressed: _isUpdating
                          ? null
                          : () => _updateAndExit(assessmentActiveStatus),
                    ),
                  ),
                ],
              ),
              if (_errorMessage case final message?) ...[
                const SizedBox(height: 14),
                Text(
                  message,
                  key: const ValueKey('assessment-exit-dialog-error'),
                  textAlign: TextAlign.center,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentExitButton extends StatelessWidget {
  const _AssessmentExitButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    this.outlined = false,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final buttonChild = isLoading
        ? SizedBox.square(
            dimension: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? color : colors.onBrand,
            ),
          )
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17),
                const SizedBox(width: 5),
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: context.textStyles.labelMedium?.copyWith(
                    fontSize: FontSize.xs,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          );

    return SizedBox(
      height: 42,
      child: outlined
          ? OutlinedButton(
              key: buttonKey,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
              child: buttonChild,
            )
          : FilledButton(
              key: buttonKey,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: colors.onBrand,
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onPressed,
              child: buttonChild,
            ),
    );
  }
}
