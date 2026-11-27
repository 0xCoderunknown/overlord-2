import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/bunker_manager.dart';
import '../screens/expedition_screen.dart';
import '../widgets/terminal/terminal_button.dart';
import 'widgets/overseer_widgets.dart';

class MissionScreen extends StatefulWidget {
  final BunkerManager bunkerManager;
  final ExpeditionContract? initialContract;

  const MissionScreen({
    super.key,
    required this.bunkerManager,
    this.initialContract,
  });

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  ExpeditionContract? _selectedContract;

  @override
  void initState() {
    super.initState();
    _selectedContract = widget.initialContract;
  }

  Color _hazardColor(int level) {
    if (level >= 3) return AppTheme.alertRed;
    if (level == 2) return AppTheme.orangeAccent;
    return PixelTheme.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isStep2 = _selectedContract != null;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: BunkerAppBar(
        title: isStep2 ? 'SELECT SCOUT TO DEPLOY' : 'QUEST BOARD',
        leading: isStep2 && widget.initialContract == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.green),
                onPressed: () => setState(() => _selectedContract = null),
              )
            : null,
      ),
      body: SafeArea(
        left: false,
        right: false,
        child: isStep2 ? _buildCharacterStep() : _buildContractStep(),
      ),
    );
  }

  Widget _buildContractStep() {
    final isLandscape = MediaQuery.sizeOf(context).width >= 600;
    if (isLandscape) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.35,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: GameDatabase.contracts.length,
        itemBuilder: (context, idx) =>
            _buildContractCard(GameDatabase.contracts[idx]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: GameDatabase.contracts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, idx) =>
          _buildContractCard(GameDatabase.contracts[idx]),
    );
  }

  Widget _buildContractCard(ExpeditionContract contract) {
    final color = _hazardColor(contract.hazardLevel);

    return InkWell(
      onTap: () => setState(() => _selectedContract = contract),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                border: Border.all(color: color),
              ),
              child: Text(
                'T${contract.hazardLevel}',
                style: AppTheme.retroText(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    contract.title,
                    style: AppTheme.retroText(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contract.subtitle.toUpperCase(),
                    style: AppTheme.retroText(
                      color: AppTheme.grey,
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (contract.lootFocus.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'LOOT: ${contract.lootFocus}',
                      style: AppTheme.retroText(
                        color: PixelTheme.elevatorCyan,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterStep() {
    final bunker = widget.bunkerManager;
    final contract = _selectedContract!;
    final selected = bunker.selectedStarter;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: AppTheme.bgBlack,
            child: Text(
              'TARGET: ${contract.title} (${contract.floorCount} FLOORS)',
              style: AppTheme.retroText(
                color: _hazardColor(contract.hazardLevel),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.sizeOf(context).width >= 600 ? 5 : 3,
                childAspectRatio:
                    MediaQuery.sizeOf(context).width >= 600 ? 0.95 : 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: GameDatabase.starters.length,
              itemBuilder: (context, idx) {
                final starter = GameDatabase.starters[idx];
                final unlocked = bunker.isStarterUnlocked(starter);
                final stats = bunker.statsFor(starter.id);
                final available = unlocked && stats.isAvailable;
                final isSelected = bunker.selectedStarterId == starter.id;
                final borderColor = !available
                    ? PixelTheme.borderPixel
                    : (isSelected ? PixelTheme.neonGreen : PixelTheme.textMuted);

                return InkWell(
                  onTap: available
                      ? () => setState(() => bunker.selectStarter(starter.id))
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PixelTheme.neonGreen.withValues(alpha: 0.14)
                          : AppTheme.bgBlack,
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ColorFiltered(
                              colorFilter: available
                                  ? const ColorFilter.mode(
                                      Colors.transparent,
                                      BlendMode.dst,
                                    )
                                  : const ColorFilter.mode(
                                      Colors.black87,
                                      BlendMode.srcATop,
                                    ),
                              child: Image.asset(
                                starter.portraitAsset,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          color: PixelTheme.roomUnrevealed,
                          child: Text(
                            !unlocked
                                ? '${starter.name} 🔒'
                                : (!stats.isAvailable
                                      ? '${stats.condition.name.toUpperCase()} (${stats.recoveryRunsLeft}R)'
                                      : starter.name),
                            style: AppTheme.retroText(
                              fontSize: 9.5,
                              color: isSelected
                                  ? PixelTheme.neonGreen
                                  : (available
                                        ? AppTheme.white
                                        : PixelTheme.warningAmber),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            color: AppTheme.bgBlack,
            child: Column(
              children: [
                Text(
                  bunker.hasAnyAvailableScout
                      ? '${selected.name.toUpperCase()} (${selected.maxHp} HP) • ${selected.weapon.name} & ${selected.armor.name}'
                      : 'ALL SCOUTS DEAD/RECOVERING — VAULT INTERN (70 HP) READY',
                  style: AppTheme.retroText(
                    color: bunker.hasAnyAvailableScout
                        ? PixelTheme.textLight
                        : PixelTheme.warningAmber,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (bunker.hasAnyAvailableScout) ...[
                  const SizedBox(height: 4),
                  Text(
                    'LVL ${bunker.statsFor(selected.id).level} • ${bunker.statsFor(selected.id).runs} RUNS • ${bunker.statsFor(selected.id).kills} KILLS',
                    style: AppTheme.retroText(
                      color: PixelTheme.elevatorCyan,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          TerminalButton(
            text: bunker.hasAnyAvailableScout
                ? '>> DEPLOY ${selected.name.toUpperCase()} <<'
                : '>> DEPLOY VAULT INTERN <<',
            borderColor: PixelTheme.neonGreen,
            textColor: PixelTheme.roomVoid,
            backgroundColor: PixelTheme.neonGreen,
            padding: 12,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ExpeditionScreen(
                    bunkerManager: bunker,
                    contract: contract,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
