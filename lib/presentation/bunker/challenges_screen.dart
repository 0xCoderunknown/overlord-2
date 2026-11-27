import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../../engine/bunker_manager.dart';
import 'widgets/overseer_widgets.dart';

class ChallengesScreen extends StatelessWidget {
  final BunkerManager bunkerManager;

  const ChallengesScreen({super.key, required this.bunkerManager});

  @override
  Widget build(BuildContext context) {
    final completedCount = GameDatabase.challenges
        .where(bunkerManager.isChallengeCompleted)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: const BunkerAppBar(title: 'CHALLENGES'),
      body: SafeArea(
        left: false,
        right: false,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: PixelTheme.pixelBox(
                background: PixelTheme.roomVoid,
                borderColor: PixelTheme.elevatorCyan,
                borderWidth: 1.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MILESTONES: $completedCount/${GameDatabase.challenges.length} UNLOCKED',
                    style: PixelTheme.pixelStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: PixelTheme.elevatorCyan,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'RUNS: ${bunkerManager.expeditionCount}  •  KILLS: ${bunkerManager.totalKills}  •  RATS: ${bunkerManager.ratsKilled}  •  BOSSES: ${bunkerManager.bossesKilled}',
                    style: PixelTheme.pixelStyle(
                      fontSize: 10.5,
                      color: PixelTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...GameDatabase.challenges.map(
              (challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChallengeCard(
                  challenge: challenge,
                  progress: bunkerManager.getChallengeProgress(challenge),
                  completed: bunkerManager.isChallengeCompleted(challenge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeDef challenge;
  final int progress;
  final bool completed;

  const _ChallengeCard({
    required this.challenge,
    required this.progress,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final accent = completed ? PixelTheme.neonGreen : PixelTheme.warningAmber;
    final clamped = progress.clamp(0, challenge.targetCount);
    final ratio = challenge.targetCount > 0
        ? clamped / challenge.targetCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: PixelTheme.pixelBox(
        background: PixelTheme.roomVoid,
        borderColor: accent,
        borderWidth: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed ? Icons.verified : Icons.emoji_events,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  challenge.title,
                  style: PixelTheme.pixelStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: PixelTheme.pixelBox(
                  background: accent.withValues(alpha: 0.14),
                  borderColor: accent,
                  borderWidth: 1,
                ),
                child: Text(
                  completed ? 'UNLOCKED' : '$clamped/${challenge.targetCount}',
                  style: PixelTheme.pixelStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description.toUpperCase(),
            style: PixelTheme.pixelStyle(
              fontSize: 11,
              color: PixelTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: PixelTheme.roomCleared,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          const SizedBox(height: 8),
          Text(
            'REWARD: ${challenge.rewardLabel.toUpperCase()}',
            style: PixelTheme.pixelStyle(
              fontSize: 10,
              color: PixelTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
