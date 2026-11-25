import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';
import '../../../domain/models.dart';
import 'hit_shake.dart';

class RoomHeroView extends StatelessWidget {
  final ScoutCharacter player;
  final bool isShaking;
  final String? damagePopup;
  final bool facesRight;
  final bool isLyingOnGround;

  const RoomHeroView({
    super.key,
    required this.player,
    required this.isShaking,
    this.damagePopup,
    this.facesRight = true,
    this.isLyingOnGround = false,
  });

  @override
  Widget build(BuildContext context) {
    final hpRatio = (player.currentHp / player.maxHp).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Healthbar on top of the scout (matching enemy/boss healthbar design)
        if (!isLyingOnGround) ...[
          Container(
            height: 4,
            width: 50,
            color: PixelTheme.roomVoid,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: hpRatio,
              child: Container(
                color: hpRatio <= 0.25
                    ? PixelTheme.alertRed
                    : (hpRatio <= 0.5 ? PixelTheme.warningAmber : PixelTheme.neonGreen),
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
        AnimatedSlide(
          offset: Offset(0, isLyingOnGround ? 0.24 : 0.0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn,
          child: AnimatedRotation(
            // Rotate anticlockwise (-0.25) if facing right, clockwise (0.25) if facing left
            turns: isLyingOnGround ? (facesRight ? -0.25 : 0.25) : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
            child: HitShake(
              isHero: true,
              isShaking: isShaking,
              damagePopup: damagePopup,
              child: Transform.flip(
                flipX: !facesRight,
                child: Image.asset(
                  'assets/images/hero.png',
                  height: 62,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.shield, color: PixelTheme.neonGreen, size: 36),
                ),
              ),
            ),
          ),
        ),
        // Ground shadow on the walking rail
        Container(
          width: isLyingOnGround ? 54 : 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 1),
        if (!isLyingOnGround)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: PixelTheme.roomVoid.withValues(alpha: 0.9),
            child: Text(
              '${player.name.toUpperCase()} (${player.currentHp}HP)',
              style: PixelTheme.pixelStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: PixelTheme.neonGreen,
              ),
            ),
          ),
      ],
    );
  }
}
