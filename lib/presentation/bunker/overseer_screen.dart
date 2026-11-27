import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../data/banter_database.dart';
import '../../data/game_database.dart';
import '../../engine/bunker_manager.dart';
import 'characters_screen.dart';
import 'challenges_screen.dart';
import 'facility_screen.dart';
import 'mission_screen.dart';
import 'weapons_screen.dart';
import 'widgets/overseer_widgets.dart';

class OverseerScreen extends StatefulWidget {
  final BunkerManager? bunkerManager;

  const OverseerScreen({super.key, this.bunkerManager});

  @override
  State<OverseerScreen> createState() => _OverseerScreenState();
}

class _OverseerScreenState extends State<OverseerScreen> {
  late BunkerManager _bunker;

  @override
  void initState() {
    super.initState();
    _bunker = widget.bunkerManager ?? BunkerManager();
    _bunker.addListener(_onUpdate);
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    if (widget.bunkerManager == null) {
      _bunker.removeListener(_onUpdate);
    }
    super.dispose();
  }

  String get _medbayBadge {
    if (_bunker.occupiedMedbayBeds > 0) {
      return '${_bunker.occupiedMedbayBeds}/${BunkerManager.maxMedbayBeds} BEDS';
    }
    if (_bunker.medbay.outputReady) return 'CLAIM READY';
    if (_bunker.medbay.isCrafting) return 'BREWING';
    return '0/${BunkerManager.maxMedbayBeds} BEDS';
  }

  Color get _medbayColor {
    if (_bunker.occupiedMedbayBeds > 0) return PixelTheme.warningAmber;
    if (_bunker.medbay.outputReady) return PixelTheme.neonGreen;
    if (_bunker.medbay.isCrafting) return PixelTheme.warningAmber;
    return PixelTheme.elevatorCyan;
  }

  @override
  Widget build(BuildContext context) {
    final quips = BanterDatabase.overseerQuips;
    final paMessage = _bunker.lastDebrief ??
        quips[_bunker.expeditionCount % quips.length];

    return Scaffold(
      backgroundColor: PixelTheme.background,
      appBar: const BunkerAppBar(title: 'VAULT COMMAND CENTER'),
      body: SafeArea(
        left: false,
        right: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth >= 600;
            final overseerCard = _buildOverseerCard(
              paMessage,
              expand: isLandscape,
            );
            final questButton = _buildQuestBoardButton(context);
            final deckGrid = _buildDeckGrid(context, expandRows: isLandscape);

            if (isLandscape) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: overseerCard),
                          const SizedBox(height: 8),
                          questButton,
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(flex: 5, child: deckGrid),
                  ],
                ),
              );
            }

            final minBodyHeight = (constraints.maxHeight - 28).clamp(
              0.0,
              double.infinity,
            );
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minBodyHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    overseerCard,
                    const SizedBox(height: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        deckGrid,
                        const SizedBox(height: 14),
                        questButton,
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverseerCard(String paMessage, {bool expand = false}) {
    final paBox = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: PixelTheme.roomUnrevealed,
      alignment: Alignment.centerLeft,
      child: Text(
        paMessage,
        style: PixelTheme.pixelStyle(
          fontSize: 11,
          color: _bunker.lastDebrief != null
              ? PixelTheme.warningAmber
              : PixelTheme.textLight,
        ),
        maxLines: expand ? 4 : 2,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: PixelTheme.pixelBox(
        background: PixelTheme.roomVoid,
        borderColor: PixelTheme.borderPixel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: PixelTheme.neonGreen,
                    width: 1.5,
                  ),
                ),
                child: Image.asset(
                  'assets/images/char/overseer.webp',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    color: PixelTheme.neonGreen,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VAULT 42 // OVERSEER',
                      style: PixelTheme.pixelStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: PixelTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    OverseerStatBadge(
                      label: 'CAPS',
                      value: '${_bunker.caps}',
                      color: PixelTheme.chestGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (expand) Expanded(child: paBox) else paBox,
        ],
      ),
    );
  }

  Widget _buildDeckGrid(BuildContext context, {bool expandRows = false}) {
    final row1 = Row(
      crossAxisAlignment:
          expandRows ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OverseerDeckTile(
            title: 'CHARACTERS',
            subtitle: 'ROSTER & BIOS',
            icon: Icons.groups,
            accent: PixelTheme.neonGreen,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharactersScreen(bunkerManager: _bunker),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OverseerDeckTile(
            title: 'WEAPONS',
            subtitle: 'ARMORY CODEX',
            icon: Icons.gavel,
            accent: PixelTheme.chestGold,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WeaponsScreen(bunkerManager: _bunker),
              ),
            ),
          ),
        ),
      ],
    );
    final row2 = Row(
      crossAxisAlignment:
          expandRows ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: OverseerDeckTile(
            title: 'CHALLENGES',
            subtitle:
                '${GameDatabase.challenges.where(_bunker.isChallengeCompleted).length}/${GameDatabase.challenges.length} UNLOCKED',
            icon: Icons.emoji_events,
            accent: PixelTheme.elevatorCyan,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChallengesScreen(bunkerManager: _bunker),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OverseerDeckTile(
            title: 'MEDBAY',
            subtitle: _medbayBadge,
            icon: Icons.local_hospital,
            accent: _medbayColor,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FacilityScreen(bunkerManager: _bunker),
              ),
            ),
          ),
        ),
      ],
    );

    if (expandRows) {
      return Column(
        children: [
          Expanded(child: row1),
          const SizedBox(height: 8),
          Expanded(child: row2),
        ],
      );
    }

    return Column(
      children: [
        row1,
        const SizedBox(height: 8),
        row2,
      ],
    );
  }

  Widget _buildQuestBoardButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MissionScreen(bunkerManager: _bunker),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.neonGreen.withValues(alpha: 0.14),
          borderColor: PixelTheme.neonGreen,
          borderWidth: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '>> QUEST BOARD <<',
              style: PixelTheme.pixelStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: PixelTheme.neonGreen,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${GameDatabase.contracts.length} LOCATIONS • ${GameDatabase.starters.where((s) => _bunker.isStarterUnlocked(s) && _bunker.statsFor(s.id).isAvailable).length} SCOUTS READY',
              style: PixelTheme.pixelStyle(
                fontSize: 10,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
