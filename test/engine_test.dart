import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/domain/models.dart';
import 'package:overlord_2/engine/building_generator.dart';
import 'package:overlord_2/engine/combat_engine.dart';
import 'package:overlord_2/engine/exploration_controller.dart';

void main() {
  group('BuildingGenerator Tests', () {
    test('generates valid multi-floor building with elevator column', () {
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

      expect(building.floors[0].rooms[0].state, RoomState.active);
      expect(building.floors[0].rooms[1].state, RoomState.outline);
    });

    test('generates scrap piles with items or empty junk', () {
      final generator = BuildingGenerator(random: Random(10));
      final pile = generator.generateScrapPile(0);
      expect(pile.isSearched, isFalse);
    });
  });

  group('CombatEngine Bounty & Armor Tests', () {
    test('killing enemy awards bounty gold and triggers victory', () {
      final player = ScoutCharacter(name: 'Vance', maxHp: 50);
      player.equippedWeapon = const EquipmentItem(
        id: 'w1',
        name: 'Super Gun',
        type: ItemType.weapon,
        minStat: 50,
        maxStat: 50,
      );

      final enemy = Enemy(
        name: 'Vermin',
        maxHp: 15,
        minDamage: 5,
        maxDamage: 5,
        bountyGold: 20,
      );

      final combat = CombatEngine(
        player: player,
        enemy: enemy,
        random: Random(1),
      );

      final result = combat.executeRound();
      expect(result.status, CombatStatus.victory);
      expect(enemy.isDead, isTrue);
      expect(player.gold, 20);
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
      // Net damage: 8 - 5 = 3
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
      final initialWeaponScrapVal = player.equippedWeapon.scrapValue; // 2
      final controller = ExplorationController(building: building, player: player);

      controller.moveTo(0, 1);
      expect(controller.currentRoom.hasUnsearchedScrap, isTrue);

      controller.searchScrapPile();
      expect(controller.pendingScrapItem, isNotNull);
      expect(controller.pendingScrapItem!.name, 'Shotgun');

      controller.equipPendingItem();
      expect(player.equippedWeapon.name, 'Shotgun');
      // Old weapon scrapped for its scrapValue
      expect(player.gold, initialWeaponScrapVal);
      expect(controller.pendingScrapItem, isNull);
    });

    test('scrapping found item grants its scrap value directly in gold', () {
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
                scrapPile: ScrapPile(
                  id: 's2',
                  containedItem: const EquipmentItem(
                    id: 'junk_part',
                    name: 'Copper Wire',
                    type: ItemType.consumable,
                    scrapValue: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      final player = ScoutCharacter(name: 'Vance', gold: 10);
      final controller = ExplorationController(building: building, player: player);

      controller.searchScrapPile();
      expect(controller.pendingScrapItem, isNotNull);

      controller.scrapPendingItem();
      expect(player.gold, 13);
      expect(controller.pendingScrapItem, isNull);
    });
  });
}
