import 'package:flutter_test/flutter_test.dart';
import 'package:overlord_2/data/game_database.dart';
import 'package:overlord_2/data/vault_archive/item_database.dart';
import 'package:overlord_2/domain/models.dart';
import 'package:overlord_2/domain/vault_models.dart';
import 'package:overlord_2/engine/bunker_manager.dart';

void main() {
  group('BunkerManager Tests', () {
    late BunkerManager bunker;

    setUp(() {
      bunker = BunkerManager();
    });

    test('initializes starter bunker with caps, scout Vance, and starter gear', () {
      expect(bunker.caps, equals(500));
      expect(bunker.roster.length, equals(1));
      expect(bunker.roster.first.name, equals('Vance'));
      expect(bunker.globalStash.isNotEmpty, isTrue);

      final medkit = bunker.globalStash.where((i) => i.id == 'c_medkit').firstOrNull;
      expect(medkit, isNotNull);
      expect(medkit!.quantity, equals(2));
    });

    test('addItemToStash increments quantity for stackable items', () {
      final initialCount = bunker.getStashItemCount('c_medkit');
      final medkitData = ItemDatabase.consumables.firstWhere((c) => c['id'] == 'c_medkit');
      bunker.addItemToStash(Item.fromDatabase(medkitData, quantity: 3));

      expect(bunker.getStashItemCount('c_medkit'), equals(initialCount + 3));
    });

    test('unlockMedbay fails without sufficient caps and succeeds with 10000 caps', () {
      bunker.caps = 5000;
      expect(bunker.unlockMedbay(), isFalse);
      expect(bunker.medbay.isUnlocked, isFalse);

      bunker.caps = 15000;
      expect(bunker.unlockMedbay(), isTrue);
      expect(bunker.medbay.isUnlocked, isTrue);
      expect(bunker.caps, equals(5000));
    });

    test('medbay synthesis lifecycle: craft, overclock, and claim', () {
      bunker.caps = 15000;
      bunker.unlockMedbay();

      bunker.addCraftingMaterials();
      expect(bunker.canCraftMedbay(), isTrue);

      bunker.startMedbayCrafting();
      expect(bunker.medbay.isCrafting, isTrue);

      bunker.completeMedbayCrafting();
      expect(bunker.medbay.isCrafting, isFalse);
      expect(bunker.medbay.outputReady, isTrue);

      final medkitBefore = bunker.getStashItemCount('c_medkit');
      bunker.claimMedbay();
      expect(bunker.medbay.outputReady, isFalse);
      expect(bunker.getStashItemCount('c_medkit'), equals(medkitBefore + 2));
    });

    test('deployExpeditionScout uses selected starter gear and completeExpedition unlocks challenges & banks consumables', () {
      final initialCaps = bunker.caps;
      final initialMeds = bunker.getStashItemCount('c_medkit');
      final scout = bunker.deployExpeditionScout();

      expect(scout.name, equals('Vance'));
      expect(scout.equippedWeapon.name, equals('Crude Pipe Pistol'));
      expect(scout.medkits, equals(initialMeds));
      expect(bunker.getStashItemCount('c_medkit'), equals(0));

      final loot = [
        const EquipmentItem(
          id: 'w_plasma_test',
          name: 'Plasma Cutter',
          type: ItemType.weapon,
          minStat: 20,
          maxStat: 30,
          scrapValue: 15,
        ),
        const EquipmentItem(
          id: 'med_syringe',
          name: 'Used Syringe',
          type: ItemType.consumable,
          consumableEffect: ConsumableEffect.material,
          scrapValue: 1,
        ),
      ];

      final unlocked = bunker.completeExpedition(
        goldEarned: 125,
        lootedItems: loot,
        unusedMedkits: 1,
        survived: true,
        kills: 15,
        ratKills: 15,
        bossKills: 1,
      );

      expect(bunker.caps, equals(initialCaps + 125));
      expect(bunker.getStashItemCount('c_medkit'), equals(1));
      // Consumables/materials bank; OP run weapons do not carry over
      expect(bunker.globalStash.any((i) => i.id == 'med_syringe'), isTrue);
      expect(bunker.globalStash.any((i) => i.name == 'Plasma Cutter'), isFalse);
      // Overlord 1 characters are selectable immediately
      bunker.selectStarter('char_shina');
      expect(bunker.deployExpeditionScout().maxHp, equals(80));
      bunker.selectStarter('char_robot');
      expect(bunker.deployExpeditionScout().maxHp, equals(150));

      // Challenges unlocked
      expect(unlocked.length, equals(3));
      final cat = GameDatabase.starters.firstWhere((s) => s.id == 'starter_cat');
      expect(bunker.isStarterUnlocked(cat), isTrue); // Alley Cat
      bunker.selectStarter('starter_cat');
      expect(bunker.selectedStarter.name, equals('Alley Cat'));
    });
  });
}

