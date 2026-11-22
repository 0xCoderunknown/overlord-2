import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../engine/combat_engine.dart';

class PixelRoomView extends StatelessWidget {
  final Room room;
  final bool isActive;
  final bool isMoveTarget;
  final ScoutCharacter player;
  final CombatEngine? combat;
  final VoidCallback onTapRoom;
  final VoidCallback onAttack;
  final VoidCallback onHeal;
  final VoidCallback onSearchScrap;

  const PixelRoomView({
    super.key,
    required this.room,
    required this.isActive,
    required this.isMoveTarget,
    required this.player,
    required this.combat,
    required this.onTapRoom,
    required this.onAttack,
    required this.onHeal,
    required this.onSearchScrap,
  });

  @override
  Widget build(BuildContext context) {
    if (room.state == RoomState.unrevealed) {
      return _buildUnrevealedRoom();
    }
    if (room.state == RoomState.outline) {
      return _buildOutlineRoom();
    }
    return _buildRevealedRoom();
  }

  Widget _buildUnrevealedRoom() {
    return Container(
      width: 260,
      height: 170,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PixelTheme.roomVoid,
        border: Border.all(color: PixelTheme.borderPixel, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: PixelTheme.borderPixel, size: 24),
            const SizedBox(height: 4),
            Text(
              'UNEXPLORED',
              style: PixelTheme.pixelStyle(
                fontSize: 9,
                color: PixelTheme.borderPixel,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineRoom() {
    return GestureDetector(
      onTap: isMoveTarget ? onTapRoom : null,
      child: Container(
        width: 260,
        height: 170,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: PixelTheme.roomUnrevealed,
          border: Border.all(
            color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.roomDiscoveredBorder,
            width: isMoveTarget ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                room.isElevator ? Icons.swap_vert : Icons.meeting_room,
                color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                room.isElevator
                    ? 'ELEVATOR SHAFT'
                    : (room.type == RoomType.bossChamber ? 'WARNING: APEX CHAMBER' : 'ADJACENT SECTOR'),
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: room.type == RoomType.bossChamber
                      ? PixelTheme.alertRed
                      : (isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted),
                ),
              ),
              if (isMoveTarget) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: PixelTheme.neonGreen,
                  child: Text(
                    'TAP TO ENTER',
                    style: PixelTheme.pixelStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.roomVoid,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevealedRoom() {
    final isBossChamber = room.type == RoomType.bossChamber;

    return Container(
      width: 260,
      height: 170,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PixelTheme.roomCleared,
        border: Border.all(
          color: isActive
              ? (isBossChamber ? PixelTheme.alertRed : PixelTheme.neonGreen)
              : PixelTheme.borderPixel,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          _buildRoomBackground(),
          Positioned(
            top: 6,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.isElevator
                      ? 'ELEVATOR SHAFT'
                      : (isBossChamber ? 'APEX BOSS CHAMBER' : room.type.name.toUpperCase()),
                  style: PixelTheme.pixelStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isBossChamber
                        ? PixelTheme.alertRed
                        : (isActive ? PixelTheme.neonGreen : PixelTheme.textMuted),
                  ),
                ),
                Text(
                  'F${room.floorIndex + 1}:R${room.roomIndex + 1}',
                  style: PixelTheme.pixelStyle(
                    fontSize: 8,
                    color: PixelTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isActive) _buildScoutInRoom() else const SizedBox(width: 40),
                _buildRoomInteriorContent(),
              ],
            ),
          ),
          if (isActive && room.hasUnresolvedEnemy)
            Positioned(
              top: 26,
              left: 16,
              right: 16,
              child: _buildInRoomCombatBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RoomInteriorPainter(isElevator: room.isElevator),
      ),
    );
  }

  Widget _buildScoutInRoom() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shield, color: PixelTheme.neonGreen, size: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          color: PixelTheme.roomVoid,
          child: Text(
            player.name.toUpperCase(),
            style: PixelTheme.pixelStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: PixelTheme.neonGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomInteriorContent() {
    if (room.hasUnresolvedEnemy) {
      final enemy = room.enemy!;
      final hpRatio = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enemy.isBoss) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: PixelTheme.alertRed,
              child: Text(
                '★ APEX BOSS ★',
                style: PixelTheme.pixelStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
            const SizedBox(height: 2),
          ],
          Container(
            height: 4,
            width: enemy.isBoss ? 70 : 50,
            color: PixelTheme.roomVoid,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hpRatio,
              child: Container(color: PixelTheme.alertRed),
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            enemy.isBoss ? Icons.smart_toy : Icons.pest_control,
            color: PixelTheme.alertRed,
            size: enemy.isBoss ? 42 : 34,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: PixelTheme.roomVoid,
            child: Text(
              '${enemy.name.toUpperCase()} (${enemy.currentHp}HP)',
              style: PixelTheme.pixelStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: PixelTheme.alertRed,
              ),
            ),
          ),
        ],
      );
    }

    if (room.scrapPile != null) {
      final scrap = room.scrapPile!;
      return GestureDetector(
        onTap: (isActive && !scrap.isSearched) ? onSearchScrap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hardware,
              color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
              size: 32,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: PixelTheme.roomVoid,
              child: Text(
                scrap.isSearched ? 'CLEARED SCRAP' : 'TAP TO SEARCH',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (room.isElevator) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.elevator, color: PixelTheme.elevatorCyan, size: 36),
          Text(
            'ELEVATOR',
            style: PixelTheme.pixelStyle(fontSize: 7, color: PixelTheme.elevatorCyan),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: PixelTheme.borderPixel, size: 22),
        Text(
          'CLEARED',
          style: PixelTheme.pixelStyle(fontSize: 7, color: PixelTheme.borderPixel),
        ),
      ],
    );
  }

  Widget _buildInRoomCombatBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PixelTheme.roomVoid.withValues(alpha: 0.9),
        border: Border.all(
          color: room.enemy?.isBoss == true ? PixelTheme.warningAmber : PixelTheme.alertRed,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PixelTheme.alertRed,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: onAttack,
            icon: const Icon(Icons.flash_on, size: 12, color: PixelTheme.roomVoid),
            label: Text(
              'ATTACK',
              style: PixelTheme.pixelStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: PixelTheme.roomVoid,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: PixelTheme.elevatorCyan,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            onPressed: player.medkits > 0 ? onHeal : null,
            icon: const Icon(Icons.medication, size: 12, color: PixelTheme.roomVoid),
            label: Text(
              'HEAL (${player.medkits})',
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: PixelTheme.roomVoid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomInteriorPainter extends CustomPainter {
  final bool isElevator;

  _RoomInteriorPainter({required this.isElevator});

  @override
  void paint(Canvas canvas, Size size) {
    final floorPaint = Paint()..color = const Color(0xFF1F2430);
    final ceilingPaint = Paint()..color = const Color(0xFF161A23);
    final beamPaint = Paint()
      ..color = const Color(0xFF2C3242)
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(0, size.height - 10, size.width, 10), floorPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 14), ceilingPaint);

    canvas.drawLine(Offset(size.width * 0.33, 14), Offset(size.width * 0.33, size.height - 10), beamPaint);
    canvas.drawLine(Offset(size.width * 0.66, 14), Offset(size.width * 0.66, size.height - 10), beamPaint);

    if (isElevator) {
      final cablePaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height), cablePaint);
      canvas.drawLine(Offset(size.width * 0.55, 0), Offset(size.width * 0.55, size.height), cablePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
