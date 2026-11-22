import 'dart:math';
import '../domain/models.dart';

enum CombatStatus {
  inProgress,
  victory,
  defeat,
}

class CombatRoundResult {
  final int playerDamageDealt;
  final int enemyDamageDealt;
  final int damageAbsorbedByArmor;
  final String narrative;
  final CombatStatus status;

  const CombatRoundResult({
    required this.playerDamageDealt,
    required this.enemyDamageDealt,
    required this.damageAbsorbedByArmor,
    required this.narrative,
    required this.status,
  });
}

class CombatEngine {
  final ScoutCharacter player;
  final Enemy enemy;
  final Random rng;

  CombatEngine({
    required this.player,
    required this.enemy,
    Random? random,
  }) : rng = random ?? Random();

  CombatStatus get status {
    if (player.isDead) return CombatStatus.defeat;
    if (enemy.isDead) return CombatStatus.victory;
    return CombatStatus.inProgress;
  }

  /// Executes a single exchange: Player attacks, then Enemy counter-attacks if alive.
  CombatRoundResult executeRound() {
    if (status != CombatStatus.inProgress) {
      return CombatRoundResult(
        playerDamageDealt: 0,
        enemyDamageDealt: 0,
        damageAbsorbedByArmor: 0,
        narrative: 'Combat already resolved.',
        status: status,
      );
    }

    // 1. Player attacks
    final pDmg = player.rollDamage(rng);
    enemy.currentHp = max(0, enemy.currentHp - pDmg);

    if (enemy.isDead) {
      // Award bounty gold on kill
      player.gold += enemy.bountyGold;
      final psychoNote = player.psychoActive ? ' (Psycho boost expired)' : '';
      player.psychoActive = false;

      final narrative =
          '${player.name} struck ${enemy.name} for $pDmg DMG! Target eliminated! Bounty +${enemy.bountyGold} Gold awarded.$psychoNote';

      return CombatRoundResult(
        playerDamageDealt: pDmg,
        enemyDamageDealt: 0,
        damageAbsorbedByArmor: 0,
        narrative: narrative,
        status: CombatStatus.victory,
      );
    }

    // 2. Enemy counter-attacks (Armor DR absorbs damage)
    final rawEnemyDmg = enemy.rollDamage(rng);
    final armorDR = player.rollArmorReduction(rng);
    final netDmg = max(0, rawEnemyDmg - armorDR);

    player.currentHp = max(0, player.currentHp - netDmg);

    if (player.isDead) {
      return CombatRoundResult(
        playerDamageDealt: pDmg,
        enemyDamageDealt: netDmg,
        damageAbsorbedByArmor: armorDR,
        narrative:
            '${player.name} dealt $pDmg DMG. ${enemy.name} struck back for $rawEnemyDmg DMG (Armor blocked $armorDR). ${player.name} flatlined!',
        status: CombatStatus.defeat,
      );
    }

    return CombatRoundResult(
      playerDamageDealt: pDmg,
      enemyDamageDealt: netDmg,
      damageAbsorbedByArmor: armorDR,
      narrative:
          '${player.name} hit for $pDmg DMG. ${enemy.name} retaliated for $netDmg DMG ($armorDR absorbed).',
      status: CombatStatus.inProgress,
    );
  }

  bool useMedkit() {
    if (player.medkits <= 0 || player.currentHp >= player.maxHp) {
      return false;
    }
    player.medkits--;
    player.heal(50);
    return true;
  }

  bool usePsycho() {
    if (player.psychoActive) return false;
    player.psychoActive = true;
    return true;
  }
}
