import 'dart:math';

import 'package:numi/core/localization/app_keys.dart';

enum StarGameLevel {
  kite(AppKeys.gamesKite, AppKeys.gamesKiteSkill, 10),
  whale(AppKeys.gamesWhale, AppKeys.gamesWhaleSkill, 20),
  turtle(AppKeys.gamesTurtle, AppKeys.gamesTurtleSkill, 100),
  fox(AppKeys.gamesFox, AppKeys.gamesFoxSkill, 50),
  firebird(AppKeys.gamesFirebird, AppKeys.gamesFirebirdSkill, 90),
  dragon(AppKeys.gamesDragon, AppKeys.gamesDragonSkill, 100);

  const StarGameLevel(this.nameKey, this.skillKey, this.maxAnswer);

  final String nameKey;
  final String skillKey;
  final int maxAnswer;

  int get number => index + 1;
  StarGameLevel? get next => number < values.length ? values[number] : null;
}

const starGameQuestionCount = 10;
const starGameMilestones = [5, 7, 9];

int starGameStars(int correct) =>
    starGameMilestones.where((target) => correct >= target).length;

String starGameTime(Duration duration) {
  final minutes = duration.inMinutes.toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds.${duration.inMilliseconds ~/ 100 % 10}';
}

class StarGameRecord {
  const StarGameRecord({required this.correct, required this.elapsed});

  final int correct;
  final Duration elapsed;

  int get stars => starGameStars(correct);

  bool beats(StarGameRecord other) =>
      correct > other.correct ||
      (correct == other.correct &&
          elapsed.inMilliseconds ~/ 100 < other.elapsed.inMilliseconds ~/ 100);

  Map<String, int> toJson() => {
    'correct': correct,
    'milliseconds': elapsed.inMilliseconds,
  };

  static StarGameRecord? fromJson(Object? value) {
    if (value case {'correct': final int correct, 'milliseconds': final int ms}
        when correct >= 0 && correct <= starGameQuestionCount && ms >= 0) {
      return StarGameRecord(
        correct: correct,
        elapsed: Duration(milliseconds: ms),
      );
    }
    return null;
  }
}

class StarGameQuestion {
  const StarGameQuestion({
    required this.expression,
    required this.answer,
    required this.choices,
  });

  final String expression;
  final int answer;
  final List<int> choices;
}

List<StarGameQuestion> buildStarGameQuestions(
  StarGameLevel level, {
  Random? random,
}) {
  final rng = random ?? Random();
  final expressions = switch (level) {
    StarGameLevel.kite => (_additions(0, 10), <_Expression>[]),
    StarGameLevel.whale => (_additions(0, 20), _subtractions(1, 20)),
    StarGameLevel.turtle => (
      _additions(10, 100, carrying: true),
      _subtractions(10, 100, borrowing: true),
    ),
    StarGameLevel.fox => _tables(2, 5),
    StarGameLevel.firebird => _tables(6, 9),
    StarGameLevel.dragon => _twoSteps(),
  };
  final (first, second) = expressions;
  final selected = second.isEmpty
      ? (first..shuffle(rng)).take(starGameQuestionCount).toList()
      : [
          ...(first..shuffle(rng)).take(starGameQuestionCount ~/ 2),
          ...(second..shuffle(rng)).take(starGameQuestionCount ~/ 2),
        ];
  selected.shuffle(rng);

  return [
    for (final (expression, answer) in selected)
      StarGameQuestion(
        expression: expression,
        answer: answer,
        choices: _choices(answer, level.maxAnswer, rng),
      ),
  ];
}

typedef _Expression = (String, int);

List<_Expression> _additions(int minimum, int cap, {bool carrying = false}) => [
  for (var left = minimum; left <= cap ~/ 2; left++)
    for (var right = left; right <= cap - left; right++)
      if (!carrying || left % 10 + right % 10 >= 10)
        ('$left + $right', left + right),
];

List<_Expression> _subtractions(
  int minimum,
  int cap, {
  bool borrowing = false,
}) => [
  for (var left = minimum; left <= cap; left++)
    for (var right = minimum; right <= left; right++)
      if (!borrowing || left % 10 < right % 10)
        ('$left − $right', left - right),
];

(List<_Expression>, List<_Expression>) _tables(int first, int last) => (
  [
    for (var table = first; table <= last; table++)
      for (var factor = 2; factor <= 10; factor++)
        if (factor < first || factor > last || table <= factor)
          ('$table × $factor', table * factor),
  ],
  [
    for (var table = first; table <= last; table++)
      for (var quotient = 2; quotient <= 10; quotient++)
        ('${table * quotient} ÷ $table', quotient),
  ],
);

(List<_Expression>, List<_Expression>) _twoSteps() {
  final additions = <_Expression>[];
  final subtractions = <_Expression>[];
  for (var left = 4; left <= 9; left++) {
    for (var right = left; right <= 9; right++) {
      for (var offset = 2; offset <= 9; offset++) {
        additions.add(('($left × $right) + $offset', left * right + offset));
        subtractions.add(('($left × $right) − $offset', left * right - offset));
      }
    }
  }
  return (additions, subtractions);
}

List<int> _choices(int answer, int cap, Random random) {
  final radius = cap <= 20 ? 4 : 8;
  final distractors = [
    for (
      var value = max(0, answer - radius);
      value <= min(cap, answer + radius);
      value++
    )
      if (value != answer) value,
  ]..shuffle(random);
  return List.unmodifiable([answer, ...distractors.take(3)]..shuffle(random));
}
