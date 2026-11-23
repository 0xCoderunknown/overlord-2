import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../domain/models.dart';
import 'building_generator.dart';
import 'combat_engine.dart';

class ExplorationController extends ChangeNotifier {
  final Building building;
  final ScoutCharacter player;
  final BuildingGenerator generator;

  int currentFloorIndex;
  int currentRoomIndex;

  CombatEngine? activeCombat;
  EquipmentItem? pendingScrapItem;
  String? lastEventLog;

  // Auto-Battler & Combat Animation State
  bool isAutoCombatActive = false;
  bool isShakingHero = false;
  bool isShakingEnemy = false;
  String? heroDamagePopup;
  String? enemyDamagePopup;
  bool _isProcessingRound = false;
  bool _disposed = false;

  ExplorationController({
    required this.building,
    required this.player,
    BuildingGenerator? buildingGenerator,
    this.currentFloorIndex = 0,
    this.currentRoomIndex = 0,
  }) : generator = buildingGenerator ?? BuildingGenerator() {
    _initStartingRoom();
  }

  Room get currentRoom => building.floors[currentFloorIndex].rooms[currentRoomIndex];

  void _initStartingRoom() {
    currentRoom.state = RoomState.active;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
  }

  bool canMoveTo(int targetFloor, int targetRoom) {
    if (activeCombat != null && activeCombat!.status == CombatStatus.inProgress) {
      return false;
    }

    final target = building.getRoom(targetFloor, targetRoom);
    if (target == null) return false;
    if (target.state == RoomState.unrevealed) return false;

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

    // Previous room locked as cleared
    currentRoom.state = RoomState.cleared;

    // Advance
    currentFloorIndex = targetFloor;
    currentRoomIndex = targetRoom;
    currentRoom.state = RoomState.active;

    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);

    // Resolve room content
    pendingScrapItem = null;
    if (currentRoom.hasUnresolvedEnemy) {
      activeCombat = CombatEngine(
        player: player,
        enemy: currentRoom.enemy!,
      );
      final enemy = currentRoom.enemy!;
      if (enemy.isBoss) {
        lastEventLog = 'DANGER! APEX BOSS [${enemy.name.toUpperCase()}] ENGAGED! ${enemy.description}';
      } else {
        lastEventLog = 'Hostile ${enemy.name} engaged! ${enemy.description}';
      }
      startAutoCombat();
    } else {
      activeCombat = null;
      isAutoCombatActive = false;
      if (currentRoom.hasUnsearchedScrap) {
        lastEventLog = 'A salvageable Scrap Pile lies in the room.';
      } else if (currentRoom.isElevator) {
        lastEventLog = 'Elevator Shaft. Vertical transit online.';
      } else if (currentRoom.ambientLore != null) {
        lastEventLog = currentRoom.ambientLore;
      } else {
        lastEventLog = 'Sector cleared and quiet.';
      }
    }

    notifyListeners();
    return true;
  }

  void _revealAdjacentRooms(int floorIdx, int roomIdx) {
    final floor = building.floors[floorIdx];

    if (roomIdx > 0) {
      final left = floor.rooms[roomIdx - 1];
      if (left.state == RoomState.unrevealed) {
        left.state = RoomState.outline;
      }
    }

    if (roomIdx < floor.rooms.length - 1) {
      final right = floor.rooms[roomIdx + 1];
      if (right.state == RoomState.unrevealed) {
        right.state = RoomState.outline;
      }
    }

    if (floor.rooms[roomIdx].isElevator) {
      if (floorIdx + 1 < building.floors.length) {
        final above = building.floors[floorIdx + 1].rooms[roomIdx];
        if (above.state == RoomState.unrevealed) {
          above.state = RoomState.outline;
        }
      }
      if (floorIdx - 1 >= 0) {
        final below = building.floors[floorIdx - 1].rooms[roomIdx];
        if (below.state == RoomState.unrevealed) {
          below.state = RoomState.outline;
        }
      }
    }
  }

  // --------------------------------------------------------------------------
  // AUTO-BATTLER ENGINE & CADENCE (~2.2s per turn: 400ms strike + 400ms counter + 1.4s pause)
  // --------------------------------------------------------------------------
  void startAutoCombat() {
    if (activeCombat == null || activeCombat!.status != CombatStatus.inProgress) return;
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
    while (!_disposed &&
        isAutoCombatActive &&
        activeCombat != null &&
        activeCombat!.status == CombatStatus.inProgress) {
      if (_isProcessingRound) return;
      _isProcessingRound = true;

      // Phase 1: Player strikes (400ms)
      final pDmg = activeCombat!.executePlayerStrike();
      isShakingEnemy = true;
      enemyDamagePopup = '-$pDmg';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      isShakingEnemy = false;
      notifyListeners();

      // Check if enemy died
      if (activeCombat!.enemy.isDead) {
        _isProcessingRound = false;
        _handleCombatVictory(pDmg);
        return;
      }

      // Phase 2: Enemy retaliates (400ms)
      final result = activeCombat!.executeEnemyStrike(pDmg);
      lastEventLog = result.narrative;
      if (result.enemyDamageDealt > 0) {
        isShakingHero = true;
        heroDamagePopup = '-${result.enemyDamageDealt}';
        notifyListeners();
      }

      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed) return;
      isShakingHero = false;
      notifyListeners();

      if (result.status == CombatStatus.defeat) {
        _isProcessingRound = false;
        isAutoCombatActive = false;
        notifyListeners();
        return;
      }

      // Phase 3: Tactical pause / Decision window (~1400ms)
      _isProcessingRound = false;
      await Future.delayed(const Duration(milliseconds: 1400));
    }
  }

  void _handleCombatVictory(int pDmg) {
    isAutoCombatActive = false;
    currentRoom.scrapPile = generator.generateScrapPile(currentFloorIndex);
    currentRoom.state = RoomState.cleared;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
    lastEventLog =
        '${player.name} struck for $pDmg DMG! Target eliminated! Defeated enemy collapsed into a Scrap Pile.';
    notifyListeners();
  }

  /// Synchronous manual round fallback (e.g. for unit testing or instant strike)
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
      pendingScrapItem = scrap.containedItem;
      lastEventLog = 'Found salvage: ${pendingScrapItem!.name} (${pendingScrapItem!.statDescription})!';
    } else {
      pendingScrapItem = null;
      lastEventLog = 'Rummaged through scrap pile... Nothing found in the junk.';
    }

    notifyListeners();
  }

  void equipPendingItem() {
    if (pendingScrapItem == null) return;
    final item = pendingScrapItem!;

    if (item.isWeapon) {
      final old = player.equippedWeapon;
      player.equippedWeapon = item;
      player.gold += old.scrapValue;
      lastEventLog = 'Equipped ${item.name}! Old weapon scrapped for +${old.scrapValue} Gold.';
    } else if (item.isArmor) {
      final old = player.equippedArmor;
      player.equippedArmor = item;
      player.gold += old.scrapValue;
      lastEventLog = 'Equipped ${item.name}! Old armor scrapped for +${old.scrapValue} Gold.';
    } else if (item.isConsumable) {
      switch (item.consumableEffect) {
        case ConsumableEffect.heal:
          player.medkits++;
          lastEventLog = 'Acquired Wasteland Trauma Medkit.';
          break;
        case ConsumableEffect.psycho:
          player.psychoActive = true;
          lastEventLog = 'Consumed Combat Psycho! Next attack gains +6 DMG.';
          break;
        case ConsumableEffect.stealth:
          player.stealthboys++;
          lastEventLog = 'Acquired Stealthboy Cloak Unit.';
          break;
        case ConsumableEffect.key:
          player.keys++;
          lastEventLog = 'Acquired Security Master Key.';
          break;
        default:
          break;
      }
    }

    pendingScrapItem = null;
    notifyListeners();
  }

  void scrapPendingItem() {
    if (pendingScrapItem == null) return;
    final item = pendingScrapItem!;

    player.gold += item.scrapValue;
    lastEventLog = 'Dismantled ${item.name} for +${item.scrapValue} Gold.';
    pendingScrapItem = null;
    notifyListeners();
  }

  /// Emergency Medkit: Strictly restricted to <= 25% HP
  void useMedkit() {
    if (!player.canEmergencyHeal) return;
    player.medkits--;
    player.heal(50);
    lastEventLog = 'EMERGENCY MEDKIT: ${player.name} restored +50 HP!';
    notifyListeners();
  }

  void activatePsycho() {
    if (player.psychoActive) return;
    player.psychoActive = true;
    lastEventLog = 'Injected Combat Psycho (+6 DMG).';
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    isAutoCombatActive = false;
    super.dispose();
  }
}
