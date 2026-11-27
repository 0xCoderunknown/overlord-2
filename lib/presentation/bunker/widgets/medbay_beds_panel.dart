import 'package:material_ui/material_ui.dart';
import '../../../core/app_theme.dart';
import '../../../core/pixel_theme.dart';
import '../../../data/game_database.dart';
import '../../../domain/models.dart';
import '../../../engine/bunker_manager.dart';
import '../../widgets/terminal/terminal_button.dart';
import '../../widgets/terminal/terminal_container.dart';

class MedbayBedsPanel extends StatefulWidget {
  final BunkerManager bunker;

  const MedbayBedsPanel({super.key, required this.bunker});

  @override
  State<MedbayBedsPanel> createState() => _MedbayBedsPanelState();
}

class _MedbayBedsPanelState extends State<MedbayBedsPanel> {
  String? _lastShotNote;

  void _cookShot(String starterId, String scoutName) {
    final outcome = widget.bunker.cookMysteryInjection(starterId);
    if (outcome == null) return;
    setState(() {
      _lastShotNote = switch (outcome) {
        MysteryShotOutcome.heal =>
          '${scoutName.toUpperCase()} HEALED BY MYSTERY SHOT!',
        MysteryShotOutcome.poison =>
          '${scoutName.toUpperCase()} POISONED! (+2 RECOVERY RUNS)',
        MysteryShotOutcome.fatal =>
          '${scoutName.toUpperCase()} DIED ON THE TABLE! BURIAL CLOTH NEEDED.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final bunker = widget.bunker;
    final occupants = bunker.medbayOccupantIds;
    final medkitCount = bunker.getStashItemCount('c_medkit');
    final scrapCount = bunker.totalCookingMaterialsCount;
    final clothCount = bunker.getStashItemCount(GameDatabase.burialCloth.id);

    return TerminalContainer(
      borderColor: occupants.isNotEmpty
          ? PixelTheme.warningAmber
          : PixelTheme.borderPixel,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOVERY BEDS (${bunker.occupiedMedbayBeds}/${BunkerManager.maxMedbayBeds})',
                style: AppTheme.retroText(
                  color: occupants.isNotEmpty
                      ? PixelTheme.warningAmber
                      : PixelTheme.elevatorCyan,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'MEDS: $medkitCount • SCRAP: $scrapCount • CLOTH: $clothCount',
                style: AppTheme.retroText(
                  color: AppTheme.terminalGreen,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (_lastShotNote != null) ...[
            const SizedBox(height: 6),
            Text(
              _lastShotNote!,
              style: AppTheme.retroText(
                color: PixelTheme.warningAmber,
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (occupants.isEmpty)
            Text(
              'All 3 beds clear. Injured/sick scouts recover 1 run per expedition, or risk cooking scrap.',
              style: AppTheme.retroText(color: AppTheme.grey, fontSize: 11),
            )
          else
            ...occupants.map((id) {
              final starter = GameDatabase.starters.firstWhere(
                (s) => s.id == id,
                orElse: () => GameDatabase.starters.first,
              );
              final stats = bunker.statsFor(id);
              final isDead = stats.condition == ScoutCondition.dead;
              final canCure = !isDead && medkitCount > 0;
              final canCook = !isDead && scrapCount > 0;
              final canBury = isDead && clothCount > 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isDead
                            ? '${starter.name.toUpperCase()} — DEAD (BLOCKING BED)'
                            : '${starter.name.toUpperCase()} — ${stats.condition.name.toUpperCase()} (${stats.recoveryRunsLeft}R)',
                        style: AppTheme.retroText(
                          color: isDead
                              ? PixelTheme.alertRed
                              : PixelTheme.warningAmber,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (isDead)
                      TerminalButton(
                        text: '[ BURY (1 CLOTH) ]',
                        padding: 6,
                        borderColor:
                            canBury ? PixelTheme.elevatorCyan : AppTheme.grey,
                        textColor:
                            canBury ? PixelTheme.elevatorCyan : AppTheme.grey,
                        onPressed: canBury
                            ? () => bunker.buryScoutWithCloth(id)
                            : null,
                      )
                    else ...[
                      TerminalButton(
                        text: '[ COOK (1 SCRAP) ]',
                        padding: 6,
                        borderColor:
                            canCook ? PixelTheme.warningAmber : AppTheme.grey,
                        textColor:
                            canCook ? PixelTheme.warningAmber : AppTheme.grey,
                        onPressed: canCook
                            ? () => _cookShot(id, starter.name)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      TerminalButton(
                        text: '[ CURE (1 MED) ]',
                        padding: 6,
                        borderColor:
                            canCure ? AppTheme.terminalGreen : AppTheme.grey,
                        textColor:
                            canCure ? AppTheme.terminalGreen : AppTheme.grey,
                        onPressed: canCure
                            ? () => bunker.treatScoutInMedbay(id)
                            : null,
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
