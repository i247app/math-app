import 'package:flutter/material.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';

import 'package:numi/core/theme/app_shadows.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_text_normalizer.dart';
import 'package:numi/features/exam/widgets/exam_math_text.dart';

class AssessmentQuestionCard extends StatelessWidget {
  const AssessmentQuestionCard({
    super.key,
    required this.question,
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
    final displayQuestion = normalizeAssessmentText(question);
    final questionImageUrl = imageUrl?.trim();
    if (questionImageUrl != null && questionImageUrl.isNotEmpty) {
      return _AssessmentImageQuestion(
        question: displayQuestion,
        imageUrl: questionImageUrl,
        renderLatex: renderLatex,
        showSpeaker: grade == 0,
        onReadQuestion: onReadQuestion,
      );
    }
    final mathQuestion = _mathQuestionParts(displayQuestion);
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
        : mathQuestion != null
        ? _AssessmentMathQuestion(
            prefix: mathQuestion.prefix,
            expression: mathQuestion.expression,
            color: colors.textPrimary,
          )
        : _questionText(colors, displayQuestion);

    return Container(
      constraints: BoxConstraints(
        minHeight: _minimumHeightFor(
          displayQuestion,
          isMathQuestion: mathQuestion != null,
          isPictorialQuestion: isPictorialQuestion,
        ),
      ),
      alignment: grade == 0 ? Alignment.topCenter : Alignment.center,
      padding: grade == 0
          ? const EdgeInsets.all(16)
          : EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isPictorialQuestion ? 40 : 28,
            ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.border),
        boxShadow: AppShadows.card(colors),
      ),
      child: grade == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _QuestionSpeaker(onPressed: onReadQuestion),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
      r'^((?:Tìm\s+x|Tính|Giải)\s*:\s*)(.+)$',
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
          fontSize: _fontSizeFor(displayQuestion),
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
                child: Image.network(
                  imageUrl,
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
        _QuestionSpeaker(onPressed: onReadQuestion),
        const SizedBox(width: 12),
      ],
      Expanded(child: child),
    ],
  );
}

class _QuestionSpeaker extends StatelessWidget {
  const _QuestionSpeaker({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return IconButton.filledTonal(
      key: const ValueKey('read-question'),
      tooltip: AppStrings.current(AppKeys.examReadQuestion),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: colors.brand,
        backgroundColor: colors.brand.withValues(alpha: 0.12),
        minimumSize: const Size(48, 48),
      ),
      icon: const Icon(Icons.volume_up_rounded, size: 28),
    );
  }
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
              fontSize: FontSize.displaySmall,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
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
        if (expression.length <= 24) {
          return SizedBox(
            width: constraints.maxWidth,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  expression,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: _textStyle(FontSize.displayMath),
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
            children: _semanticSegments().map((segment) {
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
      fontWeight: FontWeight.w900,
      height: 1.15,
      letterSpacing: 0,
    );
  }

  List<String> _semanticSegments() {
    final primarySegments = expression
        .split(RegExp(r'(?=[+−=\-])'))
        .where((segment) => segment.trim().isNotEmpty);

    return primarySegments.expand((segment) {
      if (segment.length <= 18) {
        return [segment.trim()];
      }
      return segment
          .split(RegExp(r'(?=[×xX*/÷:])'))
          .where((part) => part.trim().isNotEmpty)
          .map((part) => part.trim());
    }).toList();
  }
}
