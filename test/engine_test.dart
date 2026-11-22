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
  });
}
