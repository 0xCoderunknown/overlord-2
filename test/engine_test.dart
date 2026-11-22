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

      // Ground entrance room is active
      expect(building.floors[0].rooms[0].state, RoomState.active);
      // Adjacent room is outline (discovered)
      expect(building.floors[0].rooms[1].state, RoomState.outline);
      // Further rooms are unrevealed
      expect(building.floors[0].rooms[2].state, RoomState.unrevealed);
    });
  });

  group('ExplorationController Fog-of-War & Traversal Tests', () {
    test('traversal reveals adjacent rooms and updates room states', () {
      final generator = BuildingGenerator(random: Random(42));
      final building = generator.generateBuilding(
        floorCount: 2,
        roomsPerFloor: 4,
        elevatorColumn: 3,
      );
      final player = ScoutCharacter(name: 'TestScout', maxHp: 100);
      final controller = ExplorationController(building: building, player: player);

      expect(controller.currentFloorIndex, 0);
      expect(controller.currentRoomIndex, 0);

      // Cannot move to unrevealed room 2
      expect(controller.canMoveTo(0, 2), isFalse);
      // Can move to outline room 1
      expect(controller.canMoveTo(0, 1), isTrue);

      // Move to room 1
      final moved = controller.moveTo(0, 1);
      expect(moved, isTrue);
      expect(controller.currentRoomIndex, 1);
      expect(building.floors[0].rooms[0].state, RoomState.cleared);
      expect(building.floors[0].rooms[1].state, RoomState.active);
      // Room 2 should now be outlined
      expect(building.floors[0].rooms[2].state, RoomState.outline);
    });

    test('elevator transit moves vertically between floors', () {
      final generator = BuildingGenerator(random: Random(42));
      final building = generator.generateBuilding(
        floorCount: 2,
        roomsPerFloor: 4,
        elevatorColumn: 1, // place elevator at column 1 for easy testing
      );
      final player = ScoutCharacter(name: 'TestScout');
      final controller = ExplorationController(building: building, player: player);

      // Move into elevator at (0, 1)
      expect(controller.moveTo(0, 1), isTrue);
      expect(controller.currentRoom.isElevator, isTrue);

      // Elevator on floor 1 should now be outlined
      expect(building.floors[1].rooms[1].state, RoomState.outline);
      expect(controller.canMoveTo(1, 1), isTrue);

      // Ride elevator up to Floor 1
      expect(controller.moveTo(1, 1), isTrue);
      expect(controller.currentFloorIndex, 1);
      expect(controller.currentRoomIndex, 1);
    });
  });

  group('CombatEngine 1v1 Tests', () {
    test('resolves round damage and handles victory', () {
      final player = ScoutCharacter(name: 'Vance', maxHp: 50, minDamage: 20, maxDamage: 20);
      final enemy = Enemy(
        name: 'Vermin',
        maxHp: 15,
        minDamage: 5,
        maxDamage: 5,
        lootDrop: const LootItem(id: 'c1', name: 'Caps', caps: 10),
      );

      final combat = CombatEngine(
        player: player,
        enemy: enemy,
        random: Random(1),
      );

      expect(combat.status, CombatStatus.inProgress);
      final result = combat.executeRound();

      expect(result.status, CombatStatus.victory);
      expect(enemy.isDead, isTrue);
      expect(player.caps, 10);
    });

    test('medkit heals player', () {
      final player = ScoutCharacter(name: 'Vance', maxHp: 100, medkits: 1);
      player.currentHp = 30;

      final enemy = Enemy(name: 'Bot', maxHp: 50, minDamage: 5, maxDamage: 5);
      final combat = CombatEngine(player: player, enemy: enemy);

      final used = combat.useMedkit();
      expect(used, isTrue);
      expect(player.currentHp, 80);
      expect(player.medkits, 0);
    });
  });
}

