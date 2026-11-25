import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class PixelHud extends StatelessWidget {
  final ScoutCharacter player;
  final int floorIndex;
  final int roomIndex;

  const PixelHud({
    super.key,
    required this.player,
    required this.floorIndex,
    required this.roomIndex,
  });

  @override
  Widget build(BuildContext context) {
    final hpColor = player.currentHp <= (player.maxHp * 0.25).ceil()
        ? PixelTheme.alertRed
        : PixelTheme.neonGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: PixelTheme.roomVoid,
        border: Border(
          bottom: BorderSide(color: PixelTheme.borderPixel, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'SCOUT: ${player.name.toUpperCase()}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.neonGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${player.currentHp}/${player.maxHp} HP',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: hpColor,
                    ),
                  ),
                  if (player.psychoActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: PixelTheme.alertRed,
                      child: Text(
                        'PSYCHO',
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
              Row(
                children: [
                  Text(
                    'CAPS: ${player.gold}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      color: PixelTheme.chestGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'KEYS: ${player.keys}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      color: PixelTheme.warningAmber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'F${floorIndex + 1}:R${roomIndex + 1}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10,
                      color: PixelTheme.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: PixelTheme.roomUnrevealed,
                  child: Text(
                    'WPN: ${player.equippedWeapon.name.toUpperCase()} (${player.equippedWeapon.minStat}-${player.equippedWeapon.maxStat})',
                    style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textLight),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  color: PixelTheme.roomUnrevealed,
                  child: Text(
                    'ARM: ${player.equippedArmor.name.toUpperCase()} (${player.equippedArmor.minStat}-${player.equippedArmor.maxStat} DR)',
                    style: PixelTheme.pixelStyle(fontSize: 8, color: PixelTheme.textLight),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
