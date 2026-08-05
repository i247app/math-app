import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AssessmentQuestionCard extends StatelessWidget {
  const AssessmentQuestionCard({super.key, required this.question});
  final String question;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final mathQuestion = _mathQuestionParts(question);

    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colors.border),
      ),
      child: mathQuestion != null
          ? _AssessmentMathQuestion(
              prefix: mathQuestion.prefix,
              expression: mathQuestion.expression,
              color: colors.textPrimary,
            )
          : _questionText(colors),
    );
  }

  double _fontSizeFor(String value) {
    final length = value.trim().length;
    if (length <= 18) return 52;
    if (length <= 45) return 40;
    if (length <= 90) return 30;
    if (length <= 160) return 24;
    return 20;
  }

  bool _isMathExpression(String value) {
    final expression = value.trim();
    return RegExp(r'^[0-9\s+×xX*/÷:()=?.,-−]+$').hasMatch(expression) &&
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

  Widget _questionText(AppThemeColors colors) {
    return Text(
      question,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: _fontSizeFor(question),
        fontWeight: FontWeight.w900,
        height: 1.2,
        letterSpacing: 0,
      ),
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
              fontSize: 32,
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
                  style: _textStyle(64),
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
              return Text(segment, softWrap: false, style: _textStyle(32));
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
