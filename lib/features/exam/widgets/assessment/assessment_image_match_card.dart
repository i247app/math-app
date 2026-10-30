import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/models/exam.dart';

import 'assessment_question_speaker.dart';

/// A single-choice question presented as a number-to-picture connection.
class AssessmentImageMatchCard extends StatelessWidget {
  const AssessmentImageMatchCard({
    super.key,
    required this.question,
    required this.selectedOptionIds,
    required this.onSelected,
    this.feedbackCorrect,
    this.grade,
    this.onReadQuestion,
  });

  final ExamQuestion question;
  final Set<String> selectedOptionIds;
  final ValueChanged<ExamAnswer> onSelected;
  final bool? feedbackCorrect;
  final int? grade;
  final VoidCallback? onReadQuestion;

  static bool supports(ExamQuestion question) =>
      question.questionKind == 'SINGLE_CHOICE' &&
      RegExp(r'^\d+$').hasMatch(question.questionText.trim()) &&
      (question.questionImageUrl?.trim().isEmpty ?? true) &&
      question.options.length >= 2 &&
      question.options.every(
        (option) =>
            option.text.trim().isEmpty &&
            (option.imageUrl?.trim().isNotEmpty ?? false),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final selectedIndex = question.options.indexWhere(
      (option) => selectedOptionIds.contains(option.id),
    );
    final connectionColor = switch (feedbackCorrect) {
      true => colors.success,
      false => colors.error,
      null => colors.brand,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 24),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: AppShadows.card(colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (grade == 0) ...[
                AssessmentQuestionSpeaker(onPressed: onReadQuestion),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  context.getText(AppKeys.examMatchNumberToImage),
                  style: TextStyle(
                    color: colors.brand,
                    fontSize: FontSize.large,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final numberWidth = (width * 0.23).clamp(60.0, 88.0);
              final optionLeft = width * 0.42;
              final rowHeight = (width * 0.27).clamp(76.0, 92.0);
              const gap = 22.0;
              final height =
                  question.options.length * rowHeight +
                  (question.options.length - 1) * gap;
              final start = Offset(numberWidth, height / 2);

              return SizedBox(
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (selectedIndex >= 0)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MatchConnectionPainter(
                            start: start,
                            end: Offset(
                              optionLeft,
                              selectedIndex * (rowHeight + gap) + rowHeight / 2,
                            ),
                            color: connectionColor,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      top: (height - 80) / 2,
                      width: numberWidth,
                      height: 80,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.brand.withValues(alpha: 0.05),
                          border: Border.all(
                            color: colors.brand.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            question.questionText.trim(),
                            style: TextStyle(
                              fontSize: FontSize.displayMath,
                              color: colors.accent,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: start.dx - 9,
                      top: start.dy - 9,
                      child: _ConnectionDot(
                        color: connectionColor,
                        filled: true,
                      ),
                    ),
                    for (
                      var index = 0;
                      index < question.options.length;
                      index++
                    )
                      Positioned(
                        left: optionLeft - 10,
                        top: index * (rowHeight + gap),
                        width: width - optionLeft + 10,
                        height: rowHeight,
                        child: _ImageMatchOption(
                          option: question.options[index],
                          label: context.formatText(AppKeys.examImageGroup, {
                            'number': index + 1,
                          }),
                          selected: selectedIndex == index,
                          color: selectedIndex == index
                              ? connectionColor
                              : colors.brand,
                          onTap: () => onSelected(question.options[index]),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ImageMatchOption extends StatelessWidget {
  const _ImageMatchOption({
    required this.option,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final ExamAnswer option;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Semantics(
      key: ValueKey('image-match-option-${option.id}'),
      label: label,
      button: true,
      selected: selected,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned.fill(
            left: 10,
            child: Material(
              color: selected
                  ? color.withValues(alpha: 0.08)
                  : colors.elevatedSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: color.withValues(alpha: selected ? 1 : 0.65),
                  width: selected ? 2 : 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    option.imageUrl!,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Center(
                            child: SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                color: colors.brand,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 20,
              height: double.infinity,
              child: Center(
                child: _ConnectionDot(color: color, filled: selected),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  const _ConnectionDot({required this.color, required this.filled});
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: filled ? color : context.themeColors.elevatedSurface,
      border: Border.all(color: color, width: 1.5),
    ),
  );
}

class _MatchConnectionPainter extends CustomPainter {
  const _MatchConnectionPainter({
    required this.start,
    required this.end,
    required this.color,
  });
  final Offset start;
  final Offset end;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final midX = (start.dx + end.dx) / 2;
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(midX, start.dy, midX, end.dy, end.dx, end.dy),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_MatchConnectionPainter oldDelegate) =>
      start != oldDelegate.start ||
      end != oldDelegate.end ||
      color != oldDelegate.color;
}
