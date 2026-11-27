import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/data/game_database.dart';
import 'package:overlord_2/domain/models.dart';
import 'package:overlord_2/engine/banter_engine.dart';
import 'package:overlord_2/engine/building_generator.dart';
import 'package:overlord_2/engine/combat_engine.dart';
import 'package:overlord_2/engine/exploration_controller.dart';

void main() {
  group('GameDatabase Tests', () {
    test('contains verified enemy and gear pools', () {
      expect(GameDatabase.getTier1Enemies().isNotEmpty, isTrue);
      expect(GameDatabase.getApexBosses().length, 3);
      expect(GameDatabase.getWeaponsByTier(1).isNotEmpty, isTrue);
      expect(GameDatabase.getArmorsByTier(1).isNotEmpty, isTrue);
      expect(GameDatabase.emptyRoomLore.isNotEmpty, isTrue);
    });
  });

  group('BuildingGenerator Tests', () {
    test('generates valid multi-floor building with top-floor boss chamber', () {
      final generator = BuildingGenerator(random: Random(42));
      final building = generator.generateBuilding(
        floorCount: 3,
        roomsPerFloor: 4,
        elevatorColumn: 3,
      );

      expect(building.floors.length, 3);
      for (final floor in building.floors) {
        expect(floor.rooms.length, 4);
        expect(floor.rooms[3].type, RoomType.elevator);
      }

      // Top floor should have a boss chamber at column 0 (furthest room from elevator)
      final topFloor = building.floors[2];
      expect(topFloor.rooms[0].type, RoomType.bossChamber);
      expect(topFloor.rooms[0].enemy, isNotNull);
      expect(topFloor.rooms[0].enemy!.isBoss, isTrue);

      // Ground entrance room is active with ambient lore
      expect(building.floors[0].rooms[0].state, RoomState.active);
      expect(building.floors[0].rooms[0].ambientLore, isNotNull);
    });

    test('generates scrap piles with items or empty junk', () {
      final generator = BuildingGenerator(random: Random(10));
      final pile = generator.generateScrapPile(0);
      expect(pile.isSearched, isFalse);
    });
  });

  group('CombatEngine Bounty & Armor Tests', () {
    test('killing boss awards high bounty gold', () {
      final player = ScoutCharacter(name: 'Vance', maxHp: 100);
      player.equippedWeapon = const EquipmentItem(
        id: 'w_super',
        name: 'Super Plasma',
        type: ItemType.weapon,
        minStat: 100,
        maxStat: 100,
      );

      final boss = Enemy(
        name: 'Featherless Turkey',
        maxHp: 60,
        minDamage: 15,
        maxDamage: 25,
        bountyGold: 75,
        isBoss: true,
      );

      final combat = CombatEngine(
        player: player,
        enemy: boss,
        random: Random(1),
      );

      final result = combat.executeRound();
      expect(result.status, CombatStatus.victory);
      expect(boss.isDead, isTrue);
      expect(player.gold, 75);
    });

    test('armor absorbs incoming enemy damage', () {
      final player = ScoutCharacter(name: 'Vance', maxHp: 100);
      player.equippedArmor = const EquipmentItem(
        id: 'arm_heavy',
        name: 'Heavy Plate',
        type: ItemType.armor,
        minStat: 5,
        maxStat: 5,
      );

      final enemy = Enemy(name: 'Drone', maxHp: 100, minDamage: 8, maxDamage: 8);
      final combat = CombatEngine(
        player: player,
        enemy: enemy,
        random: Random(1),
      );

      final result = combat.executeRound();
      expect(result.damageAbsorbedByArmor, 5);
      expect(result.enemyDamageDealt, 3);
      expect(player.currentHp, 97);
    });
  });

  group('ExplorationController Scrap & Equip/Scrap Tests', () {
    test('searching scrap pile adds found item straight to backpack and empty scrap logs a quip', () {
      final building = Building(
        id: 'b1',
        name: 'Test',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.storage,
                contentType: ContentType.scrap,
                state: RoomState.outline,
                scrapPile: ScrapPile(
                  id: 's1',
                  containedItem: const EquipmentItem(
                    id: 'w_shotgun',
                    name: 'Shotgun',
                    type: ItemType.weapon,
                    minStat: 15,
                    maxStat: 20,
                    scrapValue: 5,
                  ),
                ),
              ),
              Room(
                floorIndex: 0,
                roomIndex: 2,
                type: RoomType.office,
                contentType: ContentType.scrap,
                state: RoomState.outline,
                scrapPile: ScrapPile(id: 's2', containedItem: null),
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', gold: 0);
      final controller = ExplorationController(building: building, player: player);

      controller.moveTo(0, 1);
      expect(controller.currentRoom.hasUnsearchedScrap, isTrue);

      controller.searchScrapPile();
      expect(player.backpack.length, 1);
      expect(player.backpack.first.name, 'Shotgun');
      expect(controller.lastEventLog, contains('Shotgun'));
      expect(controller.lastEventLog, contains('backpack'));
      expect(controller.scrapBannerText, '+ SHOTGUN');

      // Empty scrap pile should still produce a hero quip
      controller.moveTo(0, 2);
      controller.searchScrapPile();
      expect(player.backpack.length, 1);
      expect(controller.lastEventLog, isNotNull);
      expect(controller.lastEventLog, isNotEmpty);
      expect(controller.scrapBannerText, 'EMPTY JUNK');
    });

    test('BanterEngine produces two-way exchanges for animals, ghouls, humans, robots, bosses, and tracks roundCount', () {
      final rat = Enemy(name: 'Mutated Rat', maxHp: 16, minDamage: 2, maxDamage: 6);
      final ghoul = Enemy(name: 'Feral Ghoul Pack', maxHp: 44, minDamage: 8, maxDamage: 16);
      final raider = Enemy(name: 'Raider Enforcer', maxHp: 38, minDamage: 8, maxDamage: 14);
      final mech = Enemy(name: 'Pre-War Battlemech', maxHp: 90, minDamage: 18, maxDamage: 28, isBoss: true);
      final behemoth = Enemy(name: 'Irradiated Behemoth', maxHp: 85, minDamage: 20, maxDamage: 32, isBoss: true);

      final animalEx1 = BanterEngine.buildExchange(enemy: rat, round: 1, isLowHp: false, seed: 1);
      final animalEx2 = BanterEngine.buildExchange(enemy: rat, round: 2, isLowHp: false, seed: 1);
      final animalEx3 = BanterEngine.buildExchange(enemy: rat, round: 3, isLowHp: false, seed: 1);
      expect(animalEx1.enemyLine, isNotEmpty);
      expect({animalEx1.heroLine, animalEx2.heroLine, animalEx3.heroLine}.length, 3);

      expect(BanterEngine.classify(ghoul), EnemySpeakerKind.ghoul);
      final ghoulEx = BanterEngine.buildExchange(enemy: ghoul, round: 1, isLowHp: false, seed: 0);
      expect(ghoulEx.enemyLine, startsWith('*'));

      final humanEx = BanterEngine.buildExchange(enemy: raider, round: 1, isLowHp: false, seed: 0);
      expect(humanEx.enemyLine, isNot('.....'));
      expect(humanEx.heroLine, isNotEmpty);

      expect(BanterEngine.classify(mech), EnemySpeakerKind.robot);
      final mechEx = BanterEngine.buildExchange(enemy: mech, round: 1, isLowHp: false, seed: 0);
      expect(mechEx.enemyLine, startsWith('['));

      final bossLowEx = BanterEngine.buildExchange(enemy: behemoth, round: 2, isLowHp: true, seed: 0);
      expect(bossLowEx.heroLine, contains('Bleeding'));

      final player = ScoutCharacter(name: 'Vance');
      final combat = CombatEngine(player: player, enemy: Enemy(name: 'Scrapper', maxHp: 100, minDamage: 1, maxDamage: 2), random: Random(7));
      expect(combat.roundCount, 0);
      combat.executeRound();
      expect(combat.roundCount, 1);
      combat.executeRound();
      expect(combat.roundCount, 2);
    });

    test('equipFromBackpack swaps gear and resolveRoomEvent unlocks safe with key and medCabinet', () {
      final building = Building(
        id: 'b_events',
        name: 'Test Events',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.office,
                contentType: ContentType.empty,
                state: RoomState.outline,
                eventType: RoomEventType.lockedSafe,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 2,
                type: RoomType.clinic,
                contentType: ContentType.empty,
                state: RoomState.outline,
                eventType: RoomEventType.medCabinet,
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', keys: 1, medkits: 1);
      final oldWpnName = player.equippedWeapon.name;
      player.backpack.add(
        const EquipmentItem(
          id: 'w_rifle',
          name: 'Service Rifle',
          type: ItemType.weapon,
          minStat: 16,
          maxStat: 26,
          scrapValue: 10,
        ),
      );

      final controller = ExplorationController(building: building, player: player);

      // Swap weapon from backpack
      controller.equipFromBackpack(0);
      expect(player.equippedWeapon.name, 'Service Rifle');
      expect(player.backpack.first.name, oldWpnName);

      // Unlock safe with key
      controller.moveTo(0, 1);
      expect(controller.currentRoom.hasUnresolvedEvent, isTrue);
      controller.resolveRoomEvent(useKey: true);
      expect(player.keys, 0);
      expect(player.gold, 15);
      expect(controller.currentRoom.hasUnresolvedEvent, isFalse);

      // Med cabinet grants medkit + crafting material
      controller.moveTo(0, 2);
      final bagBefore = player.backpack.length;
      controller.resolveRoomEvent();
      expect(player.medkits, 2);
      expect(player.backpack.length, bagBefore + 1);
      expect(
        player.backpack.last.consumableEffect,
        ConsumableEffect.material,
      );
      expect(controller.currentRoom.hasUnresolvedEvent, isFalse);
    });

    test('useStealthboy bypasses non-boss hostile room and unlocks adjacent rooms', () {
      final grunt = Enemy(
        name: 'Raider Enforcer',
        maxHp: 38,
        minDamage: 8,
        maxDamage: 14,
      );
      final boss = Enemy(
        name: 'Featherless Turkey',
        maxHp: 75,
        minDamage: 16,
        maxDamage: 24,
        isBoss: true,
      );
      final building = Building(
        id: 'b_stealth',
        name: 'Test Stealth',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.corridor,
                contentType: ContentType.enemy,
                state: RoomState.outline,
                enemy: grunt,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 2,
                type: RoomType.bossChamber,
                contentType: ContentType.enemy,
                state: RoomState.unrevealed,
                enemy: boss,
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', stealthboys: 2);
      final controller = ExplorationController(building: building, player: player);

      controller.moveTo(0, 1);
      expect(controller.canUseStealthboy, isTrue);
      controller.useStealthboy();

      expect(player.stealthboys, 1);
      expect(controller.activeCombat, isNull);
      expect(controller.currentRoom.isBypassed, isTrue);
      expect(controller.currentRoom.state, RoomState.cleared);
      expect(building.floors[0].rooms[2].state, RoomState.outline);

      // Cannot stealth past Apex Boss
      controller.moveTo(0, 2);
      expect(controller.canUseStealthboy, isFalse);
      controller.dispose();
    });

    test('Fallout food works out of combat, is blocked in combat, and autoEquipBest upgrades gear', () {
      final building = Building(
        id: 'b_food',
        name: 'Test Food',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.corridor,
                contentType: ContentType.enemy,
                state: RoomState.outline,
                enemy: Enemy(name: 'Mutated Rat', maxHp: 50, minDamage: 1, maxDamage: 2),
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', maxHp: 100);
      player.currentHp = 60;
      player.backpack.add(GameDatabase.foods.first); // Purified Water (+15 HP, 0% risk)
      player.backpack.add(
        const EquipmentItem(
          id: 'w_plasma',
          name: 'Plasma Torch',
          type: ItemType.weapon,
          minStat: 22,
          maxStat: 34,
          scrapValue: 15,
        ),
      );

      final controller = ExplorationController(building: building, player: player);

      // Out of combat: eat Purified Water
      controller.equipFromBackpack(0);
      expect(player.currentHp, 75);

      // Auto-equip best weapon
      controller.autoEquipBest();
      expect(player.equippedWeapon.name, 'Plasma Torch');

      // In combat: eating food is blocked
      player.backpack.add(GameDatabase.foods.first);
      controller.moveTo(0, 1);
      final bagBefore = player.backpack.length;
      controller.equipFromBackpack(player.backpack.length - 1);
      expect(player.backpack.length, bagBefore);
      expect(controller.lastEventLog, contains('swinging'));
      controller.dispose();
    });

    test('ambient lore is displayed when moving into empty rooms', () {
      final building = Building(
        id: 'b1',
        name: 'Test',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.office,
                contentType: ContentType.empty,
                state: RoomState.outline,
                ambientLore: 'The radiation meter is clicking rhythmically.',
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance');
      final controller = ExplorationController(building: building, player: player);

      controller.moveTo(0, 1);
      expect(controller.lastEventLog, 'The radiation meter is clicking rhythmically.');
    });

    test('emergency heal is strictly locked until HP drops to 25% or lower', () {
      final building = Building(
        id: 'b1',
        name: 'Test',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', maxHp: 100, medkits: 1);
      final controller = ExplorationController(building: building, player: player);

      // At 100 HP (> 25%), heal is locked
      expect(player.canEmergencyHeal, isFalse);
      controller.useMedkit();
      expect(player.medkits, 1);
      expect(player.currentHp, 100);

      // At 26 HP (> 25%), heal is still locked
      player.currentHp = 26;
      expect(player.canEmergencyHeal, isFalse);
      controller.useMedkit();
      expect(player.medkits, 1);
      expect(player.currentHp, 26);

      // At 25 HP (<= 25%), emergency heal is unlocked
      player.currentHp = 25;
      expect(player.canEmergencyHeal, isTrue);
      controller.useMedkit();
      expect(player.medkits, 0);
      expect(player.currentHp, 75); // 25 + 50
    });

    test('scout orientation and facing direction updates based on entry direction', () {
      final building = Building(
        id: 'b_orient',
        name: 'Test Orientation',
        floors: [
          Floor(
            floorIndex: 0,
            rooms: [
              Room(
                floorIndex: 0,
                roomIndex: 0,
                type: RoomType.entrance,
                contentType: ContentType.empty,
                state: RoomState.active,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 1,
                type: RoomType.storage,
                contentType: ContentType.empty,
                state: RoomState.outline,
              ),
              Room(
                floorIndex: 0,
                roomIndex: 2,
                type: RoomType.office,
                contentType: ContentType.empty,
                state: RoomState.outline,
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance');
      final controller = ExplorationController(building: building, player: player);

      // Starting at room 0: on left, facing right
      expect(controller.isScoutOnLeft, isTrue);
      expect(controller.isScoutFacingRight, isTrue);

      // Moving right to room 1: enters on left, faces right towards room interior
      controller.moveTo(0, 1);
      expect(controller.isScoutOnLeft, isTrue);
      expect(controller.isScoutFacingRight, isTrue);

      // Moving right to room 2: enters on left, faces right
      controller.moveTo(0, 2);
      expect(controller.isScoutOnLeft, isTrue);
      expect(controller.isScoutFacingRight, isTrue);

      // Moving left back to room 1: enters from right, stands on right, faces left
      controller.moveTo(0, 1);
      expect(controller.isScoutOnLeft, isFalse);
      expect(controller.isScoutFacingRight, isFalse);
    });

    test('backtracking through cleared rooms allows returning to elevator and ascending floors', () {
      final generator = BuildingGenerator(random: Random(42));
      final building = generator.generateBuilding(
        floorCount: 3,
        roomsPerFloor: 4,
        elevatorColumn: 3,
      );
      final player = ScoutCharacter(name: 'Vance', maxHp: 100);
      player.equippedWeapon = const EquipmentItem(
        id: 'w_test_cannon',
        name: 'Test Heavy Blaster',
        type: ItemType.weapon,
        minStat: 500,
        maxStat: 500,
      );
      final controller = ExplorationController(building: building, player: player);

      void moveAndClear(int floor, int room) {
        expect(controller.moveTo(floor, room), isTrue);
        if (controller.currentRoom.hasUnresolvedEnemy) {
          controller.executeCombatRound();
          expect(controller.currentRoom.hasUnresolvedEnemy, isFalse);
        }
      }

      // Floor 1: Move right through rooms 0 -> 1 -> 2 -> 3 (Elevator)
      moveAndClear(0, 1);
      moveAndClear(0, 2);
      moveAndClear(0, 3);
      expect(controller.currentRoom.isElevator, isTrue);

      // Take elevator up to Floor 2 (floorIndex 1)
      expect(controller.canMoveTo(1, 3), isTrue);
      moveAndClear(1, 3);
      expect(controller.currentFloorIndex, 1);
      expect(controller.currentRoomIndex, 3);

      // Floor 2: Move left through rooms 3 -> 2 -> 1 -> 0, clearing any hostiles
      moveAndClear(1, 2);
      moveAndClear(1, 1);
      moveAndClear(1, 0);
      expect(controller.currentRoomIndex, 0);

      // At dead-end Room 0: verify player can freely backtrack through cleared rooms
      expect(controller.canMoveTo(1, 1), isTrue, reason: 'Cleared Room 1 must allow backtracking');
      expect(controller.moveTo(1, 1), isTrue);

      expect(controller.canMoveTo(1, 2), isTrue, reason: 'Cleared Room 2 must allow backtracking');
      expect(controller.moveTo(1, 2), isTrue);

      expect(controller.canMoveTo(1, 3), isTrue, reason: 'Cleared Elevator must allow backtracking');
      expect(controller.moveTo(1, 3), isTrue);
      expect(controller.currentRoom.isElevator, isTrue);

      // Now back at Floor 2 Elevator: verify elevator can ascend to Floor 3 (floorIndex 2)
      expect(controller.canMoveTo(2, 3), isTrue, reason: 'Elevator must allow ascension to Floor 3');
      expect(controller.moveTo(2, 3), isTrue);
      expect(controller.currentFloorIndex, 2);
      expect(controller.currentRoomIndex, 3);
    });

    test('initial death states are clean and defeat screen is gated behind death cycle', () {
      final building = BuildingGenerator().generateBuilding(floorCount: 1, roomsPerFloor: 2, elevatorColumn: 1);
      final player = ScoutCharacter(name: 'Vance');
      final controller = ExplorationController(building: building, player: player);

      expect(controller.isEnemyLyingOnGround, isFalse);
      expect(controller.isHeroLyingOnGround, isFalse);
      expect(controller.isDefeatScreenVisible, isFalse);
    });
  });
}
