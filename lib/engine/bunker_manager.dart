import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/game_database.dart';
import '../data/vault_archive/item_database.dart';
import '../domain/models.dart';
import '../domain/vault_models.dart';

class BunkerManager extends ChangeNotifier {
  int caps = 500;
  List<Item> globalStash = [];
  VaultFacility medbay = VaultFacility(id: 'fac_medbay');
  List<Scavenger> roster = [];
  String? lastDebrief;
  int expeditionCount = 0;

  // Megabonk-style lifetime stats & unlocks
  int totalKills = 0;
  int ratsKilled = 0;
  int bossesKilled = 0;
  final Set<String> unlockedIds = {};
  String selectedStarterId = 'starter_vance';

  BunkerManager() {
    _initStarterBunker();
  }

  void _initStarterBunker() {
    // Starting scout
    final jonny = Scavenger(
      id: 'scav_vance_01',
      name: 'Vance',
      imagePath: 'assets/images/char/jonny.webp',
      hp: 100,
      maxHp: 100,
      state: ScavState.idle,
    );
    roster.add(jonny);

    // Populate initial starter stash
    for (final raw in ItemDatabase.weapons.take(2)) {
      globalStash.add(Item.fromDatabase(raw, generateUniqueId: true));
    }
    for (final raw in ItemDatabase.armor.take(1)) {
      globalStash.add(Item.fromDatabase(raw, generateUniqueId: true));
    }
    // Starting medkit
    final medkitData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'c_medkit');
    globalStash.add(Item.fromDatabase(medkitData, quantity: 2));
  }

  void addItemToStash(Item item) {
    if (item.isStackable) {
      final existingIndex = globalStash.indexWhere((i) => i.id == item.id);
      if (existingIndex != -1) {
        globalStash[existingIndex].quantity += item.quantity;
        notifyListeners();
        return;
      }
    }
    globalStash.add(item);
    notifyListeners();
  }

  bool buyItem(Item item) {
    if (caps < item.value) return false;
    caps -= item.value;
    addItemToStash(Item(
      id: "${item.id}_${DateTime.now().millisecondsSinceEpoch}",
      name: item.name,
      type: item.type,
      value: item.value,
      isStackable: item.isStackable,
      tier: item.tier,
      minStat: item.minStat,
      maxStat: item.maxStat,
      description: item.description,
      imagePath: item.imagePath,
      quantity: 1,
    ));
    notifyListeners();
    return true;
  }

  int getSellValue(Item item, [int quantity = 1]) {
    final unitValue = (item.value ~/ 2).clamp(1, 99999);
    return unitValue * quantity;
  }

  void sellItem(Item item, int quantity) {
    final idx = globalStash.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;

    final actualQty = quantity.clamp(1, globalStash[idx].quantity);
    final saleValue = getSellValue(globalStash[idx], actualQty);

    caps += saleValue;
    globalStash[idx].quantity -= actualQty;

    if (globalStash[idx].quantity <= 0) {
      globalStash.removeAt(idx);
    }
    notifyListeners();
  }

  bool unlockMedbay() {
    if (caps < GameConfig.medbayUnlockCost) return false;
    caps -= GameConfig.medbayUnlockCost;
    medbay.isUnlocked = true;
    notifyListeners();
    return true;
  }

  int getStashItemCount(String itemId) {
    final item = globalStash.where((i) => i.id == itemId).firstOrNull;
    return item?.quantity ?? 0;
  }

  bool canCraftMedbay() {
    return getStashItemCount('med_syringe') >= 1 &&
        getStashItemCount('med_herb') >= 2 &&
        getStashItemCount('chem_expired') >= 1;
  }

  void addCraftingMaterials({int syringe = 1, int herb = 2, int chem = 1}) {
    final sData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'med_syringe', orElse: () => {
      'id': 'med_syringe',
      'name': 'Used Syringe',
      'type': 'material',
      'tier': 1,
      'value': 10,
      'isStackable': true,
      'description': 'Plastic syringe with a dull needle.',
    });
    final hData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'med_herb', orElse: () => {
      'id': 'med_herb',
      'name': 'Irradiated Herb',
      'type': 'material',
      'tier': 1,
      'value': 15,
      'isStackable': true,
      'description': 'Medicinal wild flora glowing with faint isotopes.',
    });
    final cData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'chem_expired', orElse: () => {
      'id': 'chem_expired',
      'name': 'Expired Chemicals',
      'type': 'material',
      'tier': 2,
      'value': 25,
      'isStackable': true,
      'description': 'Pre-war industrial disinfectant and reagents.',
    });

    addItemToStash(Item.fromDatabase(sData, quantity: syringe));
    addItemToStash(Item.fromDatabase(hData, quantity: herb));
    addItemToStash(Item.fromDatabase(cData, quantity: chem));
  }

  void _consumeStashItem(String itemId, int qty) {
    final idx = globalStash.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      globalStash[idx].quantity -= qty;
      if (globalStash[idx].quantity <= 0) {
        globalStash.removeAt(idx);
      }
    }
  }

  void startMedbayCrafting() {
    if (!medbay.isUnlocked || medbay.isCrafting) return;
    if (canCraftMedbay()) {
      _consumeStashItem('med_syringe', 1);
      _consumeStashItem('med_herb', 2);
      _consumeStashItem('chem_expired', 1);
    }
    medbay.isCrafting = true;
    medbay.minutesRemaining = GameConfig.medbayCraftingTime;
    notifyListeners();
  }

  void completeMedbayCrafting() {
    if (!medbay.isCrafting) return;
    medbay.minutesRemaining = 0;
    medbay.isCrafting = false;
    medbay.outputReady = true;
    notifyListeners();
  }

  void claimMedbay() {
    final medkitData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'c_medkit');
    addItemToStash(Item.fromDatabase(medkitData, quantity: 2));
    medbay.isCrafting = false;
    medbay.outputReady = false;
    notifyListeners();
  }

  Item? getBestStashWeapon() {
    final weapons = globalStash.where((i) => i.type == 'weapon').toList();
    if (weapons.isEmpty) return null;
    weapons.sort((a, b) => (b.maxStat ?? 0).compareTo(a.maxStat ?? 0));
    return weapons.first;
  }

  Item? getBestStashArmor() {
    final armors = globalStash.where((i) => i.type == 'armor').toList();
    if (armors.isEmpty) return null;
    armors.sort((a, b) => (b.maxStat ?? 0).compareTo(a.maxStat ?? 0));
    return armors.first;
  }

  ScoutStarter get selectedStarter {
    return GameDatabase.starters.firstWhere(
      (s) => s.id == selectedStarterId,
      orElse: () => GameDatabase.starters.first,
    );
  }

  bool isStarterUnlocked(ScoutStarter starter) {
    if (starter.unlockChallengeId == null) return true;
    return unlockedIds.contains(starter.unlockChallengeId);
  }

  void selectStarter(String starterId) {
    final starter = GameDatabase.starters.firstWhere(
      (s) => s.id == starterId,
      orElse: () => GameDatabase.starters.first,
    );
    if (!isStarterUnlocked(starter)) return;
    selectedStarterId = starter.id;
    notifyListeners();
  }

  int getChallengeProgress(ChallengeDef challenge) {
    switch (challenge.statKey) {
      case 'rats':
        return ratsKilled;
      case 'bosses':
        return bossesKilled;
      case 'kills':
      default:
        return totalKills;
    }
  }

  bool isChallengeCompleted(ChallengeDef challenge) {
    return unlockedIds.contains(challenge.id) ||
        getChallengeProgress(challenge) >= challenge.targetCount;
  }

  /// Deploys the selected Megabonk starter with their signature low-tier gear + Bunker Medkits.
  ScoutCharacter deployExpeditionScout() {
    final starter = selectedStarter;
    final availableMeds = getStashItemCount('c_medkit');
    final deployMeds = min(3, availableMeds);

    if (deployMeds > 0) {
      _consumeStashItem('c_medkit', deployMeds);
    }

    return ScoutCharacter(
      name: starter.name,
      maxHp: starter.maxHp,
      medkits: max(1, deployMeds),
      starterWeapon: starter.weapon,
      starterArmor: starter.armor,
    );
  }

  /// Records lifetime kills/unlocks, banks Caps, and stores materials/consumables (no OP weapon carry-over).
  List<ChallengeDef> completeExpedition({
    required int goldEarned,
    required List<EquipmentItem> lootedItems,
    required int unusedMedkits,
    required bool survived,
    int kills = 0,
    int ratKills = 0,
    int bossKills = 0,
  }) {
    expeditionCount++;
    totalKills += kills;
    ratsKilled += ratKills;
    bossesKilled += bossKills;

    final newlyUnlocked = <ChallengeDef>[];
    for (final c in GameDatabase.challenges) {
      if (!unlockedIds.contains(c.id) &&
          getChallengeProgress(c) >= c.targetCount) {
        unlockedIds.add(c.id);
        newlyUnlocked.add(c);
      }
    }

    int bankedCount = 0;
    if (survived) {
      caps += goldEarned;
      for (final eq in lootedItems) {
        if (eq.isConsumable) {
          addItemToStash(Item.fromEquipmentItem(eq));
          bankedCount++;
        }
      }
      if (unusedMedkits > 0) {
        final medkitData =
            ItemDatabase.consumables.firstWhere((c) => c['id'] == 'c_medkit');
        addItemToStash(Item.fromDatabase(medkitData, quantity: unusedMedkits));
      }
      lastDebrief =
          'EXTRACTED +$goldEarned CAPS & $bankedCount SUPPLIES. +$kills KILLS.';
    } else {
      lastDebrief =
          '${selectedStarter.name.toUpperCase()} FLATLINED. CLONE AUTO-REVIVED.';
    }
    if (newlyUnlocked.isNotEmpty) {
      lastDebrief =
          'UNLOCKED: ${newlyUnlocked.map((c) => c.title).join(', ')}!';
    }
    notifyListeners();
    return newlyUnlocked;
  }
}
