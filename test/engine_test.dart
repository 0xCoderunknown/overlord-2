import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/data/game_database.dart';
import 'package:overlord_2/domain/models.dart';
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

      // Top floor should have a boss chamber at column 2 (elevatorColumn - 1)
      final topFloor = building.floors[2];
      expect(topFloor.rooms[2].type, RoomType.bossChamber);
      expect(topFloor.rooms[2].enemy, isNotNull);
      expect(topFloor.rooms[2].enemy!.isBoss, isTrue);

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
    test('searching scrap pile and equipping weapon scraps old weapon for gold', () {
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
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', gold: 0);
      final initialWeaponScrapVal = player.equippedWeapon.scrapValue;
      final controller = ExplorationController(building: building, player: player);

      controller.moveTo(0, 1);
      expect(controller.currentRoom.hasUnsearchedScrap, isTrue);

      controller.searchScrapPile();
      expect(controller.pendingScrapItem, isNotNull);
      expect(controller.pendingScrapItem!.name, 'Shotgun');

      controller.equipPendingItem();
      expect(player.equippedWeapon.name, 'Shotgun');
      expect(player.gold, initialWeaponScrapVal);
      expect(controller.pendingScrapItem, isNull);
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
  });
}
