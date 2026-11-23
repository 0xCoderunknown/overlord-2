import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class InRoomCombatBar extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final bool isAutoCombatActive;
  final VoidCallback onToggleAutoCombat;
  final VoidCallback onHeal;

  const InRoomCombatBar({
    super.key,
    required this.room,
    required this.player,
    required this.isAutoCombatActive,
    required this.onToggleAutoCombat,
    required this.onHeal,
  });

  @override
  Widget build(BuildContext context) {
    final isBoss = room.enemy?.isBoss == true;
    final canHeal = player.canEmergencyHeal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: PixelTheme.roomVoid.withValues(alpha: 0.92),
        border: Border.all(
          color: isBoss ? PixelTheme.warningAmber : PixelTheme.alertRed,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Auto-Battler Status / Pause Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAutoCombatActive ? PixelTheme.alertRed : PixelTheme.roomUnrevealed,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
            onPressed: onToggleAutoCombat,
            icon: Icon(
              isAutoCombatActive ? Icons.pause : Icons.play_arrow,
              size: 12,
              color: isAutoCombatActive ? PixelTheme.roomVoid : PixelTheme.neonGreen,
            ),
            label: Text(
              isAutoCombatActive ? 'AUTO-BATTLING' : 'PAUSED (RESUME)',
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isAutoCombatActive ? PixelTheme.roomVoid : PixelTheme.neonGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Emergency Heal Button: Only active when HP <= 25%
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: canHeal ? PixelTheme.warningAmber : PixelTheme.borderPixel.withValues(alpha: 0.3),
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
            onPressed: canHeal ? onHeal : null,
            icon: Icon(
              Icons.medication,
              size: 12,
              color: canHeal ? PixelTheme.roomVoid : PixelTheme.textMuted,
            ),
            label: Text(
              canHeal
                  ? 'EMERGENCY HEAL (+50)'
                  : (player.medkits > 0 ? 'HEAL LOCKED (<=25% HP)' : 'NO MEDS (0)'),
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: canHeal ? PixelTheme.roomVoid : PixelTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
