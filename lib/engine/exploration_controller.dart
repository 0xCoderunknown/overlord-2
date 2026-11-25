import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import 'banter_engine.dart';
import 'building_generator.dart';
import 'combat_engine.dart';

class ExplorationController extends ChangeNotifier {
  final Building building;
  final ScoutCharacter player;
  final BuildingGenerator generator;

  int currentFloorIndex;
  int currentRoomIndex;

  CombatEngine? activeCombat;
  BanterExchange? activeBanter;
  String? lastEventLog;

  // Auto-Battler & Combat Animation State
  bool isAutoCombatActive = false;
  bool isShakingHero = false;
  bool isShakingEnemy = false;
  String? heroDamagePopup;
  String? enemyDamagePopup;
  bool _isProcessingRound = false;
  bool _disposed = false;

  // Visual Orientation & Aggro Standoff State
  bool isScoutOnLeft = true;
  bool isScoutFacingRight = true;
  bool isEnemyAggroed = false;
  String? scrapBannerText;

  // Death State Transitions (0.5s standing at 0 HP -> 1.0s lying on ground -> scrap/defeat)
  bool isEnemyLyingOnGround = false;
  bool isHeroLyingOnGround = false;
  bool isDefeatScreenVisible = false;
  bool isBossIntroActive = false;

  ExplorationController({
    required this.building,
    required this.player,
    BuildingGenerator? buildingGenerator,
    this.currentFloorIndex = 0,
    this.currentRoomIndex = 0,
  }) : generator = buildingGenerator ?? BuildingGenerator() {
    _initStartingRoom();
  }

  Room get currentRoom =>
      building.floors[currentFloorIndex].rooms[currentRoomIndex];

  bool get isBossDefeated {
    for (final floor in building.floors) {
      for (final room in floor.rooms) {
        if (room.type == RoomType.bossChamber &&
            room.enemy != null &&
            room.enemy!.isDead) {
          return true;
        }
      }
    }
    return false;
  }

  bool get canExtract {
    if (player.isDead) return false;
    if (activeCombat?.status == CombatStatus.inProgress) return false;
    if (isBossDefeated) return true;
    return currentRoom.type == RoomType.entrance &&
        (player.gold > 0 || player.backpack.isNotEmpty);
  }

  void _initStartingRoom() {
    currentRoom.state = RoomState.active;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
  }

  bool canMoveTo(int targetFloor, int targetRoom) {
    if (activeCombat != null &&
        activeCombat!.status == CombatStatus.inProgress) {
      return false;
    }

    final target = building.getRoom(targetFloor, targetRoom);
    if (target == null || target.state == RoomState.unrevealed) return false;
    if (targetFloor == currentFloorIndex && targetRoom == currentRoomIndex) {
      return false;
    }

    // Horizontal adjacent
    if (targetFloor == currentFloorIndex) {
      return (targetRoom - currentRoomIndex).abs() == 1;
    }

    // Vertical elevator transit
    if (currentRoom.isElevator && target.isElevator) {
      return (targetFloor - currentFloorIndex).abs() == 1;
    }

    return false;
  }

  bool moveTo(int targetFloor, int targetRoom) {
    if (!canMoveTo(targetFloor, targetRoom)) return false;

    currentRoom.state = RoomState.cleared;

    // Orientation: moving right => enter from left; moving left => enter from right
    if (targetFloor == currentFloorIndex) {
      if (targetRoom > currentRoomIndex) {
        isScoutOnLeft = true;
        isScoutFacingRight = true;
      } else if (targetRoom < currentRoomIndex) {
        isScoutOnLeft = false;
        isScoutFacingRight = false;
      }
    }

    currentFloorIndex = targetFloor;
    currentRoomIndex = targetRoom;
    currentRoom.state = RoomState.active;

    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);

    isEnemyAggroed = false;
    isEnemyLyingOnGround = false;
    heroDamagePopup = null;
    enemyDamagePopup = null;
    scrapBannerText = null;

    if (currentRoom.hasUnresolvedEnemy) {
      activeCombat = CombatEngine(player: player, enemy: currentRoom.enemy!);
      final enemy = currentRoom.enemy!;
      activeBanter = BanterEngine.buildExchange(
        enemy: enemy,
        round: 1,
        isLowHp: player.currentHp <= (player.maxHp * 0.25).ceil(),
        seed: targetFloor * 7 + targetRoom,
      );
      lastEventLog = activeBanter!.heroLine;
      if (enemy.isBoss) {
        isBossIntroActive = true;
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!_disposed) {
            isBossIntroActive = false;
            notifyListeners();
          }
        });
      }
      startAutoCombat();
    } else {
      activeCombat = null;
      activeBanter = null;
      isAutoCombatActive = false;
      isBossIntroActive = false;
      if (currentRoom.hasUnresolvedEvent &&
          currentRoom.eventType == RoomEventType.tripwire) {
        _triggerTripwire();
      } else if (currentRoom.hasUnresolvedEvent) {
        lastEventLog = currentRoom.eventType == RoomEventType.lockedSafe
            ? '"Spot a sealed floor safe. Got a key or crowbar?"'
            : '"An intact medical cabinet. Might still hold supplies."';
      } else if (currentRoom.hasUnsearchedScrap) {
        lastEventLog = '"Someone left a pile of scrap here. Might be worth a look."';
      } else if (currentRoom.isElevator) {
        lastEventLog = '"Rusted cables, flickering bulb... hope this lift holds."';
      } else if (currentRoom.ambientLore != null) {
        lastEventLog = currentRoom.ambientLore;
      } else {
        lastEventLog = '"Quiet in here. Too quiet..."';
      }
    }

    notifyListeners();
    return true;
  }

  void _revealAdjacentRooms(int floorIdx, int roomIdx) {
    void reveal(Room? r) {
      if (r != null && r.state == RoomState.unrevealed) {
        r.state = RoomState.outline;
      }
    }

    final floor = building.floors[floorIdx];
    if (roomIdx > 0) reveal(floor.rooms[roomIdx - 1]);
    if (roomIdx < floor.rooms.length - 1) reveal(floor.rooms[roomIdx + 1]);
    if (floor.rooms[roomIdx].isElevator) {
      if (floorIdx + 1 < building.floors.length) {
        reveal(building.floors[floorIdx + 1].rooms[roomIdx]);
      }
      if (floorIdx - 1 >= 0) {
        reveal(building.floors[floorIdx - 1].rooms[roomIdx]);
      }
    }
  }

  // --------------------------------------------------------------------------
  // AUTO-BATTLER ENGINE & CADENCE WITH DEATH ANIMATIONS
  // --------------------------------------------------------------------------
  void startAutoCombat() {
    if (activeCombat == null ||
        activeCombat!.status != CombatStatus.inProgress) {
      return;
    }
    if (isAutoCombatActive) return;
    isAutoCombatActive = true;
    _runAutoCombatLoop();
    notifyListeners();
  }

  void pauseAutoCombat() {
    isAutoCombatActive = false;
    notifyListeners();
  }

  void toggleAutoCombat() {
    if (isAutoCombatActive) {
      pauseAutoCombat();
    } else {
      startAutoCombat();
    }
  }

  Future<void> _runAutoCombatLoop() async {
    isEnemyAggroed = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (_disposed ||
        activeCombat == null ||
        activeCombat!.status != CombatStatus.inProgress) {
      return;
    }

    while (!_disposed &&
        isAutoCombatActive &&
        activeCombat != null &&
        activeCombat!.status == CombatStatus.inProgress) {
      if (_isProcessingRound) return;
      _isProcessingRound = true;

      final nextRound = activeCombat!.roundCount + 1;
      if (nextRound == 2 || nextRound == 3) {
        activeBanter = BanterEngine.buildExchange(
          enemy: activeCombat!.enemy,
          round: nextRound,
          isLowHp: player.currentHp <= (player.maxHp * 0.25).ceil(),
          seed: currentFloorIndex * 7 + currentRoomIndex,
        );
        lastEventLog = activeBanter!.heroLine;
        notifyListeners();
      }

      // Phase 1: Player's Turn anticipation
      await Future.delayed(const Duration(milliseconds: 1000));
      if (_disposed ||
          activeCombat == null ||
          activeCombat!.status != CombatStatus.inProgress) {
        _isProcessingRound = false;
        return;
      }

      final pDmg = activeCombat!.executePlayerStrike();

      // Check if enemy reached 0 HP: 0.5s standing -> 1.0s lying on ground -> scrap
      if (activeCombat!.enemy.isDead) {
        _isProcessingRound = false;
        isAutoCombatActive = false;
        isShakingEnemy = true;
        enemyDamagePopup = '-$pDmg';
        notifyListeners();

        // 1. Stand at 0 HP for 0.5s
        await Future.delayed(const Duration(milliseconds: 500));
        if (_disposed) return;
        isShakingEnemy = false;

        // 2. Lie on ground for 1.0s (rotated 90 degrees)
        isEnemyLyingOnGround = true;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 1000));
        if (_disposed) return;
        isEnemyLyingOnGround = false;

        // 3. Transform to scrap
        await _handleCombatVictory(pDmg);
        return;
      }

      isShakingEnemy = true;
      enemyDamagePopup = '-$pDmg';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      isShakingEnemy = false;
      notifyListeners();

      // 3-second tactical gap before Enemy's turn
      _isProcessingRound = false;
      await Future.delayed(const Duration(seconds: 3));
      if (_disposed ||
          activeCombat == null ||
          activeCombat!.status != CombatStatus.inProgress) {
        return;
      }
      _isProcessingRound = true;

      // Phase 2: Enemy's Turn anticipation
      await Future.delayed(const Duration(milliseconds: 1000));
      if (_disposed ||
          activeCombat == null ||
          activeCombat!.status != CombatStatus.inProgress) {
        _isProcessingRound = false;
        return;
      }

      final result = activeCombat!.executeEnemyStrike(pDmg);
      isShakingHero = true;
      heroDamagePopup = result.enemyDamageDealt > 0
          ? '-${result.enemyDamageDealt}'
          : 'BLOCKED';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      isShakingHero = false;
      notifyListeners();

      // Check if hero reached 0 HP: 0.5s standing -> 1.0s lying on ground -> defeat
      if (result.status == CombatStatus.defeat) {
        _isProcessingRound = false;
        isAutoCombatActive = false;
        notifyListeners();

        // 1. Stand at 0 HP for 0.5s
        await Future.delayed(const Duration(milliseconds: 500));
        if (_disposed) return;

        // 2. Lie on ground for 1.0s (rotated 90 degrees)
        isHeroLyingOnGround = true;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 1000));
        if (_disposed) return;

        // 3. Show defeat overlay
        isDefeatScreenVisible = true;
        notifyListeners();
        return;
      }

      // 3-second tactical gap before Player's next turn
      _isProcessingRound = false;
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _handleCombatVictory(int pDmg) async {
    isAutoCombatActive = false;
    isEnemyAggroed = false;
    isShakingEnemy = false;
    activeBanter = null;
    currentRoom.scrapPile = generator.generateScrapPile(currentFloorIndex);
    currentRoom.state = RoomState.cleared;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
    lastEventLog = '"One less thing between me and the exit. Let\'s check the scrap."';
    notifyListeners();
  }

  void executeCombatRound() {
    if (activeCombat == null) return;
    final result = activeCombat!.executeRound();
    lastEventLog = result.narrative;
    if (result.status == CombatStatus.victory) {
      _handleCombatVictory(result.playerDamageDealt);
    }
    notifyListeners();
  }

  void searchScrapPile() {
    if (!currentRoom.hasUnsearchedScrap) return;
    final scrap = currentRoom.scrapPile!;
    scrap.isSearched = true;
    if (scrap.containedItem != null) {
      final item = scrap.containedItem!;
      player.backpack.add(item);
      lastEventLog = '"Found ${item.name}! Stuffed it into my backpack."';
      _showTransientScrapBanner('+ ${item.name.toUpperCase()}');
    } else {
      lastEventLog = BanterEngine.emptyScrapQuip(currentFloorIndex * 5 + currentRoomIndex);
      _showTransientScrapBanner('EMPTY JUNK');
    }
    notifyListeners();
  }

  void _showTransientScrapBanner(String text) {
    scrapBannerText = text;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!_disposed && scrapBannerText == text) {
        scrapBannerText = null;
        notifyListeners();
      }
    });
  }

  bool get canUseStealthboy =>
      player.stealthboys > 0 &&
      activeCombat != null &&
      activeCombat!.status == CombatStatus.inProgress &&
      !activeCombat!.enemy.isBoss;

  void useStealthboy() {
    if (!canUseStealthboy) return;
    final enemyName = activeCombat!.enemy.name;
    player.stealthboys--;
    isAutoCombatActive = false;
    isEnemyAggroed = false;
    isShakingEnemy = false;
    activeCombat = null;
    currentRoom.isBypassed = true;
    currentRoom.state = RoomState.cleared;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
    lastEventLog = '"Stealthboy engaged! Slipped right past the $enemyName."';
    notifyListeners();
  }

  void useMedkit() {
    if (!player.canEmergencyHeal) return;
    player.medkits--;
    player.heal(50);
    heroDamagePopup = '+50';
    lastEventLog = '"Stings like rad-burns, but I\'m still breathing."';
    notifyListeners();
  }

  void activatePsycho() {
    if (player.psychoActive) return;
    player.psychoActive = true;
    lastEventLog = 'Injected Combat Psycho (+6 DMG).';
    notifyListeners();
  }

  void _triggerTripwire() {
    currentRoom.isEventResolved = true;
    final raw = 4 + generator.rng.nextInt(4); // 4-7 dmg
    final dr = player.rollArmorReduction(generator.rng);
    final dmg = (raw - dr).clamp(1, 99);
    player.currentHp = (player.currentHp - dmg).clamp(0, player.maxHp);
    isShakingHero = true;
    heroDamagePopup = '-$dmg';
    lastEventLog = '"[TRAP] Tripped a rusted wire! Shrapnel hit for $dmg DMG."';

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!_disposed) {
        isShakingHero = false;
        notifyListeners();
      }
    });

    if (player.isDead) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_disposed) return;
        isHeroLyingOnGround = true;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_disposed) return;
          isDefeatScreenVisible = true;
          notifyListeners();
        });
      });
    }
  }

  void resolveRoomEvent({bool useKey = false}) {
    if (!currentRoom.hasUnresolvedEvent) return;
    final type = currentRoom.eventType;
    currentRoom.isEventResolved = true;

    if (type == RoomEventType.medCabinet) {
      player.medkits++;
      final mat = generator.rollCraftingMaterial();
      player.backpack.add(mat);
      lastEventLog =
          '"Found a Medkit and ${mat.name} inside the cabinet!"';
      _showTransientScrapBanner('+1 MED / ${mat.name.toUpperCase()}');
      notifyListeners();
      return;
    }

    if (type == RoomEventType.lockedSafe) {
      if (useKey && player.keys > 0) {
        player.keys--;
        final item = generator.rollSafeLoot(currentFloorIndex);
        player.backpack.add(item);
        player.gold += 15;
        lastEventLog =
            '"Key worked! Packed ${item.name} and +15 Gold into my bag."';
        _showTransientScrapBanner('+ ${item.name.toUpperCase()}');
      } else {
        final success = generator.rng.nextBool();
        if (success) {
          final item = generator.rollSafeLoot(currentFloorIndex);
          player.backpack.add(item);
          player.gold += 8;
          lastEventLog =
              '"Pried it open! Packed ${item.name} and +8 Gold."';
          _showTransientScrapBanner('+ ${item.name.toUpperCase()}');
        } else {
          final dmg = 4 + generator.rng.nextInt(4);
          player.currentHp = (player.currentHp - dmg).clamp(0, player.maxHp);
          isShakingHero = true;
          heroDamagePopup = '-$dmg';
          lastEventLog = '"Safe latch snapped back! Sliced my hand for $dmg DMG."';
          Future.delayed(const Duration(milliseconds: 400), () {
            if (!_disposed) {
              isShakingHero = false;
              notifyListeners();
            }
          });
        }
      }
      notifyListeners();
    }
  }

  void equipFromBackpack(int index) {
    if (index < 0 || index >= player.backpack.length) return;
    final item = player.backpack.removeAt(index);

    if (item.isWeapon) {
      final old = player.equippedWeapon;
      player.equippedWeapon = item;
      player.backpack.add(old);
      lastEventLog = '"Swapped to ${item.name}."';
    } else if (item.isArmor) {
      final old = player.equippedArmor;
      player.equippedArmor = item;
      player.backpack.add(old);
      lastEventLog = '"Equipped ${item.name}."';
    } else if (item.isConsumable) {
      switch (item.consumableEffect) {
        case ConsumableEffect.heal:
          player.medkits++;
          lastEventLog = '"Strapped Medkit to utility belt."';
          break;
        case ConsumableEffect.psycho:
          player.psychoActive = true;
          lastEventLog = '"Injected Combat Psycho (+6 DMG)!"';
          break;
        case ConsumableEffect.stealth:
          player.stealthboys++;
          lastEventLog = '"Pocketed Stealthboy Cloak."';
          break;
        case ConsumableEffect.key:
          player.keys++;
          lastEventLog = '"Pocketed Master Key."';
          break;
        default:
          break;
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    isAutoCombatActive = false;
    super.dispose();
  }
}
