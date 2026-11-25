import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../data/banter_database.dart';
import '../../domain/vault_models.dart';
import '../../engine/bunker_manager.dart';
import '../screens/expedition_screen.dart';
import '../widgets/terminal/terminal_button.dart';
import 'bunker_ready_room.dart';
import 'contract_picker_dialog.dart';
import 'facility_screen.dart';
import 'market_screen.dart';
import 'stash_screen.dart';

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
    final scout = _bunker.roster.isNotEmpty ? _bunker.roster.first : null;

    return Scaffold(
      backgroundColor: PixelTheme.background,
      appBar: AppBar(
        title: Text(
          'VAULT COMMAND CENTER',
          style: PixelTheme.pixelStyle(
            fontSize: 13,
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overseer Command Header + Vault PA Strip
              Container(
                padding: const EdgeInsets.all(10),
                decoration: PixelTheme.pixelBox(
                  background: PixelTheme.roomVoid,
                  borderColor: PixelTheme.borderPixel,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border.all(color: PixelTheme.neonGreen),
                          ),
                          child: Image.asset(
                            'assets/images/char/overseer.webp',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              color: PixelTheme.neonGreen,
                              size: 36,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: PixelTheme.neonGreen,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _StatBadge(
                                    label: 'CAPS',
                                    value: '${_bunker.caps}',
                                    color: PixelTheme.chestGold,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatBadge(
                                    label: 'STASH',
                                    value:
                                        '${_bunker.globalStash.length}/${GameConfig.maxStashSize}',
                                    color: PixelTheme.elevatorCyan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: PixelTheme.roomUnrevealed,
                      child: Text(
                        '> $paMessage',
                        style: PixelTheme.pixelStyle(
                          fontSize: 8,
                          color: _bunker.lastDebrief != null
                              ? PixelTheme.warningAmber
                              : PixelTheme.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 2. Primary Launch Button
              TerminalButton(
                text: '>> LAUNCH FACILITY EXPEDITION <<',
                borderColor: PixelTheme.neonGreen,
                textColor: PixelTheme.roomVoid,
                backgroundColor: PixelTheme.neonGreen,
                padding: 13,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ContractPickerDialog(
                      onSelect: (contract) {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExpeditionScreen(
                              bunkerManager: _bunker,
                              contract: contract,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),

              // 3. Vault Decks with Live Status Badges
              Row(
                children: [
                  Expanded(
                    child: _DeckTile(
                      title: 'REQUISITION',
                      subtitle: 'BUY GEAR',
                      icon: Icons.storefront,
                      accent: PixelTheme.chestGold,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MarketScreen(bunkerManager: _bunker),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DeckTile(
                      title: 'ARMORY STASH',
                      subtitle:
                          '${_bunker.globalStash.length}/${GameConfig.maxStashSize} SLOTS',
                      icon: Icons.inventory_2,
                      accent: PixelTheme.elevatorCyan,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StashScreen(bunkerManager: _bunker),
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
              const SizedBox(height: 12),

              // 4. Living Ready Room (Cutaway Vault Bay)
              Expanded(
                child: BunkerReadyRoom(
                  scout: scout,
                  bestWeapon: _bunker.getBestStashWeapon(),
                  bestArmor: _bunker.getBestStashArmor(),
                  medkitCount: _bunker.getStashItemCount('c_medkit'),
                ),
              ),
            ],
          ),
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
          fontSize: 9,
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.borderPixel,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(height: 4),
            Text(
              title,
              style: PixelTheme.pixelStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: PixelTheme.neonGreen,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: PixelTheme.pixelStyle(
                fontSize: 7,
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
