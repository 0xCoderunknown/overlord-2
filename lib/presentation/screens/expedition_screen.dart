import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import '../../engine/building_generator.dart';
import '../../engine/exploration_controller.dart';
import '../widgets/building_cutaway_view.dart';
import '../widgets/pixel_hud.dart';
import '../widgets/room_stage_view.dart';

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
          'OVERLORD 2 // SECTOR RUN',
          style: PixelTheme.pixelStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: PixelTheme.neonGreen,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: PixelTheme.textLight),
            tooltip: 'Generate New Building',
            onPressed: _restart,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, color: PixelTheme.borderPixel),
        ),
      ),
      body: SafeArea(
        child: player.isDead
            ? _buildDefeatView()
            : Column(
                children: [
                  PixelHud(
                    player: player,
                    floorIndex: _controller.currentFloorIndex,
                    roomIndex: _controller.currentRoomIndex,
                    eventLog: _controller.lastEventLog,
                  ),
                  BuildingCutawayView(
                    building: _controller.building,
                    currentFloorIndex: _controller.currentFloorIndex,
                    currentRoomIndex: _controller.currentRoomIndex,
                    canMoveTo: _controller.canMoveTo,
                    onRoomTap: (f, r) => _controller.moveTo(f, r),
                  ),
                  Expanded(
                    child: RoomStageView(
                      room: _controller.currentRoom,
                      player: player,
                      combat: _controller.activeCombat,
                      onAttack: () => _controller.executeCombatRound(),
                      onUseMedkit: () => _controller.useMedkit(),
                      onClaimLoot: () => _controller.claimRoomLoot(),
                    ),
                  ),
                ],
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
              'Scout flatlined in Sector L${_controller.currentFloorIndex + 1}:R${_controller.currentRoomIndex + 1}.',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

