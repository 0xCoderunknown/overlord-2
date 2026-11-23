import 'package:material_ui/material_ui.dart';

import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../engine/building_generator.dart';
import '../../engine/exploration_controller.dart';
import '../widgets/pixel_hud.dart';
import '../widgets/pixel_room_view.dart';
import '../widgets/scrap_loot_dialog.dart';

class ExpeditionScreen extends StatefulWidget {
  const ExpeditionScreen({super.key});

  @override
  State<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends State<ExpeditionScreen> {
  late ExplorationController _controller;

  @override
  void initState() {
    super.initState();
    _startNewExpedition();
  }

  void _startNewExpedition() {
    final generator = BuildingGenerator();
    final building = generator.generateBuilding(
      floorCount: 3,
      roomsPerFloor: 4,
      elevatorColumn: 3,
    );
    final player = ScoutCharacter(name: 'Vance');

    _controller = ExplorationController(
      building: building,
      player: player,
      buildingGenerator: generator,
    );
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _restart() {
    _controller.removeListener(_onControllerUpdate);
    setState(() {
      _startNewExpedition();
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = _controller.player;

    return Scaffold(
      backgroundColor: PixelTheme.background,
      appBar: AppBar(
        backgroundColor: PixelTheme.roomVoid,
        elevation: 0,
        title: Text(
          'OVERLORD 2 // FACILITY INFILTRATION',
          style: PixelTheme.pixelStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: PixelTheme.neonGreen,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: PixelTheme.textLight),
            tooltip: 'Reset Facility',
            onPressed: _restart,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, color: PixelTheme.borderPixel),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            player.isDead
                ? _buildDefeatView()
                : Column(
                    children: [
                      PixelHud(
                        player: player,
                        floorIndex: _controller.currentFloorIndex,
                        roomIndex: _controller.currentRoomIndex,
                        eventLog: _controller.lastEventLog,
                      ),
                      Expanded(child: _buildBuildingViewport()),
                    ],
                  ),
            // Salvage Loot Popup
            if (_controller.pendingScrapItem != null)
              ScrapLootDialog(
                item: _controller.pendingScrapItem!,
                player: player,
                onEquip: () => _controller.equipPendingItem(),
                onScrap: () => _controller.scrapPendingItem(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingViewport() {
    final reversedFloors = _controller.building.floors.reversed.toList();

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(40),
      minScale: 0.6,
      maxScale: 2.0,
      child: Container(
        color: PixelTheme.roomVoid,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reversedFloors.map((floor) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floor indicator column
                Container(
                  width: 44,
                  height: 190,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: PixelTheme.roomUnrevealed,
                    border: Border.all(color: PixelTheme.borderPixel),
                  ),
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'FLOOR ${floor.floorIndex + 1}',
                        style: PixelTheme.pixelStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              floor.floorIndex == _controller.currentFloorIndex
                              ? PixelTheme.neonGreen
                              : PixelTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                // Floor Rooms
                ...floor.rooms.map((room) {
                  final isActive =
                      room.floorIndex == _controller.currentFloorIndex &&
                      room.roomIndex == _controller.currentRoomIndex;
                  final isMoveTarget = _controller.canMoveTo(
                    room.floorIndex,
                    room.roomIndex,
                  );

                  return PixelRoomView(
                    room: room,
                    isActive: isActive,
                    isMoveTarget: isMoveTarget,
                    player: _controller.player,
                    combat: _controller.activeCombat,
                    isShakingHero: _controller.isShakingHero,
                    isShakingEnemy: _controller.isShakingEnemy,
                    heroDamagePopup: _controller.heroDamagePopup,
                    enemyDamagePopup: _controller.enemyDamagePopup,
                    isScoutOnLeft: _controller.isScoutOnLeft,
                    isScoutFacingRight: _controller.isScoutFacingRight,
                    isEnemyAggroed: _controller.isEnemyAggroed,
                    combatBannerText: _controller.combatBannerText,
                    onTapRoom: () =>
                        _controller.moveTo(room.floorIndex, room.roomIndex),
                    onAttack: () => _controller.executeCombatRound(),
                    onHeal: () => _controller.useMedkit(),
                    onSearchScrap: () => _controller.searchScrapPile(),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDefeatView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.alertRed,
          borderWidth: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber,
              color: PixelTheme.alertRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'EXPEDITION TERMINATED',
              style: PixelTheme.pixelStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PixelTheme.alertRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scout flatlined in Sector F${_controller.currentFloorIndex + 1}:R${_controller.currentRoomIndex + 1}.',
              style: PixelTheme.pixelStyle(
                fontSize: 11,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.alertRed,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: _restart,
              child: Text(
                'DEPLOY NEW SQUAD',
                style: PixelTheme.pixelStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
