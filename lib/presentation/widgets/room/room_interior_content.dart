import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';
import '../../../domain/models.dart';
import 'room_enemy_view.dart';

class RoomInteriorContent extends StatelessWidget {
  final Room room;
  final bool isActive;
  final bool enemyFacesLeft;
  final bool isShakingEnemy;
  final String? enemyDamagePopup;
  final bool isEnemyAggroed;
  final bool isEnemyLyingOnGround;
  final String? scrapBannerText;
  final VoidCallback onSearchScrap;
  final VoidCallback? onTriggerEvent;

  const RoomInteriorContent({
    super.key,
    required this.room,
    required this.isActive,
    required this.enemyFacesLeft,
    required this.isShakingEnemy,
    this.enemyDamagePopup,
    required this.isEnemyAggroed,
    required this.isEnemyLyingOnGround,
    this.scrapBannerText,
    required this.onSearchScrap,
    this.onTriggerEvent,
  });

  @override
  Widget build(BuildContext context) {
    if (room.scrapPile != null) {
      final scrap = room.scrapPile!;
      return GestureDetector(
        onTap: (isActive && !scrap.isSearched) ? onSearchScrap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive && scrapBannerText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: PixelTheme.roomVoid.withValues(alpha: 0.95),
                child: Text(
                  scrapBannerText!,
                  style: PixelTheme.pixelStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: PixelTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 2),
            ],
            Icon(
              Icons.hardware,
              color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
              size: 32,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: PixelTheme.roomVoid.withValues(alpha: 0.9),
              child: Text(
                scrap.isSearched ? 'CLEARED SCRAP' : 'TAP TO SEARCH',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: scrap.isSearched ? PixelTheme.borderPixel : PixelTheme.chestGold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (room.enemy != null) {
      return RoomEnemyView(
        enemy: room.enemy!,
        isShaking: isShakingEnemy,
        damagePopup: enemyDamagePopup,
        facesLeft: enemyFacesLeft,
        isAggroed: isEnemyAggroed,
        isLyingOnGround: isEnemyLyingOnGround,
      );
    }

    if (room.hasUnresolvedEvent) {
      final isSafe = room.eventType == RoomEventType.lockedSafe;
      final color = isSafe ? PixelTheme.warningAmber : PixelTheme.elevatorCyan;
      return GestureDetector(
        onTap: isActive ? onTriggerEvent : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSafe ? Icons.lock : Icons.medical_services,
              color: color,
              size: 30,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: PixelTheme.roomVoid.withValues(alpha: 0.9),
              child: Text(
                isSafe ? 'OPEN SAFE' : 'MED CABINET',
                style: PixelTheme.pixelStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(width: 48);
  }
}
