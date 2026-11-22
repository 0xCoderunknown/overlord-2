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
  final String narrative;
  final CombatStatus status;

  const CombatRoundResult({
    required this.playerDamageDealt,
    required this.enemyDamageDealt,
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
        narrative: 'Combat already resolved.',
        status: status,
      );
    }

    // 1. Player attacks
    final pDmg = player.rollDamage(rng);
    enemy.currentHp = max(0, enemy.currentHp - pDmg);

    if (enemy.isDead) {
      // Victory
      String narrative = '${player.name} struck ${enemy.name} for $pDmg DMG! ${enemy.name} was eliminated!';
      if (enemy.lootDrop != null) {
        final drop = enemy.lootDrop!;
        if (drop.caps > 0) {
          player.caps += drop.caps;
          narrative += ' Found ${drop.caps} Caps!';
        }
        if (drop.healAmount > 0) {
          player.medkits += 1;
          narrative += ' Found 1x ${drop.name}!';
        }
      }
      return CombatRoundResult(
        playerDamageDealt: pDmg,
        enemyDamageDealt: 0,
        narrative: narrative,
        status: CombatStatus.victory,
      );
    }

    // 2. Enemy counter-attacks
    final eDmg = enemy.rollDamage(rng);
    player.currentHp = max(0, player.currentHp - eDmg);

    if (player.isDead) {
      return CombatRoundResult(
        playerDamageDealt: pDmg,
        enemyDamageDealt: eDmg,
        narrative: '${player.name} dealt $pDmg DMG, but ${enemy.name} counter-struck for $eDmg DMG. ${player.name} flatlined!',
        status: CombatStatus.defeat,
      );
    }

    return CombatRoundResult(
      playerDamageDealt: pDmg,
      enemyDamageDealt: eDmg,
      narrative: '${player.name} dealt $pDmg DMG. ${enemy.name} retaliated for $eDmg DMG.',
      status: CombatStatus.inProgress,
    );
  }

  /// Use a field medkit if available
  bool useMedkit() {
    if (player.medkits <= 0 || player.currentHp >= player.maxHp) {
      return false;
    }
    player.medkits--;
    player.heal(50);
    return true;
  }
}

