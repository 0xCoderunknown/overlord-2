import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';
import '../../../domain/models.dart';
import '../../../engine/banter_engine.dart';

class InRoomCombatBar extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final String? eventLog;
  final BanterExchange? banter;
  final VoidCallback onHeal;
  final VoidCallback? onStealth;

  const InRoomCombatBar({
    super.key,
    required this.room,
    required this.player,
    this.eventLog,
    this.banter,
    required this.onHeal,
    this.onStealth,
  });

  @override
  Widget build(BuildContext context) {
    final canHeal = player.canEmergencyHeal;
    final canStealth =
        player.stealthboys > 0 && !(room.enemy?.isBoss ?? false) && onStealth != null;

    if (canHeal || canStealth) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (canHeal)
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
          if (canHeal && canStealth) const SizedBox(width: 6),
          if (canStealth)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.elevatorCyan,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                elevation: 4,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onStealth,
              icon: const Icon(Icons.visibility_off, size: 10, color: PixelTheme.roomVoid),
              label: Text(
                'STEALTH (${player.stealthboys})',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
        ],
      );
    }

    if (banter != null && room.enemy != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: PixelTheme.roomVoid.withValues(alpha: 0.9),
            border: Border.all(color: PixelTheme.borderPixel, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${room.enemy!.name.toUpperCase()}: "${banter!.enemyLine}"',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.warningAmber,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                'VANCE: "${banter!.heroLine}"',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  color: PixelTheme.textLight,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    if (eventLog != null && eventLog!.isNotEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: PixelTheme.roomVoid.withValues(alpha: 0.85),
          child: Text(
            eventLog!,
            style: PixelTheme.pixelStyle(
              fontSize: 7,
              color: PixelTheme.textLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
