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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Text(
                'SCOUT: ${player.name.toUpperCase()}',
                style: PixelTheme.pixelStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.neonGreen,
                ),
              ),
              Text(
                'L${floorIndex + 1} : R${roomIndex + 1}',
                style: PixelTheme.pixelStyle(
                  fontSize: 13,
                  color: PixelTheme.elevatorCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // HP Bar & Stats
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
                            fontSize: 10,
                            color: PixelTheme.textMuted,
                          ),
                        ),
                        Text(
                          '${player.currentHp} / ${player.maxHp} HP',
                          style: PixelTheme.pixelStyle(
                            fontSize: 10,
                            color: hpRatio < 0.3 ? PixelTheme.alertRed : PixelTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
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
              const SizedBox(width: 16),
              // Caps & Medkits
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CAPS: ${player.caps}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 11,
                      color: PixelTheme.chestGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MEDKITS: ${player.medkits}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 11,
                      color: PixelTheme.elevatorCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (eventLog != null && eventLog!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: PixelTheme.roomUnrevealed,
              child: Text(
                '> $eventLog',
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
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

