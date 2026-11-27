import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/bunker_manager.dart';
import '../widgets/terminal/terminal_container.dart';

class CharactersScreen extends StatelessWidget {
  final BunkerManager bunkerManager;

  const CharactersScreen({super.key, required this.bunkerManager});

  void _showCharacterDetail(BuildContext context, ScoutStarter starter) {
    final unlocked = bunkerManager.isStarterUnlocked(starter);
    final challenge = starter.unlockChallengeId == null
        ? null
        : GameDatabase.challenges.firstWhere(
            (c) => c.id == starter.unlockChallengeId,
          );
    final progress = challenge != null
        ? bunkerManager.getChallengeProgress(challenge)
        : 0;

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: AppTheme.transparent,
          child: TerminalContainer(
            width: 340,
            padding: const EdgeInsets.all(18),
            borderColor: unlocked ? PixelTheme.neonGreen : PixelTheme.alertRed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppTheme.bgBlack,
                        border: Border.all(
                          color: unlocked
                              ? PixelTheme.neonGreen
                              : PixelTheme.borderPixel,
                        ),
                      ),
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            starter.name.toUpperCase(),
                            style: AppTheme.retroText(
                              color: unlocked
                                  ? PixelTheme.neonGreen
                                  : PixelTheme.alertRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${starter.title.toUpperCase()} • ${starter.maxHp} HP',
                            style: AppTheme.retroText(
                              color: PixelTheme.elevatorCyan,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  starter.bio,
                  style: AppTheme.retroText(
                    color: AppTheme.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: AppTheme.bgBlack,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STARTER WPN: ${starter.weapon.name} (${starter.weapon.statDescription})',
                        style: AppTheme.retroText(
                          color: PixelTheme.chestGold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'STARTER ARM: ${starter.armor.name} (${starter.armor.statDescription})',
                        style: AppTheme.retroText(
                          color: PixelTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!unlocked && challenge != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'LOCKED: ${challenge.description} ($progress/${challenge.targetCount})',
                    style: AppTheme.retroText(
                      color: PixelTheme.warningAmber,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 14),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    '[ CLOSE ]',
                    style: AppTheme.retroText(
                      color: AppTheme.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.green),
        title: Text(
          'CHARACTER SELECTION',
          style: AppTheme.retroText(
            color: PixelTheme.neonGreen,
            letterSpacing: 2,
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
      body: GridView.builder(
        padding: const EdgeInsets.all(14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: GameDatabase.starters.length,
        itemBuilder: (context, index) {
          final starter = GameDatabase.starters[index];
          final unlocked = bunkerManager.isStarterUnlocked(starter);
          final borderColor =
              unlocked ? PixelTheme.textMuted : PixelTheme.borderPixel;

          return InkWell(
            onTap: () => _showCharacterDetail(context, starter),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgBlack,
                border: Border.all(color: borderColor, width: 1.5),
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
                      vertical: 5,
                      horizontal: 4,
                    ),
                    color: PixelTheme.roomUnrevealed,
                    child: Text(
                      unlocked ? starter.name : '${starter.name} 🔒',
                      style: AppTheme.retroText(
                        fontSize: 10,
                        color: unlocked ? AppTheme.white : AppTheme.grey,
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
    );
  }
}
