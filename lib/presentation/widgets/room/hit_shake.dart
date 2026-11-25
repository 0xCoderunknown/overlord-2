import 'dart:math';
import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';

class HitShake extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final String? damagePopup;
  final bool isHero;

  const HitShake({
    super.key,
    required this.child,
    required this.isShaking,
    this.damagePopup,
    this.isHero = false,
  });

  @override
  State<HitShake> createState() => _HitShakeState();
}

class _HitShakeState extends State<HitShake> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
  }

  @override
  void didUpdateWidget(covariant HitShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    final startedShaking = widget.isShaking && !oldWidget.isShaking;
    final newPopup = widget.damagePopup != null && widget.damagePopup != oldWidget.damagePopup;
    if (startedShaking || newPopup) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHeal = widget.damagePopup?.startsWith('+') ?? false;
    final isBlocked = widget.damagePopup == 'BLOCKED';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        // Shake & hit flash occur in the first 40% (~340ms) so the unit reacts crisply
        final isShakingPhase = !isHeal && progress > 0 && progress < 0.4;
        final shakeProgress = (progress / 0.4).clamp(0.0, 1.0);
        final shakeDecay = 1.0 - shakeProgress;
        final shakeOffset = isShakingPhase ? sin(shakeProgress * pi * 8) * 6.0 * shakeDecay : 0.0;

        // Floating number stays solid for 60%, then fades cleanly over the last 40%
        final popupOpacity = progress < 0.6
            ? 1.0
            : (1.0 - (progress - 0.6) / 0.4).clamp(0.0, 1.0);

        final popupColor = isHeal
            ? PixelTheme.neonGreen
            : (isBlocked
                ? PixelTheme.elevatorCyan
                : (widget.isHero ? PixelTheme.alertRed : PixelTheme.warningAmber));

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: isShakingPhase && progress < 0.25
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        isBlocked
                            ? PixelTheme.elevatorCyan.withValues(alpha: 0.6)
                            : (widget.isHero
                                ? PixelTheme.alertRed.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.8)),
                        BlendMode.srcATop,
                      ),
                      child: widget.child,
                    )
                  : widget.child,
            ),
            // Floating damage / block / heal popup
            if (widget.damagePopup != null && _controller.isAnimating)
              Positioned(
                top: -18 - (progress * 30),
                child: Opacity(
                  opacity: popupOpacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                    child: Text(
                      widget.damagePopup!,
                      style: PixelTheme.pixelStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: popupColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

