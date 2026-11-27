import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../domain/vault_models.dart';
import '../../engine/bunker_manager.dart';
import '../widgets/terminal/terminal_container.dart';

class WeaponsScreen extends StatelessWidget {
  final BunkerManager bunkerManager;

  const WeaponsScreen({super.key, required this.bunkerManager});

  List<({EquipmentItem item, int tier, String? challengeId})> _allWeapons() {
    return [
      ...GameDatabase.getWeaponsByTier(1).map(
        (w) => (item: w, tier: 1, challengeId: null),
      ),
      ...GameDatabase.getWeaponsByTier(2).map(
        (w) => (item: w, tier: 2, challengeId: null),
      ),
      (
        item: const EquipmentItem(
          id: 'w_nail_bat',
          name: 'Nail-Studded Bat',
          type: ItemType.weapon,
          minStat: 13,
          maxStat: 20,
          scrapValue: 6,
          description: 'Unlocked slugger special. Tears through rodents.',
        ),
        tier: 2,
        challengeId: 'unlock_bat',
      ),
      ...GameDatabase.getWeaponsByTier(3).map(
        (w) => (item: w, tier: 3, challengeId: null),
      ),
    ];
  }

  void _showWeaponDetail(
    BuildContext context,
    EquipmentItem weapon,
    int tier,
    String? challengeId,
  ) {
    final unlocked = challengeId == null ||
        bunkerManager.unlockedIds.contains(challengeId);
    final vaultItem = Item.fromEquipmentItem(weapon);
    final tierColor = AppTheme.tierColor(tier);
    final challenge = challengeId == null
        ? null
        : GameDatabase.challenges.firstWhere((c) => c.id == challengeId);

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: AppTheme.transparent,
          child: TerminalContainer(
            width: 340,
            padding: const EdgeInsets.all(18),
            borderColor: unlocked ? tierColor : PixelTheme.alertRed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.bgBlack,
                      child: Image.asset(
                        vaultItem.imagePath ?? 'assets/images/items/pistol.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weapon.name.toUpperCase(),
                            style: AppTheme.retroText(
                              color: tierColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'TIER $tier • ${weapon.statDescription}',
                            style: AppTheme.retroText(
                              color: PixelTheme.neonGreen,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  weapon.description,
                  style: AppTheme.retroText(
                    color: AppTheme.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  unlocked
                      ? 'STATUS: IN RANDOM CHEST / SCRAP DROP POOL'
                      : 'LOCKED: ${challenge?.description ?? "Complete challenge"}',
                  style: AppTheme.retroText(
                    color: unlocked
                        ? PixelTheme.elevatorCyan
                        : PixelTheme.warningAmber,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    '[ CLOSE ]',
                    style: AppTheme.retroText(
                      color: AppTheme.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _allWeapons();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.green),
        title: Text(
          'WEAPONS COMPENDIUM',
          style: AppTheme.retroText(
            color: PixelTheme.chestGold,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.4),
            height: 1.0,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final unlocked = entry.challengeId == null ||
              bunkerManager.unlockedIds.contains(entry.challengeId);
          final vaultItem = Item.fromEquipmentItem(entry.item);
          final color = unlocked
              ? AppTheme.tierColor(entry.tier)
              : PixelTheme.borderPixel;

          return InkWell(
            onTap: () => _showWeaponDetail(
              context,
              entry.item,
              entry.tier,
              entry.challengeId,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgBlack,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ColorFiltered(
                        colorFilter: unlocked
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.dst,
                              )
                            : const ColorFilter.mode(
                                Colors.black87,
                                BlendMode.srcATop,
                              ),
                        child: Image.asset(
                          vaultItem.imagePath ?? 'assets/images/items/pistol.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    color: PixelTheme.roomUnrevealed,
                    child: Text(
                      unlocked ? entry.item.name : 'LOCKED 🔒',
                      style: AppTheme.retroText(
                        fontSize: 9,
                        color: unlocked ? color : AppTheme.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
