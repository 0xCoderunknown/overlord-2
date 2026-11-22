import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class BuildingCutawayView extends StatelessWidget {
  final Building building;
  final int currentFloorIndex;
  final int currentRoomIndex;
  final Function(int floorIndex, int roomIndex) onRoomTap;
  final bool Function(int floorIndex, int roomIndex) canMoveTo;

  const BuildingCutawayView({
    super.key,
    required this.building,
    required this.currentFloorIndex,
    required this.currentRoomIndex,
    required this.onRoomTap,
    required this.canMoveTo,
  });

  @override
  Widget build(BuildContext context) {
    // Top floor rendered at the top, Ground floor at bottom
    final reversedFloors = building.floors.reversed.toList();

    return Container(
      color: PixelTheme.roomVoid,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUILDING CROSS-SECTION // FOG-OF-WAR',
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
                  color: PixelTheme.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'TAP OUTLINED ROOM TO ADVANCE',
                style: PixelTheme.pixelStyle(
                  fontSize: 9,
                  color: PixelTheme.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...reversedFloors.map((floor) => _buildFloorRow(floor)),
        ],
      ),
    );
  }

  Widget _buildFloorRow(Floor floor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'F${floor.floorIndex + 1}',
              style: PixelTheme.pixelStyle(
                fontSize: 10,
                color: floor.floorIndex == currentFloorIndex
                    ? PixelTheme.neonGreen
                    : PixelTheme.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: floor.rooms.map((room) {
                return Expanded(
                  child: _buildRoomCell(room),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCell(Room room) {
    final isCurrent = room.floorIndex == currentFloorIndex &&
        room.roomIndex == currentRoomIndex;
    final isMoveTarget = canMoveTo(room.floorIndex, room.roomIndex);

    Color bg;
    Color border;
    Widget content;

    switch (room.state) {
      case RoomState.unrevealed:
        bg = PixelTheme.roomUnrevealed;
        border = PixelTheme.borderPixel;
        content = Center(
          child: Text(
            '?',
            style: PixelTheme.pixelStyle(
              fontSize: 11,
              color: PixelTheme.borderPixel,
            ),
          ),
        );
        break;

      case RoomState.outline:
        bg = isMoveTarget ? PixelTheme.roomOutline : PixelTheme.roomUnrevealed;
        border = isMoveTarget ? PixelTheme.neonGreen : PixelTheme.roomDiscoveredBorder;
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                room.isElevator ? Icons.swap_vert : Icons.arrow_forward,
                size: 14,
                color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted,
              ),
              Text(
                room.isElevator ? 'ELEV' : 'ROOM',
                style: PixelTheme.pixelStyle(
                  fontSize: 8,
                  color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted,
                ),
              ),
            ],
          ),
        );
        break;

      case RoomState.active:
        bg = PixelTheme.roomActive;
        border = PixelTheme.neonGreen;
        content = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person,
                size: 14,
                color: PixelTheme.neonGreen,
              ),
              Text(
                'TEAM',
                style: PixelTheme.pixelStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.neonGreen,
                ),
              ),
            ],
          ),
        );
        break;

      case RoomState.cleared:
        bg = PixelTheme.roomCleared;
        border = isCurrent ? PixelTheme.neonGreen : PixelTheme.borderPixel;
        content = Center(
          child: Icon(
            room.isElevator ? Icons.elevator : Icons.check,
            size: 13,
            color: room.isElevator ? PixelTheme.elevatorCyan : PixelTheme.borderPixel,
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: () {
        if (isMoveTarget) {
          onRoomTap(room.floorIndex, room.roomIndex);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: border,
            width: (isCurrent || isMoveTarget) ? 2 : 1,
          ),
        ),
        child: content,
      ),
    );
  }
}

