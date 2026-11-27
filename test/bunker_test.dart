import 'dart:math';
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

    test('tracks runs, kills, and level separately per character', () {
      bunker.selectStarter('starter_vance');
      bunker.completeExpedition(
        goldEarned: 50,
        lootedItems: const [],
        unusedMedkits: 1,
        survived: true,
        kills: 6,
      );

      bunker.selectStarter('char_shina');
      bunker.completeExpedition(
        goldEarned: 20,
        lootedItems: const [],
        unusedMedkits: 0,
        survived: false,
        kills: 2,
      );

      final vance = bunker.statsFor('starter_vance');
      final shina = bunker.statsFor('char_shina');
      final drifter = bunker.statsFor('char_drifter');

      expect(vance.runs, equals(1));
      expect(vance.kills, equals(6));
      expect(vance.level, equals(2));

      expect(shina.runs, equals(1));
      expect(shina.kills, equals(2));
      expect(shina.level, equals(1));

      expect(drifter.runs, equals(0));
      expect(drifter.kills, equals(0));
      expect(drifter.level, equals(1));
    });

    test('scarce medkits & post-run recovery/sickness work without softlock', () {
      // Burn starter medkits (2 in stash)
      final firstDeploy = bunker.deployExpeditionScout();
      expect(firstDeploy.medkits, equals(2));
      // When stash has 0 medkits, scout deploys with 0 medkits (no free handout)
      final dryDeploy = bunker.deployExpeditionScout();
      expect(dryDeploy.medkits, equals(0));

      // Vance catches ration sickness on a run -> benched for 1 run
      bunker.selectStarter('starter_vance');
      bunker.completeExpedition(
        goldEarned: 15,
        lootedItems: const [],
        unusedMedkits: 0,
        survived: true,
        caughtSickness: true,
      );

      final vance = bunker.statsFor('starter_vance');
      expect(vance.condition, equals(ScoutCondition.sick));
      expect(vance.isAvailable, isFalse);
      expect(bunker.occupiedMedbayBeds, equals(1));
      // Selected starter auto-falls back to an available scout
      expect(bunker.selectedStarterId, isNot(equals('starter_vance')));

      // Completing a run with Shina ticks down Vance's recovery
      bunker.selectStarter('char_shina');
      bunker.completeExpedition(
        goldEarned: 10,
        lootedItems: const [],
        unusedMedkits: 0,
        survived: true,
      );
      expect(vance.condition, equals(ScoutCondition.healthy));
      expect(vance.isAvailable, isTrue);

      // Injuring Shina allows instant cure via 1 Medkit in Medbay
      bunker.selectStarter('char_shina');
      bunker.completeExpedition(
        goldEarned: 0,
        lootedItems: const [],
        unusedMedkits: 0,
        survived: false,
      );
      final shina = bunker.statsFor('char_shina');
      expect(shina.condition, equals(ScoutCondition.injured));
      expect(shina.recoveryRunsLeft, equals(2));

      final medkitData = ItemDatabase.consumables.firstWhere(
        (c) => c['id'] == 'c_medkit',
      );
      bunker.addItemToStash(Item.fromDatabase(medkitData, quantity: 1));
      expect(bunker.treatScoutInMedbay('char_shina'), isTrue);
      expect(shina.isAvailable, isTrue);
      expect(bunker.getStashItemCount('c_medkit'), equals(0));
    });

    test('mystery scrap cooking, fatal overdose, burial cloth & intern fallback', () {
      // Seeded RNG helper: find seeds for heal (<60), poison (60..84), fatal (>=85)
      final healBunker = BunkerManager(random: _FixedRandom(10));
      final poisonBunker = BunkerManager(random: _FixedRandom(70));
      final fatalBunker = BunkerManager(random: _FixedRandom(95));

      for (final b in [healBunker, poisonBunker, fatalBunker]) {
        b.addCraftingMaterials();
        b.selectStarter('starter_vance');
        b.completeExpedition(
          goldEarned: 0,
          lootedItems: const [],
          unusedMedkits: 0,
          survived: false,
        );
      }

      // 1. Heal outcome
      expect(
        healBunker.cookMysteryInjection('starter_vance'),
        equals(MysteryShotOutcome.heal),
      );
      expect(healBunker.statsFor('starter_vance').isAvailable, isTrue);

      // 2. Poison outcome (+2 recovery runs)
      expect(
        poisonBunker.cookMysteryInjection('starter_vance'),
        equals(MysteryShotOutcome.poison),
      );
      expect(
        poisonBunker.statsFor('starter_vance').condition,
        equals(ScoutCondition.sick),
      );
      expect(
        poisonBunker.statsFor('starter_vance').recoveryRunsLeft,
        equals(4),
      );

      // 3. Fatal outcome -> dead body occupies Medbay bed until Burial Cloth is used
      expect(
        fatalBunker.cookMysteryInjection('starter_vance'),
        equals(MysteryShotOutcome.fatal),
      );
      final vanceDead = fatalBunker.statsFor('starter_vance');
      expect(vanceDead.condition, equals(ScoutCondition.dead));
      expect(vanceDead.occupiesMedbayBed, isTrue);
      expect(fatalBunker.occupiedMedbayBeds, equals(1));
      expect(fatalBunker.buryScoutWithCloth('starter_vance'), isFalse);

      fatalBunker.addItemToStash(Item.fromEquipmentItem(GameDatabase.burialCloth));
      expect(fatalBunker.buryScoutWithCloth('starter_vance'), isTrue);
      expect(vanceDead.occupiesMedbayBed, isFalse);
      expect(fatalBunker.occupiedMedbayBeds, equals(0));

      // 4. If all unlocked scouts die, Vault Intern deploys as anti-softlock fallback
      for (final s in GameDatabase.starters.where(fatalBunker.isStarterUnlocked)) {
        fatalBunker.statsFor(s.id).condition = ScoutCondition.dead;
      }
      expect(fatalBunker.hasAnyAvailableScout, isFalse);
      expect(fatalBunker.deployExpeditionScout().name, equals('Vault Intern'));
    });
  });
}

class _FixedRandom implements Random {
  final int value;
  _FixedRandom(this.value);

  @override
  int nextInt(int max) => value % max;
  @override
  double nextDouble() => 0.0;
  @override
  bool nextBool() => false;
}

