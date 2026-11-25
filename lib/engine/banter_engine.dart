import '../data/banter_database.dart';
import '../domain/models.dart';

enum EnemySpeakerKind {
  animal,
  ghoul,
  human,
  robot,
  boss,
}

class BanterExchange {
  final String enemyLine;
  final String heroLine;

  const BanterExchange({
    required this.enemyLine,
    required this.heroLine,
  });

  factory BanterExchange.fromPair(BanterPair pair) {
    return BanterExchange(enemyLine: pair.enemy, heroLine: pair.hero);
  }

  String get formatted => '$enemyLine — $heroLine';
}

class BanterEngine {
  BanterEngine._();

  static EnemySpeakerKind classify(Enemy enemy) {
    final lower = enemy.name.toLowerCase();
    if (lower.contains('drone') || lower.contains('mech')) {
      return EnemySpeakerKind.robot;
    }
    if (enemy.isBoss) {
      if (lower.contains('turkey')) return EnemySpeakerKind.animal;
      return EnemySpeakerKind.boss;
    }
    if (lower.contains('ghoul')) {
      return EnemySpeakerKind.ghoul;
    }
    if (lower.contains('rat') ||
        lower.contains('hound') ||
        lower.contains('dog') ||
        lower.contains('turkey')) {
      return EnemySpeakerKind.animal;
    }
    return EnemySpeakerKind.human;
  }

  static BanterExchange buildExchange({
    required Enemy enemy,
    required int round,
    required bool isLowHp,
    int seed = 0,
  }) {
    final kind = classify(enemy);

    switch (kind) {
      case EnemySpeakerKind.animal:
        return _resolveAnimal(enemy, round, isLowHp, seed);
      case EnemySpeakerKind.ghoul:
        return _resolveGhoul(round, isLowHp, seed);
      case EnemySpeakerKind.robot:
        return _resolveRobot(round, isLowHp);
      case EnemySpeakerKind.boss:
        return _resolveBoss(round, isLowHp);
      case EnemySpeakerKind.human:
        return _resolveHuman(round, isLowHp, seed);
    }
  }

  static BanterExchange _resolveGhoul(int round, bool isLowHp, int seed) {
    if (round <= 1) {
      final pool = BanterDatabase.ghoulRound1;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    if (isLowHp) return BanterExchange.fromPair(BanterDatabase.ghoulLowHp);
    final later = [...BanterDatabase.ghoulRound2, BanterDatabase.ghoulRound3];
    return BanterExchange.fromPair(later[(seed + round) % later.length]);
  }

  static BanterExchange _resolveAnimal(
    Enemy enemy,
    int round,
    bool isLowHp,
    int seed,
  ) {
    if (round <= 1) {
      if (enemy.name.toLowerCase().contains('turkey')) {
        return BanterExchange.fromPair(BanterDatabase.turkeyOpening);
      }
      final pool = BanterDatabase.animalRound1;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    if (isLowHp && round == 2) {
      return BanterExchange.fromPair(BanterDatabase.animalLowHp);
    }
    if (round == 2) {
      final pool = BanterDatabase.animalRound2;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    final pool = [
      BanterDatabase.animalRound3,
      ...BanterDatabase.animalRound2,
      BanterDatabase.animalLowHp,
    ];
    return BanterExchange.fromPair(pool[(seed + round) % pool.length]);
  }

  static BanterExchange _resolveHuman(int round, bool isLowHp, int seed) {
    if (round <= 1) {
      final pool = BanterDatabase.humanRound1;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    if (isLowHp && round == 2) {
      return BanterExchange.fromPair(BanterDatabase.humanLowHp);
    }
    if (round == 2) {
      final pool = BanterDatabase.humanRound2;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    final pool = [
      BanterDatabase.humanRound3,
      ...BanterDatabase.humanRound2,
      BanterDatabase.humanLowHp,
    ];
    return BanterExchange.fromPair(pool[(seed + round) % pool.length]);
  }

  static BanterExchange _resolveRobot(int round, bool isLowHp) {
    if (round <= 1) return BanterExchange.fromPair(BanterDatabase.robotRound1);
    if (isLowHp) return BanterExchange.fromPair(BanterDatabase.robotLowHp);
    final pool = [BanterDatabase.robotRound2, BanterDatabase.robotRound3];
    return BanterExchange.fromPair(pool[round % pool.length]);
  }

  static BanterExchange _resolveBoss(int round, bool isLowHp) {
    if (round <= 1) return BanterExchange.fromPair(BanterDatabase.bossRound1);
    if (isLowHp) return BanterExchange.fromPair(BanterDatabase.bossLowHp);
    final pool = [BanterDatabase.bossRound2, BanterDatabase.bossRound3];
    return BanterExchange.fromPair(pool[round % pool.length]);
  }

  static String emptyScrapQuip(int seed) {
    final pool = BanterDatabase.emptyScrapQuips;
    return pool[seed % pool.length];
  }
}
