import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';

/// Non-interactive Fallout-style CRT scanline and phosphor vignette overlay.
class CrtOverlay extends StatelessWidget {
  final Widget child;

  const CrtOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: PixelTheme.neonGreen.withValues(alpha: 0.14),
                    width: 1.5,
                  ),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.95,
                    colors: [
                      PixelTheme.neonGreen.withValues(alpha: 0.02),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.32),
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
                child: const CustomPaint(painter: _CrtScanlinePainter()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CrtScanlinePainter extends CustomPainter {
  const _CrtScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 3.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
