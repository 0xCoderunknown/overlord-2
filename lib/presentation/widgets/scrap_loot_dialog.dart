import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class ScrapLootDialog extends StatelessWidget {
  final EquipmentItem item;
  final ScoutCharacter player;
  final VoidCallback onEquip;
  final VoidCallback onScrap;

  const ScrapLootDialog({
    super.key,
    required this.item,
    required this.player,
    required this.onEquip,
    required this.onScrap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.chestGold,
          borderWidth: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SALVAGE DISCOVERED',
                  style: PixelTheme.pixelStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: PixelTheme.chestGold,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: PixelTheme.roomOutline,
                  child: Text(
                    item.type.name.toUpperCase(),
                    style: PixelTheme.pixelStyle(
                      fontSize: 9,
                      color: PixelTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Icon(
                item.isWeapon
                    ? Icons.flash_on
                    : (item.isArmor ? Icons.shield : Icons.science),
                size: 36,
                color: PixelTheme.chestGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name.toUpperCase(),
              style: PixelTheme.pixelStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              item.statDescription,
              style: PixelTheme.pixelStyle(
                fontSize: 11,
                color: PixelTheme.neonGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.description,
                style: PixelTheme.pixelStyle(
                  fontSize: 10,
                  color: PixelTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            _buildComparisonRow(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PixelTheme.neonGreen,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onEquip,
                    child: Text(
                      item.isConsumable ? 'TAKE' : 'EQUIP',
                      style: PixelTheme.pixelStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PixelTheme.roomVoid,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PixelTheme.chestGold,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onScrap,
                    child: Text(
                      'SCRAP (+${item.scrapValue}G)',
                      style: PixelTheme.pixelStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PixelTheme.roomVoid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow() {
    if (item.isConsumable) return const SizedBox.shrink();

    final currentStat = item.isWeapon
        ? 'EQUIPPED: ${player.equippedWeapon.minStat}-${player.equippedWeapon.maxStat} DMG'
        : 'EQUIPPED: ${player.equippedArmor.minStat}-${player.equippedArmor.maxStat} DR';

    return Container(
      padding: const EdgeInsets.all(8),
      color: PixelTheme.roomUnrevealed,
      child: Text(
        currentStat,
        style: PixelTheme.pixelStyle(
          fontSize: 10,
          color: PixelTheme.textMuted,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
