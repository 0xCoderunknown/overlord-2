import 'dart:math';
import '../domain/models.dart';

class BuildingGenerator {
  final Random rng;

  BuildingGenerator({Random? random}) : rng = random ?? Random();

  Building generateBuilding({
    String id = 'bld_sector_01',
    String name = 'Vault Sector Facility 42',
    int floorCount = 3,
    int roomsPerFloor = 4,
    int elevatorColumn = 3,
  }) {
    final floors = <Floor>[];

    final roomPool = [
      RoomType.office,
      RoomType.clinic,
      RoomType.generator,
      RoomType.storage,
      RoomType.corridor,
    ];

    for (int f = 0; f < floorCount; f++) {
      final rooms = <Room>[];
      for (int r = 0; r < roomsPerFloor; r++) {
        // Elevator Shaft
        if (r == elevatorColumn) {
          rooms.add(Room(
            floorIndex: f,
            roomIndex: r,
            type: RoomType.elevator,
            contentType: ContentType.elevator,
            state: RoomState.unrevealed,
          ));
          continue;
        }

        // Entrance Room: Floor 0, Room 0
        if (f == 0 && r == 0) {
          rooms.add(Room(
            floorIndex: f,
            roomIndex: r,
            type: RoomType.entrance,
            contentType: ContentType.empty,
            state: RoomState.active,
          ));
          continue;
        }

        final type = roomPool[rng.nextInt(roomPool.length)];
        final roll = rng.nextInt(100);
        ContentType contentType;
        Enemy? enemy;
        ScrapPile? scrapPile;

        if (roll < 45) {
          contentType = ContentType.enemy;
          enemy = _generateEnemy(f);
        } else if (roll < 70) {
          contentType = ContentType.scrap;
          scrapPile = generateScrapPile(f);
        } else {
          contentType = ContentType.empty;
        }

        rooms.add(Room(
          floorIndex: f,
          roomIndex: r,
          type: type,
          contentType: contentType,
          state: RoomState.unrevealed,
          enemy: enemy,
          scrapPile: scrapPile,
        ));
      }
      floors.add(Floor(floorIndex: f, rooms: rooms));
    }

    // Reveal entrance neighbor
    if (floors.isNotEmpty && floors[0].rooms.length > 1) {
      floors[0].rooms[1].state = RoomState.outline;
    }

    return Building(
      id: id,
      name: name,
      floors: floors,
    );
  }

  Enemy _generateEnemy(int floorIndex) {
    final enemies = [
      Enemy(
        name: 'Irradiated Scav-Rat',
        maxHp: 18 + (floorIndex * 8),
        minDamage: 4 + (floorIndex * 2),
        maxDamage: 7 + (floorIndex * 2),
        bountyGold: 8 + rng.nextInt(6),
      ),
      Enemy(
        name: 'Rogue Sentry Drone',
        maxHp: 30 + (floorIndex * 12),
        minDamage: 6 + (floorIndex * 3),
        maxDamage: 11 + (floorIndex * 3),
        bountyGold: 15 + rng.nextInt(10),
      ),
      Enemy(
        name: 'Raider Marauder',
        maxHp: 26 + (floorIndex * 10),
        minDamage: 5 + (floorIndex * 2),
        maxDamage: 10 + (floorIndex * 3),
        bountyGold: 12 + rng.nextInt(8),
      ),
    ];

    return enemies[rng.nextInt(enemies.length)];
  }

  ScrapPile generateScrapPile(int floorIndex) {
    // 25% chance to find an item in the scrap pile
    final hasLoot = rng.nextInt(100) < 25;
    EquipmentItem? item;

    if (hasLoot) {
      item = _rollScrapItem(floorIndex);
    }

    return ScrapPile(
      id: 'scrap_${rng.nextInt(999999)}',
      containedItem: item,
    );
  }

  EquipmentItem _rollScrapItem(int floorIndex) {
    final roll = rng.nextInt(100);

    // 40% Weapon, 30% Armor, 30% Consumable
    if (roll < 40) {
      final weapons = [
        EquipmentItem(
          id: 'wpn_nailgun_${rng.nextInt(999)}',
          name: 'Modified Nailgun',
          type: ItemType.weapon,
          minStat: 8 + floorIndex * 2,
          maxStat: 14 + floorIndex * 3,
          scrapValue: 3,
          description: 'Pneumatic piston shoots sharpened iron nails.',
        ),
        EquipmentItem(
          id: 'wpn_shotgun_${rng.nextInt(999)}',
          name: 'Sawed-Off Shotgun',
          type: ItemType.weapon,
          minStat: 12 + floorIndex * 3,
          maxStat: 18 + floorIndex * 4,
          scrapValue: 5,
          description: 'Devastating close-range scatter blast.',
        ),
        EquipmentItem(
          id: 'wpn_rebar_${rng.nextInt(999)}',
          name: 'Welded Rebar Club',
          type: ItemType.weapon,
          minStat: 9 + floorIndex * 2,
          maxStat: 15 + floorIndex * 3,
          scrapValue: 3,
          description: 'Concrete block affixed to rusted rebar.',
        ),
      ];
      return weapons[rng.nextInt(weapons.length)];
    } else if (roll < 70) {
      final armors = [
        EquipmentItem(
          id: 'arm_leather_${rng.nextInt(999)}',
          name: 'Boiled Leather Vest',
          type: ItemType.armor,
          minStat: 3 + floorIndex,
          maxStat: 6 + floorIndex,
          scrapValue: 3,
          description: 'Toughened leather stops claws and small blades.',
        ),
        EquipmentItem(
          id: 'arm_scrap_${rng.nextInt(999)}',
          name: 'Welded Scrap Plate',
          type: ItemType.armor,
          minStat: 5 + floorIndex * 2,
          maxStat: 9 + floorIndex * 2,
          scrapValue: 5,
          description: 'Heavy road signs riveted to a chest plate.',
        ),
      ];
      return armors[rng.nextInt(armors.length)];
    } else {
      final consumables = [
        const EquipmentItem(
          id: 'c_medkit',
          name: 'Military Medkit',
          type: ItemType.consumable,
          consumableEffect: ConsumableEffect.heal,
          scrapValue: 2,
          description: 'Sterile bandage and coagulant stimulant (+50 HP).',
        ),
        const EquipmentItem(
          id: 'c_psycho',
          name: 'Combat Psycho Chem',
          type: ItemType.consumable,
          consumableEffect: ConsumableEffect.psycho,
          scrapValue: 3,
          description: 'Violent adrenaline surge (+6 DMG for combat).',
        ),
        const EquipmentItem(
          id: 'c_stealthboy',
          name: 'Stealthboy Cloak Unit',
          type: ItemType.consumable,
          consumableEffect: ConsumableEffect.stealth,
          scrapValue: 4,
          description: 'Reflective optical unit allowing silent bypass.',
        ),
        const EquipmentItem(
          id: 'c_key',
          name: 'Security Master Key',
          type: ItemType.consumable,
          consumableEffect: ConsumableEffect.key,
          scrapValue: 2,
          description: 'Heavy brass key opens reinforced bunker safes.',
        ),
      ];
      return consumables[rng.nextInt(consumables.length)];
    }
  }
}
