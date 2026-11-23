import 'package:flutter/widgets.dart';
import '../data/vault_archive/item_database.dart';
import '../domain/vault_models.dart';

class BunkerManager extends ChangeNotifier {
  int caps = 500;
  List<Item> globalStash = [];
  VaultFacility medbay = VaultFacility(id: 'fac_medbay');
  List<Scavenger> roster = [];

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

  void sellItem(Item item, int quantity) {
    final idx = globalStash.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;

    final actualQty = quantity.clamp(1, globalStash[idx].quantity);
    final saleValue = (globalStash[idx].value ~/ 2) * actualQty;

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
}
