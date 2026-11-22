import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../engine/combat_engine.dart';

class RoomStageView extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final CombatEngine? combat;
  final VoidCallback onAttack;
  final VoidCallback onUseMedkit;
  final VoidCallback onClaimLoot;

  const RoomStageView({
    super.key,
    required this.room,
    required this.player,
    required this.combat,
    required this.onAttack,
    required this.onUseMedkit,
    required this.onClaimLoot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelTheme.roomActive,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoomHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: PixelTheme.pixelBox(
                background: PixelTheme.roomVoid,
                borderColor: PixelTheme.borderPixel,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Scout side
                  Expanded(child: _buildScoutFigure()),
                  Container(
                    width: 2,
                    color: PixelTheme.borderPixel,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  // Encounter side
                  Expanded(child: _buildEncounterSide()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildActionFooter(),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    String typeLabel = room.type.name.toUpperCase();
    if (room.isElevator) typeLabel = 'ELEVATOR SHAFT';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ROOM SECTOR: $typeLabel',
          style: PixelTheme.pixelStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: PixelTheme.textLight,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: room.hasUnresolvedEnemy
              ? PixelTheme.alertRed
              : (room.hasUnclaimedLoot ? PixelTheme.chestGold : PixelTheme.borderPixel),
          child: Text(
            room.hasUnresolvedEnemy
                ? 'HOSTILE DETECTED'
                : (room.hasUnclaimedLoot ? 'SUPPLIES FOUND' : 'CLEAR'),
            style: PixelTheme.pixelStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: PixelTheme.roomVoid,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoutFigure() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.shield,
          size: 42,
          color: PixelTheme.neonGreen,
        ),
        const SizedBox(height: 8),
        Text(
          player.name.toUpperCase(),
          style: PixelTheme.pixelStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: PixelTheme.neonGreen,
          ),
        ),
        Text(
          'DMG: ${player.minDamage}-${player.maxDamage}',
          style: PixelTheme.pixelStyle(
            fontSize: 9,
            color: PixelTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildEncounterSide() {
    if (room.hasUnresolvedEnemy) {
      final enemy = room.enemy!;
      final hpRatio = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.pest_control,
            size: 42,
            color: PixelTheme.alertRed,
          ),
          const SizedBox(height: 8),
          Text(
            enemy.name.toUpperCase(),
            style: PixelTheme.pixelStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: PixelTheme.alertRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Enemy HP bar
          Container(
            height: 6,
            width: 80,
            color: PixelTheme.roomUnrevealed,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hpRatio,
              child: Container(color: PixelTheme.alertRed),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${enemy.currentHp} / ${enemy.maxHp} HP',
            style: PixelTheme.pixelStyle(
              fontSize: 9,
              color: PixelTheme.textMuted,
            ),
          ),
        ],
      );
    }

    if (room.hasUnclaimedLoot) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inventory_2,
            size: 42,
            color: PixelTheme.chestGold,
          ),
          const SizedBox(height: 8),
          Text(
            room.loot!.name.toUpperCase(),
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PixelTheme.chestGold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (room.isElevator) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.elevator,
            size: 42,
            color: PixelTheme.elevatorCyan,
          ),
          const SizedBox(height: 8),
          Text(
            'ELEVATOR SHAFT',
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              color: PixelTheme.elevatorCyan,
            ),
          ),
          Text(
            'Tap elevator on other floors to ride',
            style: PixelTheme.pixelStyle(
              fontSize: 8,
              color: PixelTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.done_all,
          size: 36,
          color: PixelTheme.borderPixel,
        ),
        const SizedBox(height: 8),
        Text(
          'SECTOR SECURE',
          style: PixelTheme.pixelStyle(
            fontSize: 10,
            color: PixelTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter() {
    if (room.hasUnresolvedEnemy) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.alertRed,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onAttack,
              icon: const Icon(Icons.flash_on, size: 16, color: PixelTheme.roomVoid),
              label: Text(
                'ATTACK TARGET',
                style: PixelTheme.pixelStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.elevatorCyan,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: player.medkits > 0 ? onUseMedkit : null,
              icon: const Icon(Icons.medication, size: 16, color: PixelTheme.roomVoid),
              label: Text(
                'MEDKIT (${player.medkits})',
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (room.hasUnclaimedLoot) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: PixelTheme.chestGold,
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onClaimLoot,
        icon: const Icon(Icons.lock_open, size: 16, color: PixelTheme.roomVoid),
        label: Text(
          'LOOT CONTAINER',
          style: PixelTheme.pixelStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: PixelTheme.roomVoid,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

