import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../domain/vault_models.dart';
import 'terminal/item_grid_card.dart';

class BackpackSheet extends StatefulWidget {
  final ScoutCharacter player;
  final void Function(int index) onUseOrEquip;
  final VoidCallback? onAutoEquip;
  final bool inCombat;

  const BackpackSheet({
    super.key,
    required this.player,
    required this.onUseOrEquip,
    this.onAutoEquip,
    this.inCombat = false,
  });

  @override
  State<BackpackSheet> createState() => _BackpackSheetState();
}

class _BackpackSheetState extends State<BackpackSheet> {
  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final items = player.backpack;
    final equippedWpn = Item.fromEquipmentItem(player.equippedWeapon);
    final equippedArm = Item.fromEquipmentItem(player.equippedArmor);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppTheme.bgDark,
        border: Border(
          top: BorderSide(color: AppTheme.green, width: 2),
          left: BorderSide(color: AppTheme.green, width: 2),
          right: BorderSide(color: AppTheme.green, width: 2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EQUIPMENT & BACKPACK',
                  style: AppTheme.retroText(
                    color: AppTheme.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.green, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.green, height: 1, thickness: 2),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Equipped Loadout Showcase (Adapted from Overlord 1 DwellerEquippedCard)
                  Container(
                    padding: const EdgeInsets.all(14),
                    color: AppTheme.panelDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '[ EQUIPPED ]',
                              style: AppTheme.retroText(
                                color: AppTheme.green,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'KEYS: ${player.keys}  |  STEALTH: ${player.stealthboys}',
                              style: AppTheme.retroText(
                                color: PixelTheme.warningAmber,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (!widget.inCombat &&
                            widget.onAutoEquip != null &&
                            items.any((i) => i.isWeapon || i.isArmor)) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PixelTheme.neonGreen,
                                shape: const RoundedRectangleBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                widget.onAutoEquip!();
                                setState(() {});
                              },
                              child: Text(
                                'AUTO-EQUIP BEST',
                                style: PixelTheme.pixelStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: PixelTheme.roomVoid,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _EquippedSlotCard(item: equippedWpn)),
                            const SizedBox(width: 12),
                            Expanded(child: _EquippedSlotCard(item: equippedArm)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.green, height: 1, thickness: 2),

                  // 2. Scavenged Backpack Grid (Adapted from Overlord 1 DwellerInventorySheet)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '[ BACKPACK — TAP TO EQUIP / USE ]',
                          style: AppTheme.retroText(
                            color: AppTheme.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${items.length} / ${GameConfig.maxBackpackWeight}',
                          style: AppTheme.retroText(
                            color: items.length >= GameConfig.maxBackpackWeight
                                ? AppTheme.alertRed
                                : AppTheme.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'NO LOOT ACQUIRED YET.',
                        textAlign: TextAlign.center,
                        style: AppTheme.retroText(
                          color: AppTheme.grey,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final vaultItem = Item.fromEquipmentItem(items[index]);
                        return ItemGridCard(
                          item: vaultItem,
                          onTap: () {
                            widget.onUseOrEquip(index);
                            setState(() {});
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquippedSlotCard extends StatelessWidget {
  final Item item;

  const _EquippedSlotCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final tierColor = AppTheme.tierColor(item.tier);
    final statText = item.type == 'weapon'
        ? 'DMG: ${item.minStat}-${item.maxStat}'
        : 'DR: ${item.minStat}-${item.maxStat}';
    final imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    return Container(
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgBlack,
        border: Border.all(color: AppTheme.terminalGreen, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.name.toUpperCase(),
            style: AppTheme.retroText(
              color: tierColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.none,
                errorBuilder: (context, error, stackTrace) => Icon(
                  item.type == 'weapon' ? Icons.handyman : Icons.security,
                  color: tierColor.withValues(alpha: 0.8),
                  size: 36,
                ),
              ),
            ),
          ),
          Text(
            statText,
            style: AppTheme.retroText(
              color: AppTheme.terminalGreen,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
