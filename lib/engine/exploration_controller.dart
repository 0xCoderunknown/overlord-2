import 'package:material_ui/material_ui.dart';
import '../domain/models.dart';
import 'combat_engine.dart';

class ExplorationController extends ChangeNotifier {
  final Building building;
  final ScoutCharacter player;

  int currentFloorIndex;
  int currentRoomIndex;

  CombatEngine? activeCombat;
  String? lastEventLog;

  ExplorationController({
    required this.building,
    required this.player,
    this.currentFloorIndex = 0,
    this.currentRoomIndex = 0,
  }) {
    _initStartingRoom();
  }

  Room get currentRoom => building.floors[currentFloorIndex].rooms[currentRoomIndex];

  void _initStartingRoom() {
    currentRoom.state = RoomState.active;
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
  }

  bool canMoveTo(int targetFloor, int targetRoom) {
    // Cannot move if locked in active combat
    if (activeCombat != null && activeCombat!.status == CombatStatus.inProgress) {
      return false;
    }

    final target = building.getRoom(targetFloor, targetRoom);
    if (target == null) return false;

    // Cannot move to unrevealed rooms
    if (target.state == RoomState.unrevealed) return false;

    // Same room
    if (targetFloor == currentFloorIndex && targetRoom == currentRoomIndex) {
      return false;
    }

    // Horizontal movement on same floor: must be adjacent (step == 1)
    if (targetFloor == currentFloorIndex) {
      return (targetRoom - currentRoomIndex).abs() == 1;
    }

    // Vertical movement between floors: both must be elevators and adjacent floors
    if (currentRoom.isElevator && target.isElevator) {
      return (targetFloor - currentFloorIndex).abs() == 1;
    }

    return false;
  }

  bool moveTo(int targetFloor, int targetRoom) {
    if (!canMoveTo(targetFloor, targetRoom)) return false;

    // Previous room becomes cleared
    currentRoom.state = RoomState.cleared;

    // Move to new room
    currentFloorIndex = targetFloor;
    currentRoomIndex = targetRoom;
    currentRoom.state = RoomState.active;

    // Reveal adjacent rooms in fog of war
    _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);

    // Resolve room content
    if (currentRoom.hasUnresolvedEnemy) {
      activeCombat = CombatEngine(
        player: player,
        enemy: currentRoom.enemy!,
      );
      lastEventLog = 'Encountered hostile ${currentRoom.enemy!.name}!';
    } else {
      activeCombat = null;
      if (currentRoom.hasUnclaimedLoot) {
        lastEventLog = 'Discovered a container: ${currentRoom.loot!.name}';
      } else if (currentRoom.isElevator) {
        lastEventLog = 'Reached the Elevator Shaft. Vertical transit available.';
      } else {
        lastEventLog = 'Room is quiet and deserted.';
      }
    }

    notifyListeners();
    return true;
  }

  void _revealAdjacentRooms(int floorIdx, int roomIdx) {
    final floor = building.floors[floorIdx];

    // Reveal left room
    if (roomIdx > 0) {
      final left = floor.rooms[roomIdx - 1];
      if (left.state == RoomState.unrevealed) {
        left.state = RoomState.outline;
      }
    }

    // Reveal right room
    if (roomIdx < floor.rooms.length - 1) {
      final right = floor.rooms[roomIdx + 1];
      if (right.state == RoomState.unrevealed) {
        right.state = RoomState.outline;
      }
    }

    // If current room is an elevator, reveal connecting elevators on other floors
    if (floor.rooms[roomIdx].isElevator) {
      // Floor above
      if (floorIdx + 1 < building.floors.length) {
        final above = building.floors[floorIdx + 1].rooms[roomIdx];
        if (above.state == RoomState.unrevealed) {
          above.state = RoomState.outline;
        }
      }
      // Floor below
      if (floorIdx - 1 >= 0) {
        final below = building.floors[floorIdx - 1].rooms[roomIdx];
        if (below.state == RoomState.unrevealed) {
          below.state = RoomState.outline;
        }
      }
    }
  }

  void claimRoomLoot() {
    if (!currentRoom.hasUnclaimedLoot) return;

    final loot = currentRoom.loot!;
    currentRoom.isLootClaimed = true;

    if (loot.caps > 0) {
      player.caps += loot.caps;
      lastEventLog = 'Secured ${loot.caps} Caps from ${loot.name}!';
    }
    if (loot.healAmount > 0) {
      player.medkits += 1;
      lastEventLog = 'Secured 1x ${loot.name} into backpack!';
    }

    notifyListeners();
  }

  void executeCombatRound() {
    if (activeCombat == null) return;

    final result = activeCombat!.executeRound();
    lastEventLog = result.narrative;

    if (result.status == CombatStatus.victory) {
      currentRoom.state = RoomState.cleared;
      _revealAdjacentRooms(currentFloorIndex, currentRoomIndex);
    }

    notifyListeners();
  }

  void useMedkit() {
    if (activeCombat != null) {
      final healed = activeCombat!.useMedkit();
      if (healed) {
        lastEventLog = '${player.name} injected a Medkit (+50 HP).';
        notifyListeners();
      }
    } else if (player.medkits > 0 && player.currentHp < player.maxHp) {
      player.medkits--;
      player.heal(50);
      lastEventLog = '${player.name} used a Medkit (+50 HP).';
      notifyListeners();
    }
  }
}

