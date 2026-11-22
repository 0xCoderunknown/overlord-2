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
  final VoidCallback onSearchScrap;

  const RoomStageView({
    super.key,
    required this.room,
    required this.player,
    required this.combat,
    required this.onAttack,
    required this.onUseMedkit,
    required this.onSearchScrap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PixelTheme.roomActive,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoomHeader(),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: PixelTheme.pixelBox(
                background: PixelTheme.roomVoid,
                borderColor: PixelTheme.borderPixel,
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: _buildScoutFigure()),
                  Container(
                    width: 2,
                    color: PixelTheme.borderPixel,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(child: _buildEncounterSide()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildActionFooter(),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    String typeLabel = room.type.name.toUpperCase();
    if (room.isElevator) typeLabel = 'ELEVATOR SHAFT';

    final hasScrap = room.hasUnsearchedScrap;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'SECTOR: $typeLabel',
          style: PixelTheme.pixelStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: PixelTheme.textLight,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: room.hasUnresolvedEnemy
              ? PixelTheme.alertRed
              : (hasScrap ? PixelTheme.chestGold : PixelTheme.borderPixel),
          child: Text(
            room.hasUnresolvedEnemy
                ? 'HOSTILE PRESENT'
                : (hasScrap ? 'SCRAP PILE DETECTED' : 'SECURE'),
            style: PixelTheme.pixelStyle(
              fontSize: 8,
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
        const Icon(Icons.shield, size: 38, color: PixelTheme.neonGreen),
        const SizedBox(height: 6),
        Text(
          player.name.toUpperCase(),
          style: PixelTheme.pixelStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: PixelTheme.neonGreen,
          ),
        ),
        Text(
          'ATK: ${player.equippedWeapon.minStat}-${player.equippedWeapon.maxStat}',
          style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textMuted),
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
          const Icon(Icons.pest_control, size: 38, color: PixelTheme.alertRed),
          const SizedBox(height: 6),
          Text(
            enemy.name.toUpperCase(),
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PixelTheme.alertRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            height: 5,
            width: 70,
            color: PixelTheme.roomUnrevealed,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hpRatio,
              child: Container(color: PixelTheme.alertRed),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${enemy.currentHp}/${enemy.maxHp} HP',
            style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textMuted),
          ),
        ],
      );
    }

    if (room.scrapPile != null) {
      final scrap = room.scrapPile!;
      return GestureDetector(
        onTap: scrap.isSearched ? null : onSearchScrap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hardware,
              size: 38,
              color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
            ),
            const SizedBox(height: 6),
            Text(
              scrap.isSearched ? 'CLEARED SCRAP' : 'SCRAP PILE',
              style: PixelTheme.pixelStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
              ),
            ),
            Text(
              scrap.isSearched ? 'Empty junk searched' : 'Tap to scavenge',
              style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textMuted),
            ),
          ],
        ),
      );
    }

    if (room.isElevator) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.elevator, size: 38, color: PixelTheme.elevatorCyan),
          const SizedBox(height: 6),
          Text(
            'ELEVATOR SHAFT',
            style: PixelTheme.pixelStyle(fontSize: 10, color: PixelTheme.elevatorCyan),
          ),
          Text(
            'Tap elevator on other floors',
            style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.done_all, size: 32, color: PixelTheme.borderPixel),
        const SizedBox(height: 6),
        Text(
          'SECTOR CLEAR',
          style: PixelTheme.pixelStyle(fontSize: 9, color: PixelTheme.textMuted),
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
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: onAttack,
              icon: const Icon(Icons.flash_on, size: 14, color: PixelTheme.roomVoid),
              label: Text(
                'ATTACK TARGET',
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
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
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: player.medkits > 0 ? onUseMedkit : null,
              icon: const Icon(Icons.medication, size: 14, color: PixelTheme.roomVoid),
              label: Text(
                'HEAL (${player.medkits})',
                style: PixelTheme.pixelStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (room.hasUnsearchedScrap) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: PixelTheme.chestGold,
          shape: const RoundedRectangleBorder(),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: onSearchScrap,
        icon: const Icon(Icons.search, size: 16, color: PixelTheme.roomVoid),
        label: Text(
          'SCAVENGE SCRAP PILE',
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
