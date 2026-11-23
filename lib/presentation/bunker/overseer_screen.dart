import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../engine/bunker_manager.dart';
import '../screens/expedition_screen.dart';
import '../widgets/terminal/terminal_button.dart';
import '../widgets/terminal/terminal_container.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'VAULT COMMAND CENTER',
          style: AppTheme.retroText(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.green.withValues(alpha: 0.5), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overseer Status Banner
              TerminalContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        'assets/images/char/overseer.webp',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.none,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: AppTheme.terminalGreen, size: 48),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[ ID: VAULT OVERSEER ]',
                            style: AppTheme.retroText(
                              color: AppTheme.terminalGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Divider(color: AppTheme.green.withValues(alpha: 0.5), height: 1),
                          const SizedBox(height: 6),
                          Text(
                            'TREASURY : ${_bunker.caps} CAPS / GOLD',
                            style: AppTheme.retroText(
                              color: AppTheme.warningYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ARMORY   : ${_bunker.globalStash.length} SALVAGE ITEMS',
                            style: AppTheme.retroText(
                              color: AppTheme.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Primary Launch Button
              TerminalButton(
                text: '>> LAUNCH FACILITY EXPEDITION <<',
                borderColor: PixelTheme.neonGreen,
                textColor: PixelTheme.roomVoid,
                backgroundColor: PixelTheme.neonGreen,
                padding: 14,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpeditionScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // 3. Vault Decks Navigation Grid
              Row(
                children: [
                  Expanded(
                    child: TerminalButton(
                      text: 'REQUISITION',
                      borderColor: AppTheme.green,
                      textColor: AppTheme.terminalGreen,
                      padding: 12,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MarketScreen(bunkerManager: _bunker)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TerminalButton(
                      text: 'ARMORY STASH',
                      borderColor: AppTheme.green,
                      textColor: AppTheme.terminalGreen,
                      padding: 12,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => StashScreen(bunkerManager: _bunker)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TerminalButton(
                      text: 'MEDBAY',
                      borderColor: AppTheme.green,
                      textColor: AppTheme.terminalGreen,
                      padding: 12,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FacilityScreen(bunkerManager: _bunker)),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Infiltration Scout Dossier
              Text(
                '[ DEPLOYED INFILTRATOR ]',
                style: AppTheme.retroText(fontSize: 13, color: AppTheme.green),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TerminalContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: PixelTheme.roomVoid,
                        child: Image.asset(
                          'assets/images/hero.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SCOUT VANCE (TIER 1 INFILTRATOR)',
                              style: AppTheme.retroText(
                                fontSize: 13,
                                color: PixelTheme.neonGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'STATUS: READY FOR BREACH | VITALS: 100/100 HP',
                              style: AppTheme.retroText(
                                fontSize: 10,
                                color: AppTheme.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'EQUIPPED: PIPE PISTOL (6-12) & PHONEBOOK (2-4 DR)',
                              style: AppTheme.retroText(
                                fontSize: 9,
                                color: PixelTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

