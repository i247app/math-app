import 'package:numi_flutter/core/localization/app_keys.dart';

enum MathSquadronTargetKind { meteor, drone, crystal }

class MathSquadronQuestion {
  const MathSquadronQuestion({
    required this.prompt,
    required this.answers,
    required this.correctAnswer,
    this.targetKind = MathSquadronTargetKind.meteor,
  });

  final String prompt;
  final List<String> answers;
  final String correctAnswer;
  final MathSquadronTargetKind targetKind;
}

class MathSquadronLevelConfig {
  const MathSquadronLevelConfig({
    required this.level,
    required this.titleKey,
    required this.questions,
    required this.shields,
    required this.isBoss,
    required this.accentValue,
  });

  final int level;
  final String titleKey;
  final List<MathSquadronQuestion> questions;
  final int shields;
  final bool isBoss;
  final int accentValue;
}

const mathSquadronLevels = <MathSquadronLevelConfig>[
  MathSquadronLevelConfig(
    level: 1,
    titleKey: AppKeys.gamesSquadronLevelOne,
    shields: 3,
    isBoss: false,
    accentValue: 0xFF39C6FF,
    questions: [
      MathSquadronQuestion(
        prompt: '23 + 15 = ?',
        answers: ['28', '38', '42', '48'],
        correctAnswer: '38',
      ),
      MathSquadronQuestion(
        prompt: '64 - 21 = ?',
        answers: ['33', '42', '43', '53'],
        correctAnswer: '43',
      ),
      MathSquadronQuestion(
        prompt: '32 + 26 = ?',
        answers: ['48', '52', '58', '68'],
        correctAnswer: '58',
      ),
      MathSquadronQuestion(
        prompt: '90 - 37 = ?',
        answers: ['43', '53', '57', '63'],
        correctAnswer: '53',
      ),
      MathSquadronQuestion(
        prompt: '46 + 18 = ?',
        answers: ['54', '62', '64', '74'],
        correctAnswer: '64',
      ),
      MathSquadronQuestion(
        prompt: '75 - 29 = ?',
        answers: ['44', '46', '54', '56'],
        correctAnswer: '46',
      ),
    ],
  ),
  MathSquadronLevelConfig(
    level: 2,
    titleKey: AppKeys.gamesSquadronLevelTwo,
    shields: 3,
    isBoss: false,
    accentValue: 0xFF8D7CFF,
    questions: [
      MathSquadronQuestion(
        prompt: '3 × 7 = ?',
        answers: ['18', '20', '21', '24'],
        correctAnswer: '21',
        targetKind: MathSquadronTargetKind.drone,
      ),
      MathSquadronQuestion(
        prompt: '24 : 4 = ?',
        answers: ['4', '5', '6', '8'],
        correctAnswer: '6',
        targetKind: MathSquadronTargetKind.drone,
      ),
      MathSquadronQuestion(
        prompt: '5 × 8 = ?',
        answers: ['35', '40', '45', '48'],
        correctAnswer: '40',
        targetKind: MathSquadronTargetKind.drone,
      ),
      MathSquadronQuestion(
        prompt: '36 : 6 = ?',
        answers: ['5', '6', '7', '9'],
        correctAnswer: '6',
        targetKind: MathSquadronTargetKind.drone,
      ),
      MathSquadronQuestion(
        prompt: '4 × 9 = ?',
        answers: ['32', '35', '36', '40'],
        correctAnswer: '36',
        targetKind: MathSquadronTargetKind.drone,
      ),
      MathSquadronQuestion(
        prompt: '45 : 5 = ?',
        answers: ['7', '8', '9', '10'],
        correctAnswer: '9',
        targetKind: MathSquadronTargetKind.drone,
      ),
    ],
  ),
  MathSquadronLevelConfig(
    level: 3,
    titleKey: AppKeys.gamesSquadronLevelThree,
    shields: 5,
    isBoss: true,
    accentValue: 0xFFFF6B63,
    questions: [
      MathSquadronQuestion(
          prompt: '6 × 7 = ?',
          answers: ['36', '42', '48', '54'],
          correctAnswer: '42'),
      MathSquadronQuestion(
          prompt: '56 : 8 = ?',
          answers: ['6', '7', '8', '9'],
          correctAnswer: '7'),
      MathSquadronQuestion(
          prompt: '9 × 7 = ?',
          answers: ['54', '56', '63', '72'],
          correctAnswer: '63'),
      MathSquadronQuestion(
          prompt: '72 : 9 = ?',
          answers: ['6', '7', '8', '9'],
          correctAnswer: '8'),
      MathSquadronQuestion(
          prompt: '8 × 8 = ?',
          answers: ['56', '62', '64', '72'],
          correctAnswer: '64'),
      MathSquadronQuestion(
          prompt: '63 : 7 = ?',
          answers: ['7', '8', '9', '10'],
          correctAnswer: '9'),
      MathSquadronQuestion(
          prompt: '7 × 9 = ?',
          answers: ['56', '63', '64', '72'],
          correctAnswer: '63'),
      MathSquadronQuestion(
          prompt: '48 : 6 = ?',
          answers: ['6', '7', '8', '9'],
          correctAnswer: '8'),
    ],
  ),
  MathSquadronLevelConfig(
    level: 4,
    titleKey: AppKeys.gamesSquadronLevelFour,
    shields: 4,
    isBoss: false,
    accentValue: 0xFF44D7B6,
    questions: [
      MathSquadronQuestion(
          prompt: 'x + 18 = 45',
          answers: ['17', '27', '37', '63'],
          correctAnswer: '27',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: 'x - 24 = 36',
          answers: ['12', '50', '60', '70'],
          correctAnswer: '60',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '7 × x = 42',
          answers: ['5', '6', '7', '8'],
          correctAnswer: '6',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: 'x : 8 = 7',
          answers: ['48', '54', '56', '64'],
          correctAnswer: '56',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '96 - x = 38',
          answers: ['48', '52', '58', '68'],
          correctAnswer: '58',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: 'x + 125 = 300',
          answers: ['165', '175', '185', '425'],
          correctAnswer: '175',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '9 × x = 72',
          answers: ['6', '7', '8', '9'],
          correctAnswer: '8',
          targetKind: MathSquadronTargetKind.crystal),
    ],
  ),
  MathSquadronLevelConfig(
    level: 5,
    titleKey: AppKeys.gamesSquadronLevelFive,
    shields: 5,
    isBoss: true,
    accentValue: 0xFFFF9F43,
    questions: [
      MathSquadronQuestion(
          prompt: '348 + 275 = ?',
          answers: ['613', '623', '633', '723'],
          correctAnswer: '623'),
      MathSquadronQuestion(
          prompt: '700 - 286 = ?',
          answers: ['404', '414', '424', '486'],
          correctAnswer: '414'),
      MathSquadronQuestion(
          prompt: '126 × 3 = ?',
          answers: ['368', '378', '388', '408'],
          correctAnswer: '378'),
      MathSquadronQuestion(
          prompt: '648 : 8 = ?',
          answers: ['71', '80', '81', '91'],
          correctAnswer: '81'),
      MathSquadronQuestion(
          prompt: '459 + 168 = ?',
          answers: ['617', '627', '637', '717'],
          correctAnswer: '627'),
      MathSquadronQuestion(
          prompt: '905 - 478 = ?',
          answers: ['417', '427', '437', '527'],
          correctAnswer: '427'),
      MathSquadronQuestion(
          prompt: '214 × 4 = ?',
          answers: ['816', '846', '856', '864'],
          correctAnswer: '856'),
      MathSquadronQuestion(
          prompt: '735 : 7 = ?',
          answers: ['95', '105', '115', '125'],
          correctAnswer: '105'),
    ],
  ),
  MathSquadronLevelConfig(
    level: 6,
    titleKey: AppKeys.gamesSquadronLevelSix,
    shields: 4,
    isBoss: false,
    accentValue: 0xFF5FD2FF,
    questions: [
      MathSquadronQuestion(
          prompt: '3 m = ? cm',
          answers: ['30', '300', '3000', '30000'],
          correctAnswer: '300',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '2 h = ? min',
          answers: ['60', '90', '120', '200'],
          correctAnswer: '120',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '4 kg = ? g',
          answers: ['40', '400', '4000', '40000'],
          correctAnswer: '4000',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '1 d = ? h',
          answers: ['12', '18', '24', '60'],
          correctAnswer: '24',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '5 dm = ? cm',
          answers: ['5', '50', '500', '5000'],
          correctAnswer: '50',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '250 cm = ? m ? cm',
          answers: ['2 m 5 cm', '2 m 50 cm', '25 m', '250 m'],
          correctAnswer: '2 m 50 cm',
          targetKind: MathSquadronTargetKind.crystal),
      MathSquadronQuestion(
          prompt: '3 h 15 min = ? min',
          answers: ['165', '180', '195', '315'],
          correctAnswer: '195',
          targetKind: MathSquadronTargetKind.crystal),
    ],
  ),
  MathSquadronLevelConfig(
    level: 7,
    titleKey: AppKeys.gamesSquadronLevelSeven,
    shields: 6,
    isBoss: true,
    accentValue: 0xFFFF4D9A,
    questions: [
      MathSquadronQuestion(
          prompt: '8 × 9 = ?',
          answers: ['63', '64', '72', '81'],
          correctAnswer: '72'),
      MathSquadronQuestion(
          prompt: '864 : 8 = ?',
          answers: ['98', '108', '118', '128'],
          correctAnswer: '108'),
      MathSquadronQuestion(
          prompt: 'x × 6 = 54',
          answers: ['7', '8', '9', '10'],
          correctAnswer: '9'),
      MathSquadronQuestion(
          prompt: '578 + 246 = ?',
          answers: ['814', '824', '834', '924'],
          correctAnswer: '824'),
      MathSquadronQuestion(
          prompt: '1000 - 468 = ?',
          answers: ['522', '532', '542', '632'],
          correctAnswer: '532'),
      MathSquadronQuestion(
          prompt: '5 m = ? cm',
          answers: ['50', '500', '5000', '50000'],
          correctAnswer: '500'),
      MathSquadronQuestion(
          prompt: '7 × x = 63',
          answers: ['7', '8', '9', '10'],
          correctAnswer: '9'),
      MathSquadronQuestion(
          prompt: '936 : 9 = ?',
          answers: ['94', '104', '114', '124'],
          correctAnswer: '104'),
      MathSquadronQuestion(
          prompt: '425 + 387 = ?',
          answers: ['802', '812', '822', '912'],
          correctAnswer: '812'),
      MathSquadronQuestion(
          prompt: '900 - 375 = ?',
          answers: ['515', '525', '535', '625'],
          correctAnswer: '525'),
    ],
  ),
];

MathSquadronLevelConfig mathSquadronLevel(int level) =>
    mathSquadronLevels.firstWhere(
      (config) => config.level == level,
      orElse: () => mathSquadronLevels.first,
    );
