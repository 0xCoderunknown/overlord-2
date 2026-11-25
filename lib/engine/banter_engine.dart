import '../data/banter_database.dart';
import '../domain/models.dart';

enum EnemySpeakerKind {
  animal,
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
    if (enemy.isBoss) {
      if (lower.contains('turkey')) return EnemySpeakerKind.animal;
      return EnemySpeakerKind.boss;
    }
    if (lower.contains('rat') ||
        lower.contains('hound') ||
        lower.contains('dog') ||
        lower.contains('turkey')) {
      return EnemySpeakerKind.animal;
    }
    if (lower.contains('drone') || lower.contains('mech')) {
      return EnemySpeakerKind.robot;
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
      case EnemySpeakerKind.robot:
        return _resolveRobot(round, isLowHp);
      case EnemySpeakerKind.boss:
        return _resolveBoss(round, isLowHp);
      case EnemySpeakerKind.human:
        return _resolveHuman(round, isLowHp, seed);
    }
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
    if (round == 2) {
      if (isLowHp) return BanterExchange.fromPair(BanterDatabase.animalLowHp);
      final pool = BanterDatabase.animalRound2;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    return BanterExchange.fromPair(BanterDatabase.animalRound3);
  }

  static BanterExchange _resolveHuman(int round, bool isLowHp, int seed) {
    if (round <= 1) {
      final pool = BanterDatabase.humanRound1;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    if (round == 2) {
      if (isLowHp) return BanterExchange.fromPair(BanterDatabase.humanLowHp);
      final pool = BanterDatabase.humanRound2;
      return BanterExchange.fromPair(pool[seed % pool.length]);
    }
    return BanterExchange.fromPair(BanterDatabase.humanRound3);
  }

  static BanterExchange _resolveRobot(int round, bool isLowHp) {
    if (round <= 1) return BanterExchange.fromPair(BanterDatabase.robotRound1);
    if (round == 2) {
      return BanterExchange.fromPair(
        isLowHp ? BanterDatabase.robotLowHp : BanterDatabase.robotRound2,
      );
    }
    return BanterExchange.fromPair(BanterDatabase.robotRound3);
  }

  static BanterExchange _resolveBoss(int round, bool isLowHp) {
    if (round <= 1) return BanterExchange.fromPair(BanterDatabase.bossRound1);
    if (round == 2) {
      return BanterExchange.fromPair(
        isLowHp ? BanterDatabase.bossLowHp : BanterDatabase.bossRound2,
      );
    }
    return BanterExchange.fromPair(BanterDatabase.bossRound3);
  }

  static String emptyScrapQuip(int seed) {
    final pool = BanterDatabase.emptyScrapQuips;
    return pool[seed % pool.length];
  }
}
