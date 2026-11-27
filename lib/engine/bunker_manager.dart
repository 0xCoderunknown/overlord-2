import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/game_database.dart';
import '../data/vault_archive/item_database.dart';
import '../domain/models.dart';
import '../domain/vault_models.dart';

class BunkerManager extends ChangeNotifier {
  static const int maxMedbayBeds = 3;
  static const List<String> _cookingMaterialIds = [
    'med_syringe',
    'med_herb',
    'chem_expired',
  ];

  final Random _rng;
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
  final Map<String, CharacterStats> characterStats = {};

  BunkerManager({Random? random}) : _rng = random ?? Random() {
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

    for (final starter in GameDatabase.starters) {
      characterStats[starter.id] = CharacterStats();
    }
  }

  /// Returns persistent runs/level/kills/recovery stats for a specific scout starter.
  CharacterStats statsFor(String starterId) =>
      characterStats.putIfAbsent(starterId, () => CharacterStats());

  List<String> get medbayOccupantIds => characterStats.entries
      .where((e) => e.value.occupiesMedbayBed)
      .map((e) => e.key)
      .toList();

  int get occupiedMedbayBeds => medbayOccupantIds.length;

  bool get hasFreeMedbayBed => occupiedMedbayBeds < maxMedbayBeds;

  int get totalCookingMaterialsCount => _cookingMaterialIds.fold(
    0,
    (sum, id) => sum + getStashItemCount(id),
  );

  bool treatScoutInMedbay(String starterId) {
    final stats = statsFor(starterId);
    if (stats.condition != ScoutCondition.injured &&
        stats.condition != ScoutCondition.sick) {
      return false;
    }
    if (getStashItemCount('c_medkit') <= 0) return false;
    _consumeStashItem('c_medkit', 1);
    stats.condition = ScoutCondition.healthy;
    stats.recoveryRunsLeft = 0;
    notifyListeners();
    return true;
  }

  /// Cooks 1 wasteland material into a mystery injection: Heal (60%), Poison (25%), or Fatal (15%).
  MysteryShotOutcome? cookMysteryInjection(String starterId) {
    final stats = statsFor(starterId);
    if (stats.condition != ScoutCondition.injured &&
        stats.condition != ScoutCondition.sick) {
      return null;
    }
    String? matId;
    for (final id in _cookingMaterialIds) {
      if (getStashItemCount(id) > 0) {
        matId = id;
        break;
      }
    }
    if (matId == null) return null;
    _consumeStashItem(matId, 1);

    final roll = _rng.nextInt(100);
    final MysteryShotOutcome outcome;
    if (roll < 60) {
      outcome = MysteryShotOutcome.heal;
      stats.condition = ScoutCondition.healthy;
      stats.recoveryRunsLeft = 0;
      lastDebrief = 'MEDBAY SHOT WORKED! SCOUT CLEARED FOR DUTY.';
    } else if (roll < 85) {
      outcome = MysteryShotOutcome.poison;
      stats.condition = ScoutCondition.sick;
      stats.recoveryRunsLeft += 2;
      lastDebrief = 'BOTCHED MIX! SCOUT POISONED (+2 RECOVERY RUNS).';
    } else {
      outcome = MysteryShotOutcome.fatal;
      stats.condition = ScoutCondition.dead;
      stats.recoveryRunsLeft = 0;
      stats.isBuried = false;
      lastDebrief = 'FATAL OVERDOSE IN MEDBAY. BURIAL CLOTH REQUIRED.';
    }

    _ensureAtLeastOneAvailableScout();
    notifyListeners();
    return outcome;
  }

  /// Wraps a fallen scout in Burial Cloth to free their Medbay bed.
  bool buryScoutWithCloth(String starterId) {
    final stats = statsFor(starterId);
    if (stats.condition != ScoutCondition.dead || stats.isBuried) {
      return false;
    }
    if (getStashItemCount(GameDatabase.burialCloth.id) <= 0) return false;
    _consumeStashItem(GameDatabase.burialCloth.id, 1);
    stats.isBuried = true;
    lastDebrief = 'FALLEN SCOUT WRAPPED & DISPOSED. MEDBAY BED CLEARED.';
    notifyListeners();
    return true;
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
    if (!isStarterUnlocked(starter) || !statsFor(starter.id).isAvailable) {
      return;
    }
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

  bool get hasAnyAvailableScout => GameDatabase.starters.any(
    (s) => isStarterUnlocked(s) && statsFor(s.id).isAvailable,
  );

  /// Deploys the selected starter (or an expendable Vault Intern if all scouts are down/dead).
  ScoutCharacter deployExpeditionScout() {
    final availableMeds = getStashItemCount('c_medkit');
    final deployMeds = min(3, availableMeds);

    if (deployMeds > 0) {
      _consumeStashItem('c_medkit', deployMeds);
    }

    if (!hasAnyAvailableScout) {
      return ScoutCharacter(
        name: 'Vault Intern',
        maxHp: 70,
        medkits: deployMeds,
      );
    }

    final starter = selectedStarter;
    return ScoutCharacter(
      name: starter.name,
      maxHp: starter.maxHp,
      medkits: deployMeds,
      starterWeapon: starter.weapon,
      starterArmor: starter.armor,
    );
  }

  /// Records lifetime & per-character kills/runs/level, unlocks, and banks Caps/supplies.
  List<ChallengeDef> completeExpedition({
    required int goldEarned,
    required List<EquipmentItem> lootedItems,
    required int unusedMedkits,
    required bool survived,
    bool caughtSickness = false,
    String? starterId,
    int kills = 0,
    int ratKills = 0,
    int bossKills = 0,
  }) {
    final activeId = starterId ?? selectedStarterId;
    expeditionCount++;
    totalKills += kills;
    ratsKilled += ratKills;
    bossesKilled += bossKills;
    statsFor(activeId).recordRun(kills: kills);

    // Tick down recovery for other resting scouts
    for (final entry in characterStats.entries) {
      if (entry.key == activeId) continue;
      final s = entry.value;
      if (s.condition != ScoutCondition.dead && s.recoveryRunsLeft > 0) {
        s.recoveryRunsLeft--;
        if (s.recoveryRunsLeft == 0) {
          s.condition = ScoutCondition.healthy;
        }
      }
    }

    // Apply post-run trauma or ration sickness if a Medbay bed is open
    final activeStats = statsFor(activeId);
    if (!survived && hasFreeMedbayBed) {
      activeStats.condition = ScoutCondition.injured;
      activeStats.recoveryRunsLeft = 2;
    } else if (survived && caughtSickness && hasFreeMedbayBed) {
      activeStats.condition = ScoutCondition.sick;
      activeStats.recoveryRunsLeft = 1;
    }

    _ensureAtLeastOneAvailableScout();

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

  void _ensureAtLeastOneAvailableScout() {
    final unlocked = GameDatabase.starters.where(isStarterUnlocked).toList();
    if (unlocked.isEmpty) return;

    final anyAvailable = unlocked.any((s) => statsFor(s.id).isAvailable);
    if (!anyAvailable) {
      // Anti-softlock: clear the recovering non-dead scout closest to recovery
      final recoverable = unlocked
          .where((s) => statsFor(s.id).condition != ScoutCondition.dead)
          .toList()
        ..sort(
          (a, b) => statsFor(a.id)
              .recoveryRunsLeft
              .compareTo(statsFor(b.id).recoveryRunsLeft),
        );
      if (recoverable.isNotEmpty) {
        final s = statsFor(recoverable.first.id);
        s.condition = ScoutCondition.healthy;
        s.recoveryRunsLeft = 0;
      }
    }

    if (!statsFor(selectedStarterId).isAvailable) {
      final fallback = unlocked.where((s) => statsFor(s.id).isAvailable);
      if (fallback.isNotEmpty) {
        selectedStarterId = fallback.first.id;
      }
    }
  }
}
