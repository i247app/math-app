import 'package:numi/core/localization/app_keys.dart';

enum RescueOperation { add, multiply }

class RescueGate {
  const RescueGate(this.operation, this.value);

  final RescueOperation operation;
  final int value;

  String get label => switch (operation) {
    RescueOperation.add => '+$value',
    RescueOperation.multiply => '×$value',
  };

  int apply(int teamSize) => switch (operation) {
    RescueOperation.add => teamSize + value,
    RescueOperation.multiply => teamSize * value,
  };
}

class RescuePathChoice {
  const RescuePathChoice({
    required this.left,
    required this.right,
    required this.sceneEmoji,
  });

  final RescueGate left;
  final RescueGate right;
  final String sceneEmoji;
}

class MonsterRescueLevelConfig {
  const MonsterRescueLevelConfig({
    required this.level,
    required this.titleKey,
    required this.creatureName,
    required this.creatureAsset,
    required this.startingTeam,
    required this.choices,
    required this.bridgeTeam,
  });

  final int level;
  final String titleKey;
  final String creatureName;
  final String creatureAsset;
  final int startingTeam;
  final List<RescuePathChoice> choices;
  final int bridgeTeam;
}

const monsterRescueLevels = <MonsterRescueLevelConfig>[
  MonsterRescueLevelConfig(
    level: 1,
    titleKey: AppKeys.gamesRescueLevelOne,
    creatureName: 'Numi Điện',
    creatureAsset: 'assets/images/game-numi-electric-rescue.png',
    startingTeam: 4,
    bridgeTeam: 3,
    choices: [
      RescuePathChoice(
        left: RescueGate(RescueOperation.add, 3),
        right: RescueGate(RescueOperation.multiply, 2),
        sceneEmoji: '🌿',
      ),
      RescuePathChoice(
        left: RescueGate(RescueOperation.add, 4),
        right: RescueGate(RescueOperation.multiply, 2),
        sceneEmoji: '⚡',
      ),
    ],
  ),
];

MonsterRescueLevelConfig monsterRescueLevel(int level) =>
    monsterRescueLevels.firstWhere(
      (config) => config.level == level,
      orElse: () => monsterRescueLevels.first,
    );
