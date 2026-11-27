import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../domain/vault_models.dart';
import '../../engine/bunker_manager.dart';
import '../widgets/terminal/terminal_button.dart';
import '../widgets/terminal/terminal_container.dart';
import 'widgets/medbay_beds_panel.dart';
import 'widgets/overseer_widgets.dart';

class FacilityScreen extends StatefulWidget {
  final BunkerManager bunkerManager;

  const FacilityScreen({super.key, required this.bunkerManager});

  @override
  State<FacilityScreen> createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  @override
  void initState() {
    super.initState();
    widget.bunkerManager.addListener(_onUpdate);
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    widget.bunkerManager.removeListener(_onUpdate);
    super.dispose();
  }

  String _formatTime(int totalMinutes) {
    int h = totalMinutes ~/ 60;
    int m = totalMinutes % 60;
    return '${h}H ${m.toString().padLeft(2, '0')}M';
  }

  @override
  Widget build(BuildContext context) {
    final bunker = widget.bunkerManager;
    final medbay = bunker.medbay;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: const BunkerAppBar(title: 'MEDICAL BAY'),
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '[ ENGINEERING DECK // SECTION B-3 ]',
                style: AppTheme.retroText(
                  color: AppTheme.terminalGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              MedbayBedsPanel(bunker: bunker),
              const SizedBox(height: 14),
              TerminalContainer(
                borderColor: medbay.isUnlocked ? AppTheme.green : AppTheme.alertRed,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MEDKIT SYNTHESIZER',
                          style: AppTheme.retroText(
                            color: medbay.isUnlocked
                                ? AppTheme.terminalGreen
                                : AppTheme.alertRed,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medbay.isUnlocked ? '[ONLINE]' : '[OFFLINE]',
                          style: AppTheme.retroText(
                            color: medbay.isUnlocked
                                ? AppTheme.terminalGreen
                                : AppTheme.alertRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    medbay.isUnlocked
                        ? _buildUnlockedMedbay(bunker, medbay)
                        : _buildLockedMedbay(bunker),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedMedbay(BunkerManager bunker) {
    final canAfford = bunker.caps >= GameConfig.medbayUnlockCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, color: AppTheme.alertRed, size: 48),
        const SizedBox(height: 12),
        Text(
          'Pre-war Medkit Synthesizer is offline. Restore power to brew clean Trauma Medkits instead of gambling on scrap shots.',
          textAlign: TextAlign.center,
          style: AppTheme.retroText(color: AppTheme.grey, fontSize: 12),
        ),
        const SizedBox(height: 20),
        TerminalButton(
          text: canAfford
              ? '[ PAY ${GameConfig.medbayUnlockCost} CAPS TO RESTORE ]'
              : '[ REQUIRES ${GameConfig.medbayUnlockCost} CAPS ]',
          borderColor: canAfford ? AppTheme.warningYellow : AppTheme.grey,
          textColor: canAfford ? AppTheme.warningYellow : AppTheme.grey,
          padding: 14,
          onPressed: canAfford ? () => bunker.unlockMedbay() : null,
        ),
      ],
    );
  }

  Widget _buildUnlockedMedbay(BunkerManager bunker, VaultFacility medbay) {
    final syrCount = bunker.getStashItemCount('med_syringe');
    final herbCount = bunker.getStashItemCount('med_herb');
    final chemCount = bunker.getStashItemCount('chem_expired');
    final canCraft = bunker.canCraftMedbay();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'SYNTHESIS PROTOCOL: 2x WASTELAND MEDKIT',
          style: AppTheme.retroText(
            color: AppTheme.terminalGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildResourceRow('Used Syringe', syrCount, 1, syrCount >= 1),
        const SizedBox(height: 6),
        _buildResourceRow('Irradiated Herb', herbCount, 2, herbCount >= 2),
        const SizedBox(height: 6),
        _buildResourceRow('Expired Chemicals', chemCount, 1, chemCount >= 1),
        const SizedBox(height: 18),
        const Divider(color: AppTheme.green, height: 1, thickness: 1),
        const SizedBox(height: 16),
        if (medbay.outputReady) ...[
          TerminalButton(
            text: '[ EXTRACT 2x MEDKITS ]',
            borderColor: AppTheme.warningYellow,
            textColor: AppTheme.warningYellow,
            padding: 14,
            onPressed: () => bunker.claimMedbay(),
          ),
        ] else if (medbay.isCrafting) ...[
          Text(
            'SYNTHESIZING... ETA: ${_formatTime(medbay.minutesRemaining)}',
            textAlign: TextAlign.center,
            style: AppTheme.retroText(
              color: AppTheme.terminalGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (GameConfig.medbayCraftingTime - medbay.minutesRemaining) /
                GameConfig.medbayCraftingTime,
            backgroundColor: AppTheme.bgBlack,
            color: AppTheme.terminalGreen,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          TerminalButton(
            text: '[ OVERCLOCK SYNTHESIZER (FINISH) ]',
            borderColor: PixelTheme.elevatorCyan,
            textColor: PixelTheme.elevatorCyan,
            padding: 10,
            onPressed: () => bunker.completeMedbayCrafting(),
          ),
        ] else ...[
          TerminalButton(
            text: canCraft
                ? '[ INITIATE SYNTHESIS (4H) ]'
                : '[ INSUFFICIENT SALVAGE MATERIALS ]',
            borderColor: canCraft ? AppTheme.terminalGreen : AppTheme.grey,
            textColor: canCraft ? AppTheme.terminalGreen : AppTheme.grey,
            padding: 14,
            onPressed: canCraft ? () => bunker.startMedbayCrafting() : null,
          ),
          if (!canCraft) ...[
            const SizedBox(height: 8),
            TerminalButton(
              text: '+ REQUISITION CRAFTING SALVAGE',
              borderColor: AppTheme.blueAccent,
              textColor: AppTheme.blueAccent,
              padding: 8,
              onPressed: () => bunker.addCraftingMaterials(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildResourceRow(String name, int current, int required, bool isMet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '> $name',
          style: AppTheme.retroText(color: AppTheme.grey, fontSize: 13),
        ),
        Text(
          '[ $current / $required ]',
          style: AppTheme.retroText(
            color: isMet ? AppTheme.terminalGreen : AppTheme.alertRed,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

