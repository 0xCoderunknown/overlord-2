import 'dart:math';
import '../domain/models.dart';

class BuildingGenerator {
  final Random rng;

  BuildingGenerator({Random? random}) : rng = random ?? Random();

  Building generateBuilding({
    String id = 'bld_overlord_01',
    String name = 'Ruined Vault Facility 42',
    int floorCount = 3,
    int roomsPerFloor = 4,
    int elevatorColumn = 3, // Placed on the far right by default
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
        // Check if elevator
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

        // Entrance room: Ground floor, room 0
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

        // Random room type from pool
        final type = roomPool[rng.nextInt(roomPool.length)];

        // Decide content:
        // ~45% enemy, ~25% loot chest, ~30% empty
        final roll = rng.nextInt(100);
        ContentType contentType;
        Enemy? enemy;
        LootItem? loot;

        if (roll < 45) {
          contentType = ContentType.enemy;
          enemy = _generateEnemy(f);
        } else if (roll < 70) {
          contentType = ContentType.loot;
          loot = _generateLoot(f);
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
          loot: loot,
        ));
      }
      floors.add(Floor(floorIndex: f, rooms: rooms));
    }

    // Initial fog-of-war reveal: Entrance room is active, adjacent room is outline
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
        name: 'Mutated Vermin',
        maxHp: 20 + (floorIndex * 10),
        minDamage: 4 + (floorIndex * 2),
        maxDamage: 8 + (floorIndex * 3),
        lootDrop: rng.nextBool()
            ? LootItem(
                id: 'loot_caps_${rng.nextInt(9999)}',
                name: 'Scavenged Caps',
                caps: 5 + rng.nextInt(15),
              )
            : null,
      ),
      Enemy(
        name: 'Rogue Security Bot',
        maxHp: 35 + (floorIndex * 15),
        minDamage: 6 + (floorIndex * 3),
        maxDamage: 12 + (floorIndex * 4),
        lootDrop: rng.nextBool()
            ? LootItem(
                id: 'loot_medkit_${rng.nextInt(9999)}',
                name: 'Medical Syringe',
                healAmount: 40,
              )
            : null,
      ),
      Enemy(
        name: 'Raider Scavenger',
        maxHp: 28 + (floorIndex * 12),
        minDamage: 5 + (floorIndex * 2),
        maxDamage: 10 + (floorIndex * 3),
        lootDrop: LootItem(
          id: 'loot_pouch_${rng.nextInt(9999)}',
          name: 'Raider Pouch',
          caps: 10 + rng.nextInt(20),
        ),
      ),
    ];

    return enemies[rng.nextInt(enemies.length)];
  }

  LootItem _generateLoot(int floorIndex) {
    final loots = [
      LootItem(
        id: 'chest_caps_${rng.nextInt(9999)}',
        name: 'Cache of Caps',
        caps: 15 + rng.nextInt(35),
      ),
      LootItem(
        id: 'chest_medkit_${rng.nextInt(9999)}',
        name: 'Field Medkit',
        healAmount: 50,
      ),
      LootItem(
        id: 'chest_salvage_${rng.nextInt(9999)}',
        name: 'High-Tech Salvage',
        caps: 40 + rng.nextInt(40),
      ),
    ];

    return loots[rng.nextInt(loots.length)];
  }
}

