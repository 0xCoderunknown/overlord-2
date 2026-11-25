import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';
import '../../../domain/models.dart';
import '../../../engine/banter_engine.dart';

class InRoomCombatBar extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final String? eventLog;
  final BanterExchange? banter;
  final bool isHeroReplying;
  final VoidCallback onHeal;
  final VoidCallback? onStealth;

  const InRoomCombatBar({
    super.key,
    required this.room,
    required this.player,
    this.eventLog,
    this.banter,
    this.isHeroReplying = false,
    required this.onHeal,
    this.onStealth,
  });

  @override
  Widget build(BuildContext context) {
    final canHeal = player.canEmergencyHeal;
    final canStealth =
        player.stealthboys > 0 && !(room.enemy?.isBoss ?? false) && onStealth != null;

    final showActions = canHeal || canStealth;
    final showBanter = banter != null && room.enemy != null;

    if (!showActions && !showBanter) {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBanter) _buildBanterPill(room, banter!, isHeroReplying),
        if (showBanter && showActions) const SizedBox(height: 3),
        if (showActions)
          Row(
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
          ),
      ],
    );
  }

  Widget _buildBanterPill(Room room, BanterExchange banter, bool isHeroReplying) {
    final speakerText = isHeroReplying
        ? 'VANCE: "${banter.heroLine}"'
        : '${room.enemy!.name.toUpperCase()}: "${banter.enemyLine}"';
    final speakerColor =
        isHeroReplying ? PixelTheme.neonGreen : PixelTheme.warningAmber;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: PixelTheme.roomVoid.withValues(alpha: 0.9),
          border: Border.all(color: PixelTheme.borderPixel, width: 1),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            speakerText,
            key: ValueKey<String>(speakerText),
            style: PixelTheme.pixelStyle(
              fontSize: 7,
              fontWeight: isHeroReplying ? FontWeight.normal : FontWeight.bold,
              color: speakerColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
