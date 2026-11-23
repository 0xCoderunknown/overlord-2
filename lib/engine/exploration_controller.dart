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

  // Visual Orientation & Aggro Standoff State
  bool isScoutOnLeft = true;
  bool isScoutFacingRight = true;
  bool isEnemyAggroed = false;
  String? combatBannerText;

  // Death State Transitions (0.5s standing at 0 HP -> 1.0s lying on ground -> scrap/defeat)
  bool isEnemyLyingOnGround = false;
  bool isHeroLyingOnGround = false;
  bool isDefeatScreenVisible = false;

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
    if (target == null || target.state == RoomState.unrevealed) return false;
    if (targetFloor == currentFloorIndex && targetRoom == currentRoomIndex) return false;

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

    pendingScrapItem = null;
    isEnemyAggroed = false;
    isEnemyLyingOnGround = false;
    combatBannerText = null;

    if (currentRoom.hasUnresolvedEnemy) {
      activeCombat = CombatEngine(
        player: player,
        enemy: currentRoom.enemy!,
      );
      final enemy = currentRoom.enemy!;
      lastEventLog = enemy.isBoss
          ? 'DANGER! APEX BOSS [${enemy.name.toUpperCase()}] ENGAGED! ${enemy.description}'
          : 'Hostile ${enemy.name} engaged! ${enemy.description}';
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
    void reveal(Room? r) { if (r != null && r.state == RoomState.unrevealed) r.state = RoomState.outline; }
    final floor = building.floors[floorIdx];
    if (roomIdx > 0) reveal(floor.rooms[roomIdx - 1]);
    if (roomIdx < floor.rooms.length - 1) reveal(floor.rooms[roomIdx + 1]);
    if (floor.rooms[roomIdx].isElevator) {
      if (floorIdx + 1 < building.floors.length) reveal(building.floors[floorIdx + 1].rooms[roomIdx]);
      if (floorIdx - 1 >= 0) reveal(building.floors[floorIdx - 1].rooms[roomIdx]);
    }
  }

  // --------------------------------------------------------------------------
  // AUTO-BATTLER ENGINE & CADENCE WITH DEATH ANIMATIONS
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
    combatBannerText = 'COMBAT STARTED';
    isEnemyAggroed = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (_disposed || activeCombat == null || activeCombat!.status != CombatStatus.inProgress) return;

    while (!_disposed &&
        isAutoCombatActive &&
        activeCombat != null &&
        activeCombat!.status == CombatStatus.inProgress) {
      if (_isProcessingRound) return;
      _isProcessingRound = true;

      // Phase 1: Player's Turn Announcement
      combatBannerText = "PLAYER'S TURN";
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1000));
      if (_disposed || activeCombat == null || activeCombat!.status != CombatStatus.inProgress) {
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
        combatBannerText = 'LETHAL BLOW';
        notifyListeners();

        // 1. Stand at 0 HP for 0.5s
        await Future.delayed(const Duration(milliseconds: 500));
        if (_disposed) return;
        isShakingEnemy = false;

        // 2. Lie on ground for 1.0s (rotated 90 degrees)
        isEnemyLyingOnGround = true;
        combatBannerText = 'TARGET DOWN';
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
      if (_disposed || activeCombat == null || activeCombat!.status != CombatStatus.inProgress) return;
      _isProcessingRound = true;

      // Phase 2: Enemy's Turn Announcement
      combatBannerText = "ENEMY'S TURN";
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 1000));
      if (_disposed || activeCombat == null || activeCombat!.status != CombatStatus.inProgress) {
        _isProcessingRound = false;
        return;
      }

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

      // Check if hero reached 0 HP: 0.5s standing -> 1.0s lying on ground -> defeat
      if (result.status == CombatStatus.defeat) {
        _isProcessingRound = false;
        isAutoCombatActive = false;
        combatBannerText = 'CRITICAL HIT';
        notifyListeners();

        // 1. Stand at 0 HP for 0.5s
        await Future.delayed(const Duration(milliseconds: 500));
        if (_disposed) return;

        // 2. Lie on ground for 1.0s (rotated 90 degrees)
        isHeroLyingOnGround = true;
        combatBannerText = 'SCOUT FLATLINED';
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
    combatBannerText = 'ENEMY DEFEATED';
    isEnemyAggroed = false;
    isShakingEnemy = false;
    currentRoom.scrapPile = generator.generateScrapPile(currentFloorIndex);
    currentRoom.state = RoomState.cleared;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
    lastEventLog =
        '${player.name} struck for $pDmg DMG! Target eliminated! Defeated enemy collapsed into a Scrap Pile.';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1800));
    if (_disposed) return;
    combatBannerText = null;
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
        case ConsumableEffect.heal: player.medkits++; lastEventLog = 'Acquired Wasteland Trauma Medkit.'; break;
        case ConsumableEffect.psycho: player.psychoActive = true; lastEventLog = 'Consumed Combat Psycho (+6 DMG).'; break;
        case ConsumableEffect.stealth: player.stealthboys++; lastEventLog = 'Acquired Stealthboy Cloak Unit.'; break;
        case ConsumableEffect.key: player.keys++; lastEventLog = 'Acquired Security Master Key.'; break;
        default: break;
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
