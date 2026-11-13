import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_text_normalizer.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';
import 'package:numi/features/exam/data/exam_image_cache.dart';

import 'assessment_question_speaker.dart';

class AssessmentQuestionCard extends StatelessWidget {
  const AssessmentQuestionCard({
    super.key,
    required this.question,
    this.minimumHeight,
    this.compact = false,
    this.renderLatex = false,
    this.imageUrl,
    this.grade,
    this.onReadQuestion,
  });
  final String question;
  final bool renderLatex;
  final String? imageUrl;
  final int? grade;
  final VoidCallback? onReadQuestion;
  final double? minimumHeight;
  final bool compact;

  static final RegExp _pictorialSymbolPattern = RegExp(
    <String>[
      r'\p{Extended_Pictographic}',
      r'\p{Regional_Indicator}{2}',
      r'[#*0-9]\uFE0F?\u20E3',
    ].join('|'),
    unicode: true,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final showSpeaker = grade == 0 || grade == 1;
    final displayQuestion = normalizeAssessmentText(question);
    final questionImageUrl = imageUrl?.trim();
    if (questionImageUrl != null && questionImageUrl.isNotEmpty) {
      return _AssessmentImageQuestion(
        question: displayQuestion,
        imageUrl: questionImageUrl,
        renderLatex: renderLatex,
        showSpeaker: showSpeaker,
        onReadQuestion: onReadQuestion,
      );
    }
    final mathQuestion = _mathQuestionParts(displayQuestion);
    final orderingQuestion = _OrderingQuestionParts.parse(displayQuestion);
    final isPictorialQuestion = _containsPictorialSymbols(displayQuestion);
    final questionContent = renderLatex
        ? ExamMathText(
            displayQuestion,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.displaySmall,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          )
        : orderingQuestion != null
        ? Semantics(
            label: displayQuestion,
            excludeSemantics: true,
            child: _AssessmentOrderingQuestion(parts: orderingQuestion),
          )
        : mathQuestion != null
        ? _AssessmentMathQuestion(
            prefix: mathQuestion.prefix,
            expression: mathQuestion.expression,
            color: colors.textPrimary,
          )
        : _questionText(colors, displayQuestion);

    return Container(
      constraints: BoxConstraints(
        minHeight:
            minimumHeight ??
            _minimumHeightFor(
              displayQuestion,
              isMathQuestion: mathQuestion != null,
              isPictorialQuestion: isPictorialQuestion,
            ),
      ),
      alignment: showSpeaker ? Alignment.topCenter : Alignment.center,
      padding: showSpeaker
          ? const EdgeInsets.all(16)
          : EdgeInsets.symmetric(
              horizontal: 24,
              vertical: compact ? 20 : (isPictorialQuestion ? 40 : 28),
            ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.card(colors),
      ),
      child: showSpeaker
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: AssessmentQuestionSpeaker(onPressed: onReadQuestion),
                ),
                SizedBox(height: compact ? 8 : 12),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: compact ? 0 : 16),
                  child: questionContent,
                ),
              ],
            )
          : questionContent,
    );
  }

  double _minimumHeightFor(
    String value, {
    required bool isMathQuestion,
    required bool isPictorialQuestion,
  }) {
    final length = value.trim().length;
    if (isPictorialQuestion) {
      return length <= 90 ? 260 : 300;
    }

    if (isMathQuestion) {
      if (length <= 24) return 236;
      if (length <= 48) return 256;
      return 276;
    }

    if (length <= 45) return 176;
    if (length <= 90) return 206;
    if (length <= 160) return 246;
    return 276;
  }

  bool _containsPictorialSymbols(String value) {
    return _pictorialSymbolPattern.hasMatch(value);
  }

  double _fontSizeFor(String value) {
    final length = value.trim().length;
    if (length <= 18) return FontSize.displayHero;
    if (length <= 45) return FontSize.displayExtraLarge;
    if (length <= 90) return FontSize.displaySmall;
    if (length <= 160) return FontSize.xxxl;
    return FontSize.xl;
  }

  bool _isMathExpression(String value) {
    final expression = value.trim();
    return RegExp(r'^[0-9\s+×xX*/÷:()=?.,−-]+$').hasMatch(expression) &&
        RegExp(r'[+×xX*/÷:=−-]').hasMatch(expression) &&
        RegExp(r'\d').hasMatch(expression);
  }

  _MathQuestionParts? _mathQuestionParts(String value) {
    if (_isMathExpression(value)) {
      return _MathQuestionParts(expression: value.trim());
    }

    final prefixedExpression = RegExp(
      r'^((?:Tìm\s+x|Tính(?:\s+giá\s+trị(?:\s+(?:của\s+)?biểu\s+thức)?)?|Giải|Điền\s+số(?:\s+thích\s+hợp)?)\s*:\s*)(.+)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (prefixedExpression == null) {
      return null;
    }

    final expression = prefixedExpression.group(2)!;
    if (!_isMathExpression(expression)) {
      return null;
    }
    return _MathQuestionParts(
      prefix: prefixedExpression.group(1)!.trim(),
      expression: expression,
    );
  }

  Widget _questionText(AppThemeColors colors, String displayQuestion) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        displayQuestion,
        textAlign: TextAlign.center,
        softWrap: true,
        maxLines: null,
        overflow: TextOverflow.visible,
        textWidthBasis: TextWidthBasis.parent,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: compact
              ? _fontSizeFor(displayQuestion).clamp(0, FontSize.displayMedium)
              : _fontSizeFor(displayQuestion),
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AssessmentImageQuestion extends StatelessWidget {
  const _AssessmentImageQuestion({
    required this.question,
    required this.imageUrl,
    required this.renderLatex,
    required this.showSpeaker,
    required this.onReadQuestion,
  });

  final String question;
  final String imageUrl;
  final bool renderLatex;
  final bool showSpeaker;
  final VoidCallback? onReadQuestion;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final textStyle = TextStyle(
      color: colors.brandStrong,
      fontSize: FontSize.xl,
      fontWeight: FontWeight.w700,
      height: 1.3,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.brand.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: colors.brand.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuestionPromptRow(
            showSpeaker: showSpeaker,
            onReadQuestion: onReadQuestion,
            child: renderLatex
                ? ExamMathText(
                    question,
                    textAlign: TextAlign.start,
                    style: textStyle,
                  )
                : Text(question, softWrap: true, style: textStyle),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxWidth * 0.8,
                ),
                child: Image(
                  image: ExamImageCache.provider(imageUrl),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.brand,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPromptRow extends StatelessWidget {
  const _QuestionPromptRow({
    required this.showSpeaker,
    required this.onReadQuestion,
    required this.child,
  });

  final bool showSpeaker;
  final VoidCallback? onReadQuestion;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (showSpeaker) ...[
        AssessmentQuestionSpeaker(onPressed: onReadQuestion),
        const SizedBox(width: 12),
      ],
      Expanded(child: child),
    ],
  );
}

class _MathQuestionParts {
  const _MathQuestionParts({this.prefix, required this.expression});

  final String? prefix;
  final String expression;
}

class _AssessmentMathQuestion extends StatelessWidget {
  const _AssessmentMathQuestion({
    required this.prefix,
    required this.expression,
    required this.color,
  });

  final String? prefix;
  final String expression;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (prefix == null) {
      return _AssessmentMathExpression(expression: expression, color: color);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prefix!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: FontSize.xl,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _AssessmentMathExpression(expression: expression, color: color),
        ],
      ),
    );
  }
}

class _AssessmentMathExpression extends StatelessWidget {
  const _AssessmentMathExpression({
    required this.expression,
    required this.color,
  });

  final String expression;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final displayExpression = expression.replaceAllMapped(
          RegExp(r'\s*([+×xX*/÷:=−-])\s*'),
          (match) {
            final operator = match.group(1)!;
            final preceding = expression.substring(0, match.start).trimRight();
            final isSign =
                (operator == '-' || operator == '−') &&
                (preceding.isEmpty ||
                    '(+×xX*/÷:=−-'.contains(preceding[preceding.length - 1]));
            return isSign ? operator : ' $operator ';
          },
        ).trim();
        // Use the actual width (including accessibility text scaling) rather
        // than shrinking every short expression from a fixed 64px size.
        double? singleLineFontSize;
        for (final size in [
          FontSize.displayMath,
          FontSize.displayExtraLarge,
          FontSize.displayLarge,
          FontSize.displaySmall,
        ]) {
          final painter = TextPainter(
            text: TextSpan(
              text: displayExpression,
              style: DefaultTextStyle.of(context).style.merge(_textStyle(size)),
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final fits = painter.width <= constraints.maxWidth;
          painter.dispose();
          if (fits) {
            singleLineFontSize = size;
            break;
          }
        }
        if (singleLineFontSize != null) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayExpression,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: _textStyle(singleLineFontSize),
                ),
              ),
            ),
          );
        }

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: _semanticSegments(displayExpression).map((segment) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    segment,
                    softWrap: false,
                    style: _textStyle(FontSize.displaySmall),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  TextStyle _textStyle(double fontSize) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.15,
      letterSpacing: 0,
    );
  }

  List<String> _semanticSegments(String value) {
    final segments = <String>[];
    var start = 0;
    var depth = 0;
    for (var index = 0; index < value.length; index++) {
      final character = value[index];
      if (character == '(') depth++;
      if (character == ')') depth--;
      if (depth == 0 &&
          index > start &&
          '+−-=×xX*/÷:'.contains(character) &&
          RegExp(r'[0-9)?]').hasMatch(value.substring(start, index))) {
        segments.add(value.substring(start, index).trim());
        start = index;
      }
    }
    segments.add(value.substring(start).trim());
    return segments;
  }
}

class _OrderingQuestionParts {
  const _OrderingQuestionParts(this.prefix, this.numbers, this.suffix);

  final String prefix;
  final List<String> numbers;
  final String suffix;

  static _OrderingQuestionParts? parse(String value) {
    if (!RegExp(
      r'sắp\s+xếp|xếp\s+.*thứ\s+tự',
      caseSensitive: false,
    ).hasMatch(value)) {
      return null;
    }
    // A comma followed by whitespace separates items; a comma inside a number
    // is decimal punctuation. Semicolons support decimal-comma lists as well.
    const number = r'[−-]?\d+(?:[.,]\d+)?';
    const separator = r'(?:\s*;\s*|,\s+)';
    final match = RegExp(
      '^(.+?(?::|các\\s+số)\\s*)'
      '($number(?:$separator$number)+)'
      r'([.!?]?|\s+(?:theo|từ)\s+.*)$',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return null;
    return _OrderingQuestionParts(
      match.group(1)!.trim(),
      match.group(2)!.split(RegExp(separator)),
      match.group(3)!.trim().replaceFirst(RegExp(r'^[.!?]$'), ''),
    );
  }
}

class _AssessmentOrderingQuestion extends StatelessWidget {
  const _AssessmentOrderingQuestion({required this.parts});

  final _OrderingQuestionParts parts;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final promptStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: FontSize.xl,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(parts.prefix, textAlign: TextAlign.center, style: promptStyle),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final number in parts.numbers)
                Container(
                  constraints: BoxConstraints(
                    minWidth: 56,
                    maxWidth: constraints.maxWidth,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.inputSurface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      number,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: FontSize.displaySmall,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (parts.suffix.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(parts.suffix, textAlign: TextAlign.center, style: promptStyle),
        ],
      ],
    );
  }
}
