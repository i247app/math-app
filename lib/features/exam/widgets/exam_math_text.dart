import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Keeps prose in the app font and delegates TeX rendering to Flutter Math.
class ExamMathText extends StatelessWidget {
  const ExamMathText(
    this.content, {
    super.key,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  final String content;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final parts = _splitMath(content);
    return Text.rich(
      TextSpan(
        children: parts
            .map((part) {
              if (!part.isMath) return TextSpan(text: part.content);
              return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Math.tex(
                    part.content,
                    textStyle: style,
                    // WidgetSpan applies the surrounding text scale itself.
                    textScaleFactor: 1,
                    onErrorFallback: (_) => Text(
                      part.content,
                      style: style,
                      textScaler: TextScaler.noScaling,
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}

class _MathPart {
  const _MathPart(this.content, {this.isMath = false});

  final String content;
  final bool isMath;
}

List<_MathPart> _splitMath(String value) {
  final parts = <_MathPart>[];
  final startPattern = RegExp(r'\$\$?|\\\(|\\\[|\\(?:dfrac|tfrac|frac)\b');
  var cursor = 0;
  for (final match in startPattern.allMatches(value)) {
    if (match.start < cursor) continue;
    if (_isEscaped(value, match.start)) continue;
    final start = match.group(0)!;
    int end;
    String formula;
    if (start.startsWith(r'\') && start.endsWith('frac')) {
      final fractionEnd = _fractionEnd(value, match.end);
      if (fractionEnd == null) continue;
      end = fractionEnd;
      formula = value.substring(match.start, end);
    } else {
      final closing = switch (start) {
        r'\(' => r'\)',
        r'\[' => r'\]',
        _ => start,
      };
      var closingIndex = value.indexOf(closing, match.end);
      while (closingIndex >= 0 && _isEscaped(value, closingIndex)) {
        closingIndex = value.indexOf(closing, closingIndex + closing.length);
      }
      if (closingIndex < 0) break;
      end = closingIndex + closing.length;
      formula = value.substring(match.end, closingIndex);
    }
    if (match.start > cursor) {
      parts.add(_MathPart(value.substring(cursor, match.start)));
    }
    parts.add(_MathPart(formula, isMath: true));
    cursor = end;
  }
  if (cursor < value.length) parts.add(_MathPart(value.substring(cursor)));

  // Bare fractions can form a whole expression without explicit delimiters.
  if (parts.any((part) => part.isMath) &&
      !value.contains(r'$') &&
      !value.contains(r'\(') &&
      !value.contains(r'\[') &&
      parts
          .where((part) => !part.isMath)
          .every(
            (part) =>
                RegExp(r'^[0-9\s+*/=<>.,%()\-−×÷≤≥≠]*$').hasMatch(part.content),
          )) {
    return [_MathPart(value, isMath: true)];
  }
  return parts;
}

// Scan balanced arguments only; the library parses the formula itself.
int? _fractionEnd(String value, int cursor) {
  for (var argument = 0; argument < 2; argument++) {
    while (cursor < value.length && value[cursor].trim().isEmpty) {
      cursor++;
    }
    if (cursor >= value.length || value[cursor] != '{') return null;
    var depth = 0;
    do {
      if (!_isEscaped(value, cursor)) {
        if (value[cursor] == '{') depth++;
        if (value[cursor] == '}') depth--;
      }
      cursor++;
    } while (cursor < value.length && depth > 0);
    if (depth != 0) return null;
  }
  return cursor;
}

bool _isEscaped(String value, int index) {
  var backslashes = 0;
  for (var cursor = index - 1; cursor >= 0 && value[cursor] == r'\'; cursor--) {
    backslashes++;
  }
  return backslashes.isOdd;
}
