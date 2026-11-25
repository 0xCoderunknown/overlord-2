import 'package:flutter_test/flutter_test.dart';
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

    test('buyItem deducts caps and adds new equipment to stash', () {
      final testWeapon = Item(
        id: 'w_test_pipe',
        name: 'Test Pipe Rifle',
        value: 120,
        isStackable: false,
        type: 'weapon',
        tier: 1,
      );

      final initialCaps = bunker.caps;
      final success = bunker.buyItem(testWeapon);

      expect(success, isTrue);
      expect(bunker.caps, equals(initialCaps - 120));
      expect(bunker.globalStash.any((i) => i.name == 'Test Pipe Rifle'), isTrue);
    });

    test('buyItem fails if player has insufficient caps', () {
      final expensiveItem = Item(
        id: 'w_laser_gatling',
        name: 'Gatling Laser',
        value: 99999,
        isStackable: false,
        type: 'weapon',
        tier: 3,
      );

      final success = bunker.buyItem(expensiveItem);
      expect(success, isFalse);
    });

    test('sellItem sells partial stack and credits half item value', () {
      final medkit = bunker.globalStash.firstWhere((i) => i.id == 'c_medkit');
      final unitSalePrice = bunker.getSellValue(medkit, 1);
      final initialCaps = bunker.caps;
      final initialQty = medkit.quantity;

      expect(unitSalePrice, equals((medkit.value ~/ 2).clamp(1, 99999)));
      bunker.sellItem(medkit, 1);

      expect(bunker.caps, equals(initialCaps + unitSalePrice));
      expect(bunker.getStashItemCount('c_medkit'), equals(initialQty - 1));
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

    test('deployExpeditionScout equips best gear and completeExpedition banks loot and gold', () {
      final initialCaps = bunker.caps;
      final initialMeds = bunker.getStashItemCount('c_medkit');
      final scout = bunker.deployExpeditionScout();

      expect(scout.name, equals('Vance'));
      expect(scout.medkits, equals(initialMeds));
      expect(bunker.getStashItemCount('c_medkit'), equals(0));
      expect(scout.equippedWeapon.name, isNotEmpty);

      final loot = [
        const EquipmentItem(
          id: 'w_plasma_test',
          name: 'Plasma Cutter',
          type: ItemType.weapon,
          minStat: 20,
          maxStat: 30,
          scrapValue: 15,
        ),
      ];

      bunker.completeExpedition(
        goldEarned: 125,
        lootedItems: loot,
        unusedMedkits: 1,
        survived: true,
      );

      expect(bunker.caps, equals(initialCaps + 125));
      expect(bunker.getStashItemCount('c_medkit'), equals(1));
      expect(bunker.globalStash.any((i) => i.name == 'Plasma Cutter'), isTrue);
    });
  });
}

