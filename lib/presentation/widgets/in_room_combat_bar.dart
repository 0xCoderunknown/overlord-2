import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class InRoomCombatBar extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final String? bannerText;
  final VoidCallback onHeal;

  const InRoomCombatBar({
    super.key,
    required this.room,
    required this.player,
    this.bannerText,
    required this.onHeal,
  });

  @override
  Widget build(BuildContext context) {
    final isBoss = room.enemy?.isBoss == true;
    final canHeal = player.canEmergencyHeal;
    final isDefeated = bannerText == 'ENEMY DEFEATED';

    final text = bannerText ?? (isBoss ? 'APEX DUEL IN PROGRESS' : '1V1 DUEL IN PROGRESS');
    final formattedText = text.startsWith('[') ? text : '[$text]';
    final statusColor = isDefeated
        ? PixelTheme.neonGreen
        : (isBoss ? PixelTheme.warningAmber : PixelTheme.alertRed);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: PixelTheme.roomVoid.withValues(alpha: 0.95),
              border: Border.all(
                color: statusColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDefeated ? Icons.check : Icons.flash_on,
                  size: 11,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  formattedText,
                  style: PixelTheme.pixelStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          if (canHeal) ...[
            const SizedBox(height: 3),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.warningAmber,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                elevation: 4,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onHeal,
              icon: const Icon(Icons.medication, size: 10, color: PixelTheme.roomVoid),
              label: Text(
                'EMERGENCY HEAL (+50 HP)',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
