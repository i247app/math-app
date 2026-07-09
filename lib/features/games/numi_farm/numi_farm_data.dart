import 'package:numi_flutter/core/localization/app_keys.dart';

enum NumiFarmSkill {
  countToFive,
  countToTen,
  compareGroups,
  addWithinTen,
  subtractWithinTen,
}

enum NumiFarmInteraction {
  tapToHarvest,
  chooseBasket,
  combineHarvest,
  removeHarvest,
}

class NumiFarmStageConfig {
  const NumiFarmStageConfig({
    required this.stage,
    required this.titleKey,
    required this.skill,
    required this.interaction,
    required this.roundCount,
    required this.minimumValue,
    required this.maximumValue,
    required this.fieldItemCount,
    required this.choiceCount,
    required this.hasTimer,
  });

  final int stage;
  final String titleKey;
  final NumiFarmSkill skill;
  final NumiFarmInteraction interaction;
  final int roundCount;
  final int minimumValue;
  final int maximumValue;
  final int fieldItemCount;
  final int choiceCount;
  final bool hasTimer;
}

const numiFarmStages = <NumiFarmStageConfig>[
  NumiFarmStageConfig(
    stage: 1,
    titleKey: AppKeys.gamesFarmStageOneTitle,
    skill: NumiFarmSkill.countToFive,
    interaction: NumiFarmInteraction.tapToHarvest,
    roundCount: 5,
    minimumValue: 1,
    maximumValue: 5,
    fieldItemCount: 8,
    choiceCount: 0,
    hasTimer: false,
  ),
  NumiFarmStageConfig(
    stage: 2,
    titleKey: AppKeys.gamesFarmStageTwoTitle,
    skill: NumiFarmSkill.countToTen,
    interaction: NumiFarmInteraction.tapToHarvest,
    roundCount: 6,
    minimumValue: 1,
    maximumValue: 10,
    fieldItemCount: 12,
    choiceCount: 0,
    hasTimer: false,
  ),
  NumiFarmStageConfig(
    stage: 3,
    titleKey: AppKeys.gamesFarmStageThreeTitle,
    skill: NumiFarmSkill.compareGroups,
    interaction: NumiFarmInteraction.chooseBasket,
    roundCount: 6,
    minimumValue: 1,
    maximumValue: 10,
    fieldItemCount: 0,
    choiceCount: 2,
    hasTimer: false,
  ),
  NumiFarmStageConfig(
    stage: 4,
    titleKey: AppKeys.gamesFarmStageFourTitle,
    skill: NumiFarmSkill.addWithinTen,
    interaction: NumiFarmInteraction.combineHarvest,
    roundCount: 7,
    minimumValue: 0,
    maximumValue: 10,
    fieldItemCount: 10,
    choiceCount: 0,
    hasTimer: false,
  ),
  NumiFarmStageConfig(
    stage: 5,
    titleKey: AppKeys.gamesFarmStageFiveTitle,
    skill: NumiFarmSkill.subtractWithinTen,
    interaction: NumiFarmInteraction.removeHarvest,
    roundCount: 7,
    minimumValue: 0,
    maximumValue: 10,
    fieldItemCount: 10,
    choiceCount: 0,
    hasTimer: false,
  ),
];

NumiFarmStageConfig numiFarmStage(int stage) => numiFarmStages.firstWhere(
  (config) => config.stage == stage,
  orElse: () => numiFarmStages.first,
);

class NumiFarmCountRound {
  const NumiFarmCountRound({
    required this.target,
    required this.fieldItemCount,
  });

  final int target;
  final int fieldItemCount;
}

List<NumiFarmCountRound> buildHarvestRounds(int stage) {
  final config = numiFarmStage(stage);
  final targets = stage == 1
      ? const <int>[2, 4, 1, 5, 3]
      : const <int>[6, 8, 7, 10, 9, 5];
  return targets
      .map(
        (target) => NumiFarmCountRound(
          target: target,
          fieldItemCount: config.fieldItemCount,
        ),
      )
      .toList(growable: false);
}

enum NumiFarmChoiceKind { comparison, addition, subtraction }

class NumiFarmChoiceRound {
  const NumiFarmChoiceRound({
    required this.left,
    required this.right,
    required this.answer,
    required this.choices,
    required this.kind,
  });

  final int left;
  final int right;
  final String answer;
  final List<String> choices;
  final NumiFarmChoiceKind kind;
}

List<NumiFarmChoiceRound> buildChoiceRounds(int stage) {
  return switch (stage) {
    3 => const <NumiFarmChoiceRound>[
      NumiFarmChoiceRound(
        left: 2,
        right: 4,
        answer: '<',
        choices: ['<', '=', '>'],
        kind: NumiFarmChoiceKind.comparison,
      ),
      NumiFarmChoiceRound(
        left: 5,
        right: 3,
        answer: '>',
        choices: ['=', '>', '<'],
        kind: NumiFarmChoiceKind.comparison,
      ),
      NumiFarmChoiceRound(
        left: 4,
        right: 4,
        answer: '=',
        choices: ['>', '<', '='],
        kind: NumiFarmChoiceKind.comparison,
      ),
      NumiFarmChoiceRound(
        left: 7,
        right: 9,
        answer: '<',
        choices: ['=', '<', '>'],
        kind: NumiFarmChoiceKind.comparison,
      ),
      NumiFarmChoiceRound(
        left: 10,
        right: 6,
        answer: '>',
        choices: ['<', '>', '='],
        kind: NumiFarmChoiceKind.comparison,
      ),
      NumiFarmChoiceRound(
        left: 8,
        right: 8,
        answer: '=',
        choices: ['=', '>', '<'],
        kind: NumiFarmChoiceKind.comparison,
      ),
    ],
    4 => _equationRounds(const [
      (1, 2),
      (2, 3),
      (4, 1),
      (3, 3),
      (4, 5),
      (6, 4),
      (7, 2),
    ], addition: true),
    5 => _equationRounds(const [
      (5, 1),
      (6, 2),
      (7, 3),
      (8, 5),
      (9, 4),
      (10, 6),
      (10, 3),
    ], addition: false),
    _ => const <NumiFarmChoiceRound>[],
  };
}

List<NumiFarmChoiceRound> _equationRounds(
  List<(int, int)> values, {
  required bool addition,
}) {
  return values
      .map((pair) {
        final answer = addition ? pair.$1 + pair.$2 : pair.$1 - pair.$2;
        final lower = answer > 0 ? answer - 1 : answer + 2;
        final upper = answer + 1;
        final choices = <int>[lower, answer, upper]..sort();
        final rotation = (pair.$1 + pair.$2) % choices.length;
        final rotated = <int>[
          ...choices.skip(rotation),
          ...choices.take(rotation),
        ];
        return NumiFarmChoiceRound(
          left: pair.$1,
          right: pair.$2,
          answer: '$answer',
          choices: rotated.map((choice) => '$choice').toList(growable: false),
          kind: addition
              ? NumiFarmChoiceKind.addition
              : NumiFarmChoiceKind.subtraction,
        );
      })
      .toList(growable: false);
}
