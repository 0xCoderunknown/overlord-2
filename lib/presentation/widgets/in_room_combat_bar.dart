import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class InRoomCombatBar extends StatelessWidget {
  final Room room;
  final ScoutCharacter player;
  final String? eventLog;
  final VoidCallback onHeal;

  const InRoomCombatBar({
    super.key,
    required this.room,
    required this.player,
    this.eventLog,
    required this.onHeal,
  });

  @override
  Widget build(BuildContext context) {
    final canHeal = player.canEmergencyHeal;

    if (canHeal) {
      return Center(
        child: ElevatedButton.icon(
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
      );
    }

    if (eventLog != null && eventLog!.isNotEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: PixelTheme.roomVoid.withValues(alpha: 0.85),
          child: Text(
            '> $eventLog',
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
