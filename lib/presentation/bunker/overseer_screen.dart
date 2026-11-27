import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../data/banter_database.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/bunker_manager.dart';
import 'characters_screen.dart';
import 'challenges_screen.dart';
import 'facility_screen.dart';
import 'mission_screen.dart';
import 'weapons_screen.dart';

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

  Color _contractColor(ExpeditionContract contract) {
    if (contract.hazardLevel >= 3) return PixelTheme.alertRed;
    if (contract.hazardLevel == 2) return PixelTheme.warningAmber;
    return PixelTheme.neonGreen;
  }

  String get _medbayBadge {
    if (_bunker.medbay.outputReady) return 'CLAIM READY';
    if (_bunker.medbay.isCrafting) return 'BREWING';
    return _bunker.medbay.isUnlocked ? 'ONLINE' : 'LOCKED (10K)';
  }

  Color get _medbayColor {
    if (_bunker.medbay.outputReady) return PixelTheme.neonGreen;
    if (_bunker.medbay.isCrafting) return PixelTheme.warningAmber;
    return _bunker.medbay.isUnlocked
        ? PixelTheme.elevatorCyan
        : PixelTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final quips = BanterDatabase.overseerQuips;
    final paMessage = _bunker.lastDebrief ??
        quips[_bunker.expeditionCount % quips.length];

    return Scaffold(
      backgroundColor: PixelTheme.background,
      appBar: AppBar(
        title: Text(
          'VAULT COMMAND CENTER',
          style: PixelTheme.pixelStyle(
            fontSize: 15,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: PixelTheme.neonGreen,
          ),
        ),
        backgroundColor: PixelTheme.roomVoid,
        elevation: 0,
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, color: PixelTheme.borderPixel),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                    // 1. Overseer Command Briefing Panel
                    Container(
                      padding: const EdgeInsets.all(12),
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
                                width: 92,
                                height: 92,
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    color: PixelTheme.neonGreen,
                                    size: 44,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VAULT 42 // OVERSEER',
                                      style: PixelTheme.pixelStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: PixelTheme.neonGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _StatBadge(
                                          label: 'CAPS',
                                          value: '${_bunker.caps}',
                                          color: PixelTheme.chestGold,
                                        ),
                                        _StatBadge(
                                          label: 'RUNS',
                                          value: '${_bunker.expeditionCount}',
                                          color: PixelTheme.elevatorCyan,
                                        ),
                                        _StatBadge(
                                          label: 'KILLS',
                                          value: '${_bunker.totalKills}',
                                          color: PixelTheme.alertRed,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'FILTERS: 64% • RADS: NOMINAL',
                                      style: PixelTheme.pixelStyle(
                                        fontSize: 10,
                                        color: PixelTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            color: PixelTheme.roomUnrevealed,
                            child: Text(
                              paMessage,
                              style: PixelTheme.pixelStyle(
                                fontSize: 11,
                                color: _bunker.lastDebrief != null
                                    ? PixelTheme.warningAmber
                                    : PixelTheme.textLight,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. Bottom-Anchored Command Deck & Direct Mission Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

              // 2. Codex & Vault Decks (2x2 Grid)
              Row(
                children: [
                  Expanded(
                    child: _DeckTile(
                      title: 'CHARACTERS',
                      subtitle: 'ROSTER & BIOS',
                      icon: Icons.groups,
                      accent: PixelTheme.neonGreen,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              CharactersScreen(bunkerManager: _bunker),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DeckTile(
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
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DeckTile(
                      title: 'CHALLENGES',
                      subtitle:
                          '${GameDatabase.challenges.where(_bunker.isChallengeCompleted).length}/${GameDatabase.challenges.length} UNLOCKED',
                      icon: Icons.emoji_events,
                      accent: PixelTheme.elevatorCyan,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ChallengesScreen(bunkerManager: _bunker),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DeckTile(
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
              ),
              const SizedBox(height: 14),

              // 3. Direct Mission Selector (Click Mission -> Select Scout -> Drop)
              Text(
                '[ SELECT MISSION TO DEPLOY ]',
                style: PixelTheme.pixelStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.neonGreen,
                ),
              ),
              const SizedBox(height: 8),
              ...GameDatabase.contracts.map((contract) {
                final color = _contractColor(contract);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MissionScreen(
                          bunkerManager: _bunker,
                          initialContract: contract,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: PixelTheme.pixelBox(
                        background: PixelTheme.roomVoid,
                        borderColor: color,
                        borderWidth: 1.5,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: PixelTheme.pixelBox(
                              background: color.withValues(alpha: 0.14),
                              borderColor: color,
                              borderWidth: 1,
                            ),
                            child: Text(
                              'T${contract.hazardLevel}',
                              style: PixelTheme.pixelStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contract.title,
                                  style: PixelTheme.pixelStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contract.subtitle.toUpperCase(),
                                  style: PixelTheme.pixelStyle(
                                    fontSize: 10.5,
                                    color: PixelTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.play_arrow, color: color, size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PixelTheme.roomUnrevealed,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$label: $value',
        style: PixelTheme.pixelStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _DeckTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.borderPixel,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              style: PixelTheme.pixelStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: PixelTheme.pixelStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: accent,
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
