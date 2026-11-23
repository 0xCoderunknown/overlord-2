import 'dart:math';
import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';

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
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void didUpdateWidget(covariant HitShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Horizontal shake oscillation: sin curve decaying over time
        final progress = _controller.value;
        final decay = 1.0 - progress;
        final shakeOffset = sin(progress * pi * 8) * 6.0 * decay;

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: progress > 0 && progress < 0.4
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        widget.isHero
                            ? PixelTheme.alertRed.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.8),
                        BlendMode.srcATop,
                      ),
                      child: widget.child,
                    )
                  : widget.child,
            ),
            // Floating damage number popup
            if (widget.damagePopup != null && _controller.isAnimating)
              Positioned(
                top: -24 - (progress * 18),
                child: Opacity(
                  opacity: decay.clamp(0.0, 1.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: PixelTheme.roomVoid.withValues(alpha: 0.9),
                    child: Text(
                      widget.damagePopup!,
                      style: PixelTheme.pixelStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: widget.isHero ? PixelTheme.alertRed : PixelTheme.warningAmber,
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

