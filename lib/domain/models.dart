import 'dart:math';

enum RoomType {
  entrance,
  corridor,
  office,
  clinic,
  generator,
  storage,
  elevator,
}

enum RoomState {
  unrevealed,     // Blacked out (fog of war)
  outline,        // Discovered, adjacent to cleared room, tap to move
  active,         // Squad/Scout is inside
  cleared,        // Explored and resolved
}

enum ContentType {
  empty,
  loot,
  enemy,
  elevator,
}

class LootItem {
  final String id;
  final String name;
  final int caps;
  final int healAmount;

  const LootItem({
    required this.id,
    required this.name,
    this.caps = 0,
    this.healAmount = 0,
  });
}

class Enemy {
  final String name;
  final int maxHp;
  int currentHp;
  final int minDamage;
  final int maxDamage;
  final LootItem? lootDrop;

  Enemy({
    required this.name,
    required this.maxHp,
    required this.minDamage,
    required this.maxDamage,
    this.lootDrop,
  }) : currentHp = maxHp;

  bool get isDead => currentHp <= 0;

  int rollDamage(Random rng) {
    return minDamage + rng.nextInt(maxDamage - minDamage + 1);
  }
}

class ScoutCharacter {
  final String name;
  final int maxHp;
  int currentHp;
  final int minDamage;
  final int maxDamage;
  int caps;
  int medkits;

  ScoutCharacter({
    required this.name,
    this.maxHp = 100,
    this.minDamage = 8,
    this.maxDamage = 16,
    this.caps = 0,
    this.medkits = 1,
  }) : currentHp = maxHp;

  bool get isDead => currentHp <= 0;

  int rollDamage(Random rng) {
    return minDamage + rng.nextInt(maxDamage - minDamage + 1);
  }

  void heal(int amount) {
    currentHp = min(maxHp, currentHp + amount);
  }
}

class Room {
  final int floorIndex;
  final int roomIndex;
  final RoomType type;
  final ContentType contentType;
  RoomState state;
  final Enemy? enemy;
  final LootItem? loot;
  bool isLootClaimed;

  Room({
    required this.floorIndex,
    required this.roomIndex,
    required this.type,
    required this.contentType,
    this.state = RoomState.unrevealed,
    this.enemy,
    this.loot,
    this.isLootClaimed = false,
  });

  bool get isElevator => type == RoomType.elevator;
  bool get hasUnresolvedEnemy => enemy != null && !enemy!.isDead;
  bool get hasUnclaimedLoot => loot != null && !isLootClaimed;
}

class Floor {
  final int floorIndex;
  final List<Room> rooms;

  const Floor({
    required this.floorIndex,
    required this.rooms,
  });
}

class Building {
  final String id;
  final String name;
  final List<Floor> floors;

  const Building({
    required this.id,
    required this.name,
    required this.floors,
  });

  Room? getRoom(int floorIndex, int roomIndex) {
    if (floorIndex < 0 || floorIndex >= floors.length) return null;
    final floor = floors[floorIndex];
    if (roomIndex < 0 || roomIndex >= floor.rooms.length) return null;
    return floor.rooms[roomIndex];
  }
}

