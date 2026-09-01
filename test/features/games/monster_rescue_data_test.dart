import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/games/domain/models/monster_rescue/monster_rescue_data.dart';

void main() {
  test('rescue gates transform the visible team size', () {
    const addGate = RescueGate(RescueOperation.add, 3);
    const multiplyGate = RescueGate(RescueOperation.multiply, 2);

    expect(addGate.apply(4), 7);
    expect(multiplyGate.apply(4), 8);
    expect(addGate.label, '+3');
    expect(multiplyGate.label, '×2');
  });

  test('vertical slice has one complete rescue mission', () {
    expect(monsterRescueLevels, hasLength(1));
    final mission = monsterRescueLevels.single;
    expect(mission.choices, hasLength(2));
    expect(mission.startingTeam, greaterThan(mission.bridgeTeam));
    expect(mission.creatureAsset, contains('numi-electric-rescue'));
  });
}
