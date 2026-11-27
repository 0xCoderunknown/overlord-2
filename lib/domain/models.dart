import 'dart:math';

enum RoomType {
  entrance,
  corridor,
  office,
  clinic,
  generator,
  storage,
  elevator,
  bossChamber,
}

enum RoomState {
  unrevealed,
  outline,
  active,
  cleared,
}

enum ContentType {
  empty,
  loot,
  scrap,
  enemy,
  elevator,
}

enum RoomEventType {
  none,
  lockedSafe,
  medCabinet,
  tripwire,
}

enum ItemType {
  weapon,
  armor,
  consumable,
}

enum ConsumableEffect {
  heal,
  psycho,
  stealth,
  key,
  material,
  food,
}

class ScoutStarter {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String portraitAsset;
  final int maxHp;
  final EquipmentItem weapon;
  final EquipmentItem armor;
  final String? unlockChallengeId;

  const ScoutStarter({
    required this.id,
    required this.name,
    required this.title,
    this.bio = '',
    this.portraitAsset = 'assets/images/hero.png',
    this.maxHp = 100,
    required this.weapon,
    required this.armor,
    this.unlockChallengeId,
  });
}

class ChallengeDef {
  final String id;
  final String title;
  final String description;
  final String statKey; // 'rats', 'kills', 'bosses'
  final int targetCount;
  final String rewardLabel;

  const ChallengeDef({
    required this.id,
    required this.title,
    required this.description,
    required this.statKey,
    required this.targetCount,
    required this.rewardLabel,
  });
}

class ExpeditionContract {
  final String id;
  final String title;
  final String subtitle;
  final int floorCount;
  final int roomsPerFloor;
  final int bountyMultiplier;
  final int hazardLevel;
  final String lootFocus;

  const ExpeditionContract({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.floorCount,
    required this.roomsPerFloor,
    this.bountyMultiplier = 1,
    this.hazardLevel = 1,
    this.lootFocus = '',
  });
}

class EquipmentItem {
  final String id;
  final String name;
  final ItemType type;
  final int minStat;
  final int maxStat;
  final int scrapValue;
  final ConsumableEffect? consumableEffect;
  final String description;

  const EquipmentItem({
    required this.id,
    required this.name,
    required this.type,
    this.minStat = 0,
    this.maxStat = 0,
    this.scrapValue = 3,
    this.consumableEffect,
    this.description = '',
  });

  bool get isWeapon => type == ItemType.weapon;
  bool get isArmor => type == ItemType.armor;
  bool get isConsumable => type == ItemType.consumable;

  String get statDescription {
    if (isWeapon) return 'DMG: $minStat - $maxStat';
    if (isArmor) return 'DR: $minStat - $maxStat';
    return description;
  }
}

class ScrapPile {
  final String id;
  bool isSearched;
  final EquipmentItem? containedItem;

  ScrapPile({
    required this.id,
    this.isSearched = false,
    this.containedItem,
  });
}

class Enemy {
  final String name;
  final int maxHp;
  int currentHp;
  final int minDamage;
  final int maxDamage;
  final int bountyGold;
  final bool isBoss;
  final String description;

  Enemy({
    required this.name,
    required this.maxHp,
    required this.minDamage,
    required this.maxDamage,
    this.bountyGold = 12,
    this.isBoss = false,
    this.description = '',
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
  int gold;
  int medkits;
  int keys;
  int stealthboys;
  bool psychoActive;
  bool caughtSickness;

  EquipmentItem equippedWeapon;
  EquipmentItem equippedArmor;
  final List<EquipmentItem> backpack;

  ScoutCharacter({
    required this.name,
    this.maxHp = 100,
    this.gold = 0,
    this.medkits = 1,
    this.keys = 1,
    this.stealthboys = 0,
    this.psychoActive = false,
    this.caughtSickness = false,
    EquipmentItem? starterWeapon,
    EquipmentItem? starterArmor,
    List<EquipmentItem>? backpack,
  })  : currentHp = maxHp,
        backpack = backpack ?? [],
        equippedWeapon = starterWeapon ??
            const EquipmentItem(
              id: 'wpn_pipe_pistol',
              name: 'Crude Pipe Pistol',
              type: ItemType.weapon,
              minStat: 6,
              maxStat: 12,
              scrapValue: 2,
              description: 'Rusted chamber. Shoots scrap rivets.',
            ),
        equippedArmor = starterArmor ??
            const EquipmentItem(
              id: 'arm_phonebook',
              name: 'Taped Phonebook',
              type: ItemType.armor,
              minStat: 2,
              maxStat: 4,
              scrapValue: 2,
              description: 'Layers of yellow pages bound by duct tape.',
            );

  bool get isDead => currentHp <= 0;

  /// Emergency heal is strictly restricted to critical situations (HP <= 25%).
  bool get canEmergencyHeal =>
      medkits > 0 && currentHp <= (maxHp * 0.25).ceil();

  int rollDamage(Random rng) {
    final base = equippedWeapon.minStat +
        rng.nextInt(max(1, equippedWeapon.maxStat - equippedWeapon.minStat + 1));
    return psychoActive ? base + 6 : base;
  }

  int rollArmorReduction(Random rng) {
    if (equippedArmor.maxStat <= equippedArmor.minStat) {
      return equippedArmor.minStat;
    }
    return equippedArmor.minStat +
        rng.nextInt(equippedArmor.maxStat - equippedArmor.minStat + 1);
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
  ScrapPile? scrapPile;
  String? ambientLore;
  RoomEventType eventType;
  bool isEventResolved;
  bool isBypassed;

  Room({
    required this.floorIndex,
    required this.roomIndex,
    required this.type,
    required this.contentType,
    this.state = RoomState.unrevealed,
    this.enemy,
    this.scrapPile,
    this.ambientLore,
    this.eventType = RoomEventType.none,
    this.isEventResolved = false,
    this.isBypassed = false,
  });

  bool get isElevator => type == RoomType.elevator;
  bool get hasUnresolvedEnemy =>
      enemy != null && !enemy!.isDead && !isBypassed;
  bool get hasUnsearchedScrap => scrapPile != null && !scrapPile!.isSearched;
  bool get hasUnresolvedEvent =>
      eventType != RoomEventType.none && !isEventResolved;
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

enum ScoutCondition {
  healthy,
  injured,
  sick,
  dead,
}

enum MysteryShotOutcome {
  heal,
  poison,
  fatal,
}

/// Per-character expedition progression & Medbay recovery state.
class CharacterStats {
  int runs;
  int kills;
  int level;
  ScoutCondition condition;
  int recoveryRunsLeft;
  bool isBuried;

  CharacterStats({
    this.runs = 0,
    this.kills = 0,
    this.level = 1,
    this.condition = ScoutCondition.healthy,
    this.recoveryRunsLeft = 0,
    this.isBuried = false,
  });

  bool get isAvailable =>
      condition == ScoutCondition.healthy && recoveryRunsLeft == 0;

  bool get occupiesMedbayBed =>
      condition == ScoutCondition.injured ||
      condition == ScoutCondition.sick ||
      (condition == ScoutCondition.dead && !isBuried);

  void recordRun({int kills = 0}) {
    runs++;
    this.kills += kills;
    level = 1 + (this.kills ~/ 5);
  }
}
