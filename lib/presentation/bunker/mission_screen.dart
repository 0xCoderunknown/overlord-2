import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/bunker_manager.dart';
import '../screens/expedition_screen.dart';
import '../widgets/terminal/terminal_button.dart';

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
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.green),
        leading: isStep2 && widget.initialContract == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.green),
                onPressed: () => setState(() => _selectedContract = null),
              )
            : null,
        title: Text(
          isStep2 ? 'SELECT SCOUT TO DEPLOY' : 'SELECT MISSION',
          style: AppTheme.retroText(
            color: PixelTheme.neonGreen,
            fontSize: 15,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.4),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: isStep2 ? _buildCharacterStep() : _buildContractStep(),
      ),
    );
  }

  Widget _buildContractStep() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: GameDatabase.contracts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final contract = GameDatabase.contracts[idx];
        final color = _hazardColor(contract.hazardLevel);

        return InkWell(
          onTap: () => setState(() => _selectedContract = contract),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgBlack,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.title,
                        style: AppTheme.retroText(
                          color: color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contract.subtitle,
                        style: AppTheme.retroText(
                          color: AppTheme.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterStep() {
    final bunker = widget.bunkerManager;
    final contract = _selectedContract!;
    final selected = bunker.selectedStarter;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: GameDatabase.starters.length,
              itemBuilder: (context, idx) {
                final starter = GameDatabase.starters[idx];
                final unlocked = bunker.isStarterUnlocked(starter);
                final isSelected = bunker.selectedStarterId == starter.id;
                final borderColor = !unlocked
                    ? PixelTheme.borderPixel
                    : (isSelected ? PixelTheme.neonGreen : PixelTheme.textMuted);

                return InkWell(
                  onTap: unlocked
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
                              colorFilter: unlocked
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
                            unlocked ? starter.name : '${starter.name} 🔒',
                            style: AppTheme.retroText(
                              fontSize: 10,
                              color: isSelected
                                  ? PixelTheme.neonGreen
                                  : (unlocked ? AppTheme.white : AppTheme.grey),
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
            child: Text(
              '${selected.name.toUpperCase()} (${selected.maxHp} HP) • ${selected.weapon.name} & ${selected.armor.name}',
              style: AppTheme.retroText(
                color: PixelTheme.textLight,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          TerminalButton(
            text: '>> DEPLOY ${selected.name.toUpperCase()} <<',
            borderColor: PixelTheme.neonGreen,
            textColor: PixelTheme.roomVoid,
            backgroundColor: PixelTheme.neonGreen,
            padding: 14,
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
