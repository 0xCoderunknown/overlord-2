import 'dart:math';
import 'models.dart';

enum ScavState { idle, exploring, returning, waitingForInput, dead }

class GameConfig {
  static const int minutesPerDay = 1440;
  static const int maxBackpackWeight = 10;
  static const int minReviveCost = 20;
  static const int medbayUnlockCost = 10000;
  static const int medbayCraftingTime = 240;
  static const int maxStashSize = 50;
  static const int maxOfflineMinutes = 4320;
}

class Item {
  final String id;
  final String name;
  final int value;
  final bool isStackable;
  int quantity;
  final String type;
  final int tier;
  final int? minStat;
  final int? maxStat;
  final String? description;
  final String? imagePath;

  Item({
    required this.id,
    required this.name,
    this.value = 0,
    this.isStackable = false,
    this.quantity = 1,
    this.type = 'misc',
    this.tier = 1,
    this.minStat,
    this.maxStat,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'value': value,
    'isStackable': isStackable,
    'quantity': quantity,
    'type': type,
    'tier': tier,
    'minStat': minStat,
    'maxStat': maxStat,
    'description': description,
    'imagePath': imagePath,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    name: json['name'] as String,
    value: json['value'] as int? ?? 0,
    isStackable: json['isStackable'] as bool? ?? false,
    quantity: json['quantity'] as int? ?? 1,
    type: json['type'] as String? ?? 'misc',
    tier: json['tier'] as int? ?? 1,
    minStat: json['minStat'] as int?,
    maxStat: json['maxStat'] as int?,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
  );

  factory Item.fromDatabase(
    Map<String, dynamic> data, {
    int quantity = 1,
    bool generateUniqueId = false,
  }) {
    return Item(
      id: generateUniqueId
          ? "${data['id']}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000).toString().padLeft(3, '0')}"
          : data['id'],
      name: data['name'],
      type: data['type'] ?? 'misc',
      value: data['value'] ?? 0,
      isStackable: data['isStackable'] ?? false,
      quantity: quantity,
      tier: data['tier'] ?? 1,
      minStat: data['minStat'],
      maxStat: data['maxStat'],
      description: data['description'],
      imagePath: data['imagePath'],
    );
  }

  /// Converter to Overlord 2's EquipmentItem
  EquipmentItem toEquipmentItem() {
    ItemType it;
    if (type == 'weapon') {
      it = ItemType.weapon;
    } else if (type == 'armor') {
      it = ItemType.armor;
    } else {
      it = ItemType.consumable;
    }

    ConsumableEffect? ce;
    if (id == 'c_medkit') ce = ConsumableEffect.heal;

    return EquipmentItem(
      id: id,
      name: name,
      type: it,
      minStat: minStat ?? 0,
      maxStat: maxStat ?? minStat ?? 0,
      scrapValue: max(1, value ~/ 10),
      consumableEffect: ce,
      description: description ?? '',
    );
  }
}

class Scavenger {
  final String id;
  String name;
  String imagePath;
  int hp;
  int maxHp;
  ScavState state;
  String? pendingPoiId;
  List<Item> backpack;
  Item? equippedWeapon;
  Item? equippedArmor;
  int minutesExplored;
  int minutesToReturn;
  List<String> logs;
  List<String> loreQueue;
  int stress;
  String? hiddenTrait;

  Scavenger({
    required this.id,
    required this.name,
    this.imagePath = 'assets/images/char/jonny.webp',
    this.hp = 100,
    this.maxHp = 100,
    this.state = ScavState.idle,
    this.pendingPoiId,
    List<Item>? backpack,
    this.equippedWeapon,
    this.equippedArmor,
    this.minutesExplored = 0,
    this.minutesToReturn = 0,
    this.stress = 0,
    this.hiddenTrait,
    List<String>? logs,
    List<String>? loreQueue,
  })  : backpack = backpack ?? [],
        logs = logs ?? [],
        loreQueue = loreQueue ?? [];

  int get currentWeight => backpack.where((i) => i.id != 'loot_caps').length;

  bool addItemToBackpack(Item newItem) {
    if (newItem.isStackable) {
      int existingIndex = backpack.indexWhere((i) => i.id == newItem.id);
      if (existingIndex != -1) {
        backpack[existingIndex].quantity += newItem.quantity;
        return true;
      }
    }

    if (currentWeight < GameConfig.maxBackpackWeight || newItem.id == 'loot_caps') {
      backpack.add(newItem);
      return true;
    }
    return false;
  }
}

class VaultFacility {
  final String id;
  bool isUnlocked;
  bool isCrafting;
  int minutesRemaining;
  bool outputReady;

  VaultFacility({
    required this.id,
    this.isUnlocked = false,
    this.isCrafting = false,
    this.minutesRemaining = 0,
    this.outputReady = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUnlocked': isUnlocked,
    'isCrafting': isCrafting,
    'minutesRemaining': minutesRemaining,
    'outputReady': outputReady,
  };

  factory VaultFacility.fromJson(Map<String, dynamic> json) => VaultFacility(
    id: json['id'] as String,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isCrafting: json['isCrafting'] as bool? ?? false,
    minutesRemaining: json['minutesRemaining'] as int? ?? 0,
    outputReady: json['outputReady'] as bool? ?? false,
  );
}

