import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';
import 'hit_shake.dart';

class RoomEnemyView extends StatelessWidget {
  final Enemy enemy;
  final bool isShaking;
  final String? damagePopup;

  const RoomEnemyView({
    super.key,
    required this.enemy,
    required this.isShaking,
    this.damagePopup,
  });

  @override
  Widget build(BuildContext context) {
    final hpRatio = (enemy.currentHp / enemy.maxHp).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (enemy.isBoss) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            color: PixelTheme.alertRed,
            child: Text(
              '★ APEX BOSS ★',
              style: PixelTheme.pixelStyle(
                fontSize: 6,
                fontWeight: FontWeight.bold,
                color: PixelTheme.roomVoid,
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
        Container(
          height: 4,
          width: enemy.isBoss ? 70 : 50,
          color: PixelTheme.roomVoid,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: hpRatio,
            child: Container(color: PixelTheme.alertRed),
          ),
        ),
        const SizedBox(height: 2),
        HitShake(
          isHero: false,
          isShaking: isShaking,
          damagePopup: damagePopup,
          child: Transform.flip(
            flipX: true,
            child: Image.asset(
              'assets/images/enemy.png',
              height: enemy.isBoss ? 74 : 58,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (context, error, stackTrace) => Icon(
                enemy.isBoss ? Icons.smart_toy : Icons.pest_control,
                color: PixelTheme.alertRed,
                size: enemy.isBoss ? 42 : 34,
              ),
            ),
          ),
        ),
        // Ground shadow on walking rail
        Container(
          width: enemy.isBoss ? 44 : 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          color: PixelTheme.roomVoid.withValues(alpha: 0.9),
          child: Text(
            '${enemy.name.toUpperCase()} (${enemy.currentHp}HP)',
            style: PixelTheme.pixelStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: PixelTheme.alertRed,
            ),
          ),
        ),
      ],
    );
  }
}

