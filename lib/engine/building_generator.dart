import 'dart:math';
import '../data/game_database.dart';
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
    int bountyMultiplier = 1,
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
      final isTopFloor = f == floorCount - 1;

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

        // Entrance Room: Ground Floor, Room 0
        if (f == 0 && r == 0) {
          rooms.add(Room(
            floorIndex: f,
            roomIndex: r,
            type: RoomType.entrance,
            contentType: ContentType.empty,
            state: RoomState.active,
            ambientLore: 'Bunker airlock seals behind you. Mission initiated.',
          ));
          continue;
        }

        // Apex Boss Chamber on top floor furthest from the elevator (r == 0 when elevator is on right)
        final bossCol = elevatorColumn == 0 ? roomsPerFloor - 1 : 0;
        if (isTopFloor && r == bossCol) {
          final boss = _rollBoss(bountyMultiplier: bountyMultiplier);
          rooms.add(Room(
            floorIndex: f,
            roomIndex: r,
            type: RoomType.bossChamber,
            contentType: ContentType.enemy,
            state: RoomState.unrevealed,
            enemy: boss,
            ambientLore: 'Heavy structural tremors. An apex threat guards the sector.',
          ));
          continue;
        }

        final type = roomPool[rng.nextInt(roomPool.length)];
        final roll = rng.nextInt(100);
        ContentType contentType;
        Enemy? enemy;
        ScrapPile? scrapPile;
        String? ambient;
        RoomEventType eventType = RoomEventType.none;

        if (roll < 45) {
          contentType = ContentType.enemy;
          enemy = _rollEnemyForFloor(f, bountyMultiplier: bountyMultiplier);
        } else if (roll < 70) {
          contentType = ContentType.scrap;
          scrapPile = generateScrapPile(f);
        } else {
          contentType = ContentType.empty;
          ambient = _pickIndoorLore(type, rng);
          final evRoll = rng.nextInt(100);
          if (type == RoomType.clinic && evRoll < 40) {
            eventType = RoomEventType.medCabinet;
          } else if (evRoll < 25) {
            eventType = RoomEventType.lockedSafe;
          } else if (evRoll < 42) {
            eventType = RoomEventType.tripwire;
          }
        }

        rooms.add(Room(
          floorIndex: f,
          roomIndex: r,
          type: type,
          contentType: contentType,
          state: RoomState.unrevealed,
          enemy: enemy,
          scrapPile: scrapPile,
          ambientLore: ambient,
          eventType: eventType,
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

  String _pickIndoorLore(RoomType type, Random rng) {
    final pool = GameDatabase.getIndoorLorePool(type);
    return '"${pool[rng.nextInt(pool.length)]}"';
  }

  Enemy _rollEnemyForFloor(int floorIndex, {int bountyMultiplier = 1}) {
    List<Enemy> pool;
    if (floorIndex == 0) {
      pool = GameDatabase.getTier1Enemies();
    } else if (floorIndex == 1) {
      pool = GameDatabase.getTier2Enemies();
    } else {
      pool = GameDatabase.getTier3Enemies();
    }

    final template = pool[rng.nextInt(pool.length)];
    return Enemy(
      name: template.name,
      maxHp: template.maxHp,
      minDamage: template.minDamage,
      maxDamage: template.maxDamage,
      bountyGold: template.bountyGold * bountyMultiplier,
      isBoss: template.isBoss,
      description: template.description,
    );
  }

  Enemy _rollBoss({int bountyMultiplier = 1}) {
    final bosses = GameDatabase.getApexBosses();
    final template = bosses[rng.nextInt(bosses.length)];
    return Enemy(
      name: template.name,
      maxHp: template.maxHp,
      minDamage: template.minDamage,
      maxDamage: template.maxDamage,
      bountyGold: template.bountyGold * bountyMultiplier,
      isBoss: true,
      description: template.description,
    );
  }

  ScrapPile generateScrapPile(int floorIndex) {
    // 25% chance to find loot in scrap pile
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

  EquipmentItem rollSafeLoot(int floorIndex) {
    return _rollScrapItem(min(2, floorIndex + 1));
  }

  EquipmentItem rollCraftingMaterial() {
    final mats = GameDatabase.craftingMaterials;
    return mats[rng.nextInt(mats.length)];
  }

  EquipmentItem _rollScrapItem(int floorIndex) {
    final roll = rng.nextInt(100);
    final tier = min(3, floorIndex + 1);

    // 35% Weapon, 25% Armor, 20% Consumable, 20% Medbay Material
    if (roll < 35) {
      final weapons = GameDatabase.getWeaponsByTier(tier);
      return weapons[rng.nextInt(weapons.length)];
    } else if (roll < 60) {
      final armors = GameDatabase.getArmorsByTier(tier);
      return armors[rng.nextInt(armors.length)];
    } else if (roll < 80) {
      final consumables = GameDatabase.consumables;
      return consumables[rng.nextInt(consumables.length)];
    } else {
      return rollCraftingMaterial();
    }
  }
}
