import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class ExpeditionBottomBar extends StatelessWidget {
  final ScoutCharacter player;
  final bool canExtract;
  final VoidCallback onTapBackpack;
  final VoidCallback onTapMedkit;
  final VoidCallback onTapExtract;

  const ExpeditionBottomBar({
    super.key,
    required this.player,
    required this.canExtract,
    required this.onTapBackpack,
    required this.onTapMedkit,
    required this.onTapExtract,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = player.backpack.isNotEmpty;
    final canHeal = player.canEmergencyHeal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: PixelTheme.roomVoid,
        border: Border(
          top: BorderSide(color: PixelTheme.borderPixel, width: 2),
        ),
      ),
      child: Row(
        children: [
          // 1. Prominent Backpack Button
          Expanded(
            flex: 3,
            child: _ActionButton(
              icon: Icons.backpack,
              label: 'BACKPACK (${player.backpack.length})',
              subLabel: hasItems ? 'TAP TO EQUIP / USE' : 'EMPTY',
              color: hasItems ? PixelTheme.neonGreen : PixelTheme.textMuted,
              borderColor: hasItems ? PixelTheme.neonGreen : PixelTheme.borderPixel,
              onPressed: onTapBackpack,
            ),
          ),
          const SizedBox(width: 8),

          // 2. Emergency Medkit Button
          Expanded(
            flex: 2,
            child: _ActionButton(
              icon: Icons.medical_services,
              label: 'MED (${player.medkits})',
              subLabel: canHeal ? 'HEAL +50' : '<=25% HP',
              color: canHeal ? PixelTheme.elevatorCyan : PixelTheme.textMuted,
              borderColor: canHeal ? PixelTheme.elevatorCyan : PixelTheme.borderPixel,
              onPressed: canHeal ? onTapMedkit : null,
            ),
          ),

          // 3. Extract Button (when boss defeated or at airlock with loot)
          if (canExtract) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PixelTheme.neonGreen,
                  shape: const RoundedRectangleBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
                onPressed: onTapExtract,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EXTRACT',
                      style: PixelTheme.pixelStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PixelTheme.roomVoid,
                      ),
                    ),
                    Text(
                      '+${player.gold}C / ${player.backpack.length} LOOT',
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: PixelTheme.roomVoid,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color color;
  final Color borderColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.borderColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: PixelTheme.roomUnrevealed,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subLabel,
                    style: PixelTheme.pixelStyle(
                      fontSize: 8,
                      color: color.withValues(alpha: 0.75),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
