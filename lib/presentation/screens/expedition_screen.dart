import 'package:material_ui/material_ui.dart';

import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/building_generator.dart';
import '../../engine/bunker_manager.dart';
import '../../engine/combat_engine.dart';
import '../../engine/exploration_controller.dart';
import '../widgets/backpack_sheet.dart';
import '../widgets/expedition_bottom_bar.dart';
import '../widgets/expedition_defeat_view.dart';
import '../widgets/pixel_hud.dart';
import '../widgets/room/pixel_room_view.dart';
import '../widgets/terminal/event_modal.dart';

class ExpeditionScreen extends StatefulWidget {
  final BunkerManager? bunkerManager;
  final ExpeditionContract? contract;

  const ExpeditionScreen({super.key, this.bunkerManager, this.contract});

  @override
  State<ExpeditionScreen> createState() => _ExpeditionScreenState();
}

class _ExpeditionScreenState extends State<ExpeditionScreen>
    with SingleTickerProviderStateMixin {
  late ExplorationController _controller;
  final TransformationController _transformController =
      TransformationController();
  late final AnimationController _cameraAnimController;
  Animation<Matrix4>? _cameraAnimation;
  Size _viewportSize = Size.zero;
  int? _lastCamFloor;
  int? _lastCamRoom;

  @override
  void initState() {
    super.initState();
    _cameraAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (_cameraAnimation != null) {
          _transformController.value = _cameraAnimation!.value;
        }
      });
    _startNewExpedition();
  }

  void _startNewExpedition() {
    final activeContract = widget.contract ?? GameDatabase.contracts[1];
    final generator = BuildingGenerator();
    final building = generator.generateBuilding(
      name: activeContract.title,
      floorCount: activeContract.floorCount,
      roomsPerFloor: activeContract.roomsPerFloor,
      elevatorColumn: activeContract.roomsPerFloor - 1,
      bountyMultiplier: activeContract.bountyMultiplier,
      unlockedIds: widget.bunkerManager?.unlockedIds ?? const {},
    );
    final player = widget.bunkerManager?.deployExpeditionScout() ??
        ScoutCharacter(name: 'Vance');

    _controller = ExplorationController(
      building: building,
      player: player,
      buildingGenerator: generator,
    );
    _controller.addListener(_onControllerUpdate);
    _lastCamFloor = null;
    _lastCamRoom = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _centerCameraOnActiveRoom(animate: false);
    });
  }

  void _extractToBunker() {
    final player = _controller.player;
    widget.bunkerManager?.completeExpedition(
      goldEarned: player.gold,
      lootedItems: player.backpack,
      unusedMedkits: player.medkits,
      survived: true,
      kills: _controller.sessionKills,
      ratKills: _controller.sessionRatsKilled,
      bossKills: _controller.sessionBossesKilled,
    );
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _restart();
    }
  }

  void _onControllerUpdate() {
    setState(() {});
    if (_lastCamFloor != _controller.currentFloorIndex ||
        _lastCamRoom != _controller.currentRoomIndex) {
      _centerCameraOnActiveRoom(animate: true);
    }
  }

  void _centerCameraOnActiveRoom({bool animate = true}) {
    if (_viewportSize == Size.zero) return;
    final floors = _controller.building.floors;
    final f = _controller.currentFloorIndex;
    final r = _controller.currentRoomIndex;
    if (f < 0 || f >= floors.length) return;
    final rooms = floors[f].rooms;
    if (r < 0 || r >= rooms.length) return;

    _lastCamFloor = f;
    _lastCamRoom = r;

    double roomX = 16.0 + 52.0;
    for (int i = 0; i < r; i++) {
      roomX += rooms[i].isElevator ? 108.0 : 298.0;
    }
    final activeW = rooms[r].isElevator ? 108.0 : 298.0;
    final targetX = roomX + activeW / 2;

    final visualRow = (floors.length - 1) - f;
    final targetY = 16.0 + visualRow * 198.0 + 99.0;

    final scale = _transformController.value.getMaxScaleOnAxis().clamp(0.6, 2.0);
    final tx = _viewportSize.width / 2 - targetX * scale;
    final ty = _viewportSize.height / 2 - targetY * scale;

    final targetMatrix = Matrix4.diagonal3Values(scale, scale, 1.0)
      ..setTranslationRaw(tx, ty, 0.0);

    if (!animate) {
      _cameraAnimController.stop();
      _transformController.value = targetMatrix;
      return;
    }

    _cameraAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _cameraAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _cameraAnimController.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _cameraAnimController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _openBackpack() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BackpackSheet(
        player: _controller.player,
        onUseOrEquip: (idx) => _controller.equipFromBackpack(idx),
        onAutoEquip: () => _controller.autoEquipBest(),
        inCombat: _controller.activeCombat?.status == CombatStatus.inProgress,
      ),
    );
  }

  void _openRoomEventModal() {
    final room = _controller.currentRoom;
    if (!room.hasUnresolvedEvent) return;

    if (room.eventType == RoomEventType.medCabinet) {
      showDialog(
        context: context,
        builder: (ctx) => EventModal(
          title: 'MEDICAL CABINET',
          message: 'An intact pre-war trauma cabinet hangs on the wall.',
          confirmText: 'SCAVENGE CABINET',
          cancelText: 'LEAVE',
          accentColor: PixelTheme.elevatorCyan,
          onConfirm: () {
            Navigator.of(ctx).pop();
            _controller.resolveRoomEvent();
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      );
    } else if (room.eventType == RoomEventType.lockedSafe) {
      final hasKey = _controller.player.keys > 0;
      showDialog(
        context: context,
        builder: (ctx) => EventModal(
          title: 'SEALED FLOOR SAFE',
          message: hasKey
              ? 'Heavy steel safe. Use 1 Master Key for guaranteed Tier 2-3 salvage, or force it open at your own risk.'
              : 'Heavy steel safe. No Master Keys left—you can try forcing the latch open (50% trap risk).',
          confirmText: hasKey
              ? 'USE MASTER KEY (${_controller.player.keys})'
              : 'FORCE LOCK (RISKY)',
          cancelText: hasKey ? 'FORCE LOCK (RISKY)' : 'LEAVE',
          accentColor: PixelTheme.warningAmber,
          onConfirm: () {
            Navigator.of(ctx).pop();
            _controller.resolveRoomEvent(useKey: hasKey);
          },
          onCancel: () {
            Navigator.of(ctx).pop();
            if (hasKey) {
              _controller.resolveRoomEvent(useKey: false);
            }
          },
        ),
      );
    }
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
            (player.isDead && _controller.isDefeatScreenVisible)
                ? _buildDefeatView()
                : Column(
                    children: [
                      PixelHud(
                        player: player,
                        floorIndex: _controller.currentFloorIndex,
                        roomIndex: _controller.currentRoomIndex,
                      ),
                      Expanded(child: _buildBuildingViewport()),
                      ExpeditionBottomBar(
                        player: player,
                        canExtract: _controller.canExtract,
                        onTapBackpack: _openBackpack,
                        onTapMedkit: () => _controller.useMedkit(),
                        onTapExtract: _extractToBunker,
                      ),
                    ],
                  ),
            if (_controller.isBossIntroActive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: PixelTheme.alertRed, width: 4),
                      color: PixelTheme.alertRed.withValues(alpha: 0.12),
                    ),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      color: PixelTheme.alertRed,
                      child: Text(
                        '⚠ APEX THREAT DETECTED ⚠',
                        style: PixelTheme.pixelStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: PixelTheme.roomVoid,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingViewport() {
    final reversedFloors = _controller.building.floors.reversed.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_viewportSize != newSize) {
          _viewportSize = newSize;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _lastCamFloor == null) {
              _centerCameraOnActiveRoom(animate: false);
            }
          });
        }

        return InteractiveViewer(
          transformationController: _transformController,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(220),
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
                    isEnemyLyingOnGround: _controller.isEnemyLyingOnGround,
                    isHeroLyingOnGround: _controller.isHeroLyingOnGround,
                    scrapBannerText: isActive ? _controller.scrapBannerText : null,
                    eventLog: isActive ? _controller.lastEventLog : null,
                    banter: isActive ? _controller.activeBanter : null,
                    isHeroReplyingToBanter:
                        isActive && _controller.isHeroReplyingToBanter,
                    onTapRoom: () =>
                        _controller.moveTo(room.floorIndex, room.roomIndex),
                    onHeal: () => _controller.useMedkit(),
                    onSearchScrap: () => _controller.searchScrapPile(),
                    onTriggerEvent: _openRoomEventModal,
                    onStealth: () => _controller.useStealthboy(),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
      },
    );
  }

  Widget _buildDefeatView() {
    return ExpeditionDefeatView(
      floorIndex: _controller.currentFloorIndex,
      roomIndex: _controller.currentRoomIndex,
      hasBunker: widget.bunkerManager != null,
      onConfirm: () {
        if (widget.bunkerManager != null && Navigator.of(context).canPop()) {
          widget.bunkerManager!.completeExpedition(
            goldEarned: 0,
            lootedItems: const [],
            unusedMedkits: 0,
            survived: false,
            kills: _controller.sessionKills,
            ratKills: _controller.sessionRatsKilled,
            bossKills: _controller.sessionBossesKilled,
          );
          Navigator.of(context).pop();
        } else {
          _restart();
        }
      },
    );
  }
}
