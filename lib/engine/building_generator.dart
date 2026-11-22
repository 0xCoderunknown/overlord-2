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

        // Apex Boss Chamber on top floor right before elevator
        if (isTopFloor && r == elevatorColumn - 1) {
          final boss = _rollBoss();
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

        if (roll < 45) {
          contentType = ContentType.enemy;
          enemy = _rollEnemyForFloor(f);
        } else if (roll < 70) {
          contentType = ContentType.scrap;
          scrapPile = generateScrapPile(f);
        } else {
          contentType = ContentType.empty;
          ambient = GameDatabase.emptyRoomLore[rng.nextInt(GameDatabase.emptyRoomLore.length)];
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

  Enemy _rollEnemyForFloor(int floorIndex) {
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
      bountyGold: template.bountyGold,
      isBoss: template.isBoss,
      description: template.description,
    );
  }

  Enemy _rollBoss() {
    final bosses = GameDatabase.getApexBosses();
    final template = bosses[rng.nextInt(bosses.length)];
    return Enemy(
      name: template.name,
      maxHp: template.maxHp,
      minDamage: template.minDamage,
      maxDamage: template.maxDamage,
      bountyGold: template.bountyGold,
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

  EquipmentItem _rollScrapItem(int floorIndex) {
    final roll = rng.nextInt(100);
    final tier = min(3, floorIndex + 1);

    // 40% Weapon, 30% Armor, 30% Consumable
    if (roll < 40) {
      final weapons = GameDatabase.getWeaponsByTier(tier);
      return weapons[rng.nextInt(weapons.length)];
    } else if (roll < 70) {
      final armors = GameDatabase.getArmorsByTier(tier);
      return armors[rng.nextInt(armors.length)];
    } else {
      final consumables = GameDatabase.consumables;
      return consumables[rng.nextInt(consumables.length)];
    }
  }
}
