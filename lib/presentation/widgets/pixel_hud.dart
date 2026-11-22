import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class PixelHud extends StatelessWidget {
  final ScoutCharacter player;
  final int floorIndex;
  final int roomIndex;
  final String? eventLog;

  const PixelHud({
    super.key,
    required this.player,
    required this.floorIndex,
    required this.roomIndex,
    this.eventLog,
  });

  @override
  Widget build(BuildContext context) {
    final hpRatio = (player.currentHp / player.maxHp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.neonGreen,
                    ),
                  ),
                  if (player.psychoActive) ...[
                    const SizedBox(width: 8),
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
              Text(
                'L${floorIndex + 1} : R${roomIndex + 1}',
                style: PixelTheme.pixelStyle(
                  fontSize: 12,
                  color: PixelTheme.elevatorCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Vitality Bar & Wealth
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'VITALITY',
                          style: PixelTheme.pixelStyle(
                            fontSize: 9,
                            color: PixelTheme.textMuted,
                          ),
                        ),
                        Text(
                          '${player.currentHp} / ${player.maxHp} HP',
                          style: PixelTheme.pixelStyle(
                            fontSize: 9,
                            color: hpRatio < 0.3 ? PixelTheme.alertRed : PixelTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: PixelTheme.roomUnrevealed,
                        border: Border.all(color: PixelTheme.borderPixel),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: hpRatio,
                        child: Container(
                          color: hpRatio < 0.3
                              ? PixelTheme.alertRed
                              : (hpRatio < 0.6 ? PixelTheme.warningAmber : PixelTheme.terminalGreen),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'GOLD: ${player.gold}',
                style: PixelTheme.pixelStyle(
                  fontSize: 11,
                  color: PixelTheme.chestGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'MEDS: ${player.medkits}',
                style: PixelTheme.pixelStyle(
                  fontSize: 11,
                  color: PixelTheme.elevatorCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Equipped gear tags
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
          if (eventLog != null && eventLog!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: PixelTheme.roomUnrevealed,
              child: Text(
                '> $eventLog',
                style: PixelTheme.pixelStyle(
                  fontSize: 9,
                  color: PixelTheme.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
