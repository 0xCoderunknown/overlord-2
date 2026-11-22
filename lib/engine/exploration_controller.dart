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
      lastEventLog = 'Hostile ${currentRoom.enemy!.name} engaged!';
    } else {
      activeCombat = null;
      if (currentRoom.hasUnsearchedScrap) {
        lastEventLog = 'A salvageable Scrap Pile lies in the room.';
      } else if (currentRoom.isElevator) {
        lastEventLog = 'Elevator Shaft. Vertical transit online.';
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

  void executeCombatRound() {
    if (activeCombat == null) return;

    final result = activeCombat!.executeRound();
    lastEventLog = result.narrative;

    if (result.status == CombatStatus.victory) {
      // Enemy defeated -> spawns a scrap pile in the room
      currentRoom.scrapPile = generator.generateScrapPile(currentFloorIndex);
      currentRoom.state = RoomState.cleared;
      _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
      lastEventLog = '${result.narrative} The defeated enemy collapsed into a Scrap Pile!';
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
          lastEventLog = 'Stowed Medkit (+50 HP) in backpack.';
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

  void useMedkit() {
    if (player.medkits <= 0 || player.currentHp >= player.maxHp) return;
    player.medkits--;
    player.heal(50);
    lastEventLog = '${player.name} used Medkit (+50 HP).';
    notifyListeners();
  }

  void activatePsycho() {
    if (player.psychoActive) return;
    player.psychoActive = true;
    lastEventLog = 'Injected Combat Psycho (+6 DMG).';
    notifyListeners();
  }
}
