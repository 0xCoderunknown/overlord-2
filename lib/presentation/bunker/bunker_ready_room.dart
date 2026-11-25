import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../domain/vault_models.dart';
import '../widgets/room/room_background_view.dart';

class BunkerReadyRoom extends StatelessWidget {
  final Scavenger? scout;
  final Item? bestWeapon;
  final Item? bestArmor;
  final int medkitCount;

  const BunkerReadyRoom({
    super.key,
    required this.scout,
    required this.bestWeapon,
    required this.bestArmor,
    required this.medkitCount,
  });

  @override
  Widget build(BuildContext context) {
    final name = (scout?.name ?? 'VANCE').toUpperCase();
    final hp = scout?.hp ?? 100;
    final maxHp = scout?.maxHp ?? 100;
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);

    final wpnName = bestWeapon?.name.toUpperCase() ?? 'CRUDE PIPE PISTOL';
    final wpnStat = bestWeapon != null
        ? '${bestWeapon!.minStat}-${bestWeapon!.maxStat} DMG'
        : '6-12 DMG';
    final wpnImg = bestWeapon?.imagePath ?? 'assets/images/items/pistol.png';

    final armName = bestArmor?.name.toUpperCase() ?? 'TAPED PHONEBOOK';
    final armStat = bestArmor != null
        ? '${bestArmor!.minStat}-${bestArmor!.maxStat} DR'
        : '2-4 DR';
    final armImg = bestArmor?.imagePath ?? 'assets/images/items/vest.png';

    return Container(
      decoration: BoxDecoration(
        color: PixelTheme.roomCleared,
        border: Border.all(color: PixelTheme.neonGreen, width: 2),
      ),
      child: Stack(
        children: [
          const RoomBackgroundView(
            roomType: RoomType.entrance,
            isActive: true,
            isCleared: false,
          ),
          // Header strip
          Positioned(
            top: 6,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                  child: Text(
                    'SCOUT $name — READY BAY',
                    style: PixelTheme.pixelStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.neonGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                  child: Text(
                    'MEDS: $medkitCount',
                    style: PixelTheme.pixelStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.elevatorCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scout standing on the bunker floor slab + Loadout Rack
          Positioned(
            bottom: 18,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 54,
                      color: PixelTheme.roomVoid,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: hpRatio,
                        child: Container(color: PixelTheme.neonGreen),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Image.asset(
                      'assets/images/hero.png',
                      height: 68,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shield, color: PixelTheme.neonGreen, size: 40),
                    ),
                    Container(
                      width: 34,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                      child: Text(
                        '$hp/$maxHp HP',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: PixelTheme.neonGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LoadoutSlotTile(
                        slot: 'WPN',
                        name: wpnName,
                        stat: wpnStat,
                        imagePath: wpnImg,
                        accent: PixelTheme.warningAmber,
                      ),
                      const SizedBox(height: 6),
                      _LoadoutSlotTile(
                        slot: 'ARM',
                        name: armName,
                        stat: armStat,
                        imagePath: armImg,
                        accent: PixelTheme.elevatorCyan,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadoutSlotTile extends StatelessWidget {
  final String slot;
  final String name;
  final String stat;
  final String imagePath;
  final Color accent;

  const _LoadoutSlotTile({
    required this.slot,
    required this.name,
    required this.stat,
    required this.imagePath,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: PixelTheme.roomVoid.withValues(alpha: 0.92),
        border: Border.all(color: PixelTheme.borderPixel, width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 24,
            height: 24,
            filterQuality: FilterQuality.none,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.build, color: accent, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$slot: $name',
                  style: PixelTheme.pixelStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: PixelTheme.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  stat,
                  style: PixelTheme.pixelStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
