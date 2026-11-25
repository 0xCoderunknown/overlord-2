import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';
import '../../../domain/models.dart';
import '../../../engine/banter_engine.dart';
import '../../../engine/combat_engine.dart';
import 'in_room_combat_bar.dart';
import 'rickety_elevator_view.dart';
import 'room_background_view.dart';
import 'room_hero_view.dart';
import 'room_interior_content.dart';

class PixelRoomView extends StatelessWidget {
  final Room room;
  final bool isActive;
  final bool isMoveTarget;
  final ScoutCharacter player;
  final CombatEngine? combat;
  final bool isShakingHero;
  final bool isShakingEnemy;
  final String? heroDamagePopup;
  final String? enemyDamagePopup;
  final bool isScoutOnLeft;
  final bool isScoutFacingRight;
  final bool isEnemyAggroed;
  final bool isEnemyLyingOnGround;
  final bool isHeroLyingOnGround;
  final String? scrapBannerText;
  final String? eventLog;
  final BanterExchange? banter;
  final VoidCallback onTapRoom;
  final VoidCallback onHeal;
  final VoidCallback onSearchScrap;
  final VoidCallback? onTriggerEvent;
  final VoidCallback? onStealth;

  const PixelRoomView({
    super.key,
    required this.room,
    required this.isActive,
    required this.isMoveTarget,
    required this.player,
    required this.combat,
    this.isShakingHero = false,
    this.isShakingEnemy = false,
    this.heroDamagePopup,
    this.enemyDamagePopup,
    this.isScoutOnLeft = true,
    this.isScoutFacingRight = true,
    this.isEnemyAggroed = false,
    this.isEnemyLyingOnGround = false,
    this.isHeroLyingOnGround = false,
    this.scrapBannerText,
    this.eventLog,
    this.banter,
    required this.onTapRoom,
    required this.onHeal,
    required this.onSearchScrap,
    this.onTriggerEvent,
    this.onStealth,
  });

  double get roomWidth => room.isElevator ? 100 : 290;

  @override
  Widget build(BuildContext context) {
    if (room.isElevator && room.state != RoomState.unrevealed) {
      return GestureDetector(
        onTap: isMoveTarget ? onTapRoom : null,
        child: RicketyElevatorView(
          room: room,
          isActive: isActive,
          isMoveTarget: isMoveTarget,
          player: player,
          eventLog: isActive ? eventLog : null,
        ),
      );
    }

    if (room.state == RoomState.unrevealed) {
      return _buildUnrevealedRoom();
    }
    if (room.state == RoomState.outline) {
      return _buildOutlineRoom();
    }
    return _buildRevealedRoom();
  }

  Widget _buildUnrevealedRoom() {
    return Container(
      width: roomWidth,
      height: 190,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PixelTheme.roomVoid,
        border: Border.all(color: PixelTheme.borderPixel, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              room.isElevator ? Icons.swap_vert : Icons.lock,
              color: PixelTheme.borderPixel,
              size: room.isElevator ? 20 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              room.isElevator ? 'SHAFT' : 'UNEXPLORED',
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                color: PixelTheme.borderPixel,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineRoom() {
    final title = room.isElevator
        ? 'ELEVATOR'
        : (room.type == RoomType.bossChamber ? 'WARNING: APEX' : 'SECTOR');
    final titleColor = room.type == RoomType.bossChamber
        ? PixelTheme.alertRed
        : (isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted);

    return GestureDetector(
      onTap: isMoveTarget ? onTapRoom : null,
      child: Container(
        width: roomWidth,
        height: 190,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: PixelTheme.roomUnrevealed,
          border: Border.all(
            color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.roomDiscoveredBorder,
            width: isMoveTarget ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                room.isElevator ? Icons.swap_vert : Icons.meeting_room,
                color: isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(title, style: PixelTheme.pixelStyle(fontSize: 9, fontWeight: FontWeight.bold, color: titleColor)),
              if (isMoveTarget) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: PixelTheme.neonGreen,
                  child: Text(
                    'ENTER',
                    style: PixelTheme.pixelStyle(fontSize: 8, fontWeight: FontWeight.bold, color: PixelTheme.roomVoid),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevealedRoom() {
    final isBossChamber = room.type == RoomType.bossChamber;

    return GestureDetector(
      onTap: isMoveTarget ? onTapRoom : null,
      child: Container(
        width: roomWidth,
        height: 190,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: PixelTheme.roomCleared,
          border: Border.all(
            color: isActive
                ? (isBossChamber ? PixelTheme.alertRed : PixelTheme.neonGreen)
                : (isMoveTarget ? PixelTheme.neonGreen : PixelTheme.borderPixel),
            width: (isActive || isMoveTarget) ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Flat horizontal 2D cutaway room background
            RoomBackgroundView(
              roomType: room.type,
              isActive: isActive,
              isCleared: room.state == RoomState.cleared,
            ),

            // Room Header Banner
            Positioned(
              top: 4,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: PixelTheme.roomVoid.withValues(alpha: 0.85),
                    child: Text(
                      isBossChamber ? 'APEX BOSS CHAMBER' : room.type.name.toUpperCase(),
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isBossChamber
                            ? PixelTheme.alertRed
                            : (isActive || isMoveTarget ? PixelTheme.neonGreen : PixelTheme.textMuted),
                      ),
                    ),
                  ),
                  if (isMoveTarget && !isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      color: PixelTheme.neonGreen,
                      child: Text(
                        'RETURN',
                        style: PixelTheme.pixelStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: PixelTheme.roomVoid,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: PixelTheme.roomVoid.withValues(alpha: 0.85),
                    child: Text(
                      'F${room.floorIndex + 1}:R${room.roomIndex + 1}',
                      style: PixelTheme.pixelStyle(
                        fontSize: 8,
                        color: PixelTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Combatants grounded on flat floor slab (bottom: 18)
            Positioned(
              bottom: 18,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: isScoutOnLeft
                    ? [
                        if (isActive) _buildScoutInRoom() else const SizedBox(width: 48),
                        _buildRoomInteriorContent(enemyFacesLeft: true),
                      ]
                    : [
                        _buildRoomInteriorContent(enemyFacesLeft: false),
                        if (isActive) _buildScoutInRoom() else const SizedBox(width: 48),
                      ],
              ),
            ),

            // In-Room Emergency Heal / Combat Banter OR Exploration Message
            if (isActive && room.hasUnresolvedEnemy)
              Positioned(
                top: 24,
                left: 10,
                right: 10,
                child: InRoomCombatBar(
                  room: room,
                  player: player,
                  eventLog: eventLog,
                  banter: banter,
                  onHeal: onHeal,
                  onStealth: onStealth,
                ),
              )
            else if (isActive && eventLog != null && eventLog!.isNotEmpty)
              Positioned(
                top: 24,
                left: 10,
                right: 10,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                      border: Border.all(
                        color: PixelTheme.borderPixel,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      eventLog!,
                      style: PixelTheme.pixelStyle(
                        fontSize: 7,
                        color: PixelTheme.textLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoutInRoom() {
    return RoomHeroView(
      player: player,
      isShaking: isShakingHero,
      damagePopup: heroDamagePopup,
      facesRight: isScoutFacingRight,
      isLyingOnGround: isHeroLyingOnGround,
    );
  }

  Widget _buildRoomInteriorContent({bool enemyFacesLeft = true}) {
    return RoomInteriorContent(
      room: room,
      isActive: isActive,
      enemyFacesLeft: enemyFacesLeft,
      isShakingEnemy: isShakingEnemy,
      enemyDamagePopup: enemyDamagePopup,
      isEnemyAggroed: isEnemyAggroed,
      isEnemyLyingOnGround: isEnemyLyingOnGround,
      scrapBannerText: scrapBannerText,
      onSearchScrap: onSearchScrap,
      onTriggerEvent: onTriggerEvent,
    );
  }
}
