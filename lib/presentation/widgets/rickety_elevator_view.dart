import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class RicketyElevatorView extends StatelessWidget {
  final Room room;
  final bool isActive;
  final bool isMoveTarget;
  final ScoutCharacter player;

  const RicketyElevatorView({
    super.key,
    required this.room,
    required this.isActive,
    this.isMoveTarget = false,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 190,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0E14),
        border: Border.all(
          color: isActive
              ? PixelTheme.elevatorCyan
              : (isMoveTarget ? PixelTheme.neonGreen : PixelTheme.borderPixel),
          width: (isActive || isMoveTarget) ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Shaft interior: vertical guide rails, cables, and overhead pulley
          Positioned.fill(
            child: CustomPaint(
              painter: _RicketyShaftPainter(isActive: isActive),
            ),
          ),

          // Shaft top indicator header
          Positioned(
            top: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: PixelTheme.roomVoid.withValues(alpha: 0.85),
              child: Center(
                child: Text(
                  '▲ FL-${room.floorIndex + 1} ▼',
                  style: PixelTheme.pixelStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    color: isActive ? PixelTheme.elevatorCyan : PixelTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),

          // Rickety Elevator Cabin & Scout
          Positioned(
            bottom: 8,
            left: 6,
            right: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive) ...[
                  // Warm amber work light bulb
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PixelTheme.warningAmber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PixelTheme.warningAmber,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Scout inside the lift cage (facing into the facility rooms)
                  Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/hero.png',
                      height: 56,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shield, color: PixelTheme.neonGreen, size: 30),
                    ),
                  ),
                ] else ...[
                  // Empty lift gate / shaft floor sign or board prompt
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isMoveTarget
                            ? PixelTheme.neonGreen
                            : PixelTheme.borderPixel.withValues(alpha: 0.5),
                      ),
                      color: isMoveTarget
                          ? PixelTheme.roomVoid.withValues(alpha: 0.85)
                          : const Color(0xFF131720).withValues(alpha: 0.7),
                    ),
                    child: Center(
                      child: isMoveTarget
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: PixelTheme.neonGreen,
                              child: Text(
                                'BOARD',
                                style: PixelTheme.pixelStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: PixelTheme.roomVoid,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.fence,
                              color: PixelTheme.borderPixel.withValues(alpha: 0.6),
                              size: 20,
                            ),
                    ),
                  ),
                ],
                // Rusted lift platform / cage floor with hazard stripes
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2532),
                    border: Border.all(color: const Color(0xFF384358)),
                  ),
                  child: Center(
                    child: Text(
                      'LIFT CAR',
                      style: PixelTheme.pixelStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                        color: isActive ? PixelTheme.elevatorCyan : PixelTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RicketyShaftPainter extends CustomPainter {
  final bool isActive;

  _RicketyShaftPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    // Shaft background vertical corrugated iron lines
    final ribPaint = Paint()
      ..color = const Color(0xFF141924)
      ..strokeWidth = 2;
    for (double x = 14; x < size.width - 12; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), ribPaint);
    }

    // Heavy vertical steel guide rails on sides
    final railPaint = Paint()
      ..color = const Color(0xFF2E384D)
      ..strokeWidth = 3;
    canvas.drawLine(Offset(8, 0), Offset(8, size.height), railPaint);
    canvas.drawLine(Offset(size.width - 8, 0), Offset(size.width - 8, size.height), railPaint);

    // Overhead hoist pulley drum at top
    final pulleyPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(size.width * 0.5, 24), 10, pulleyPaint);

    final hubPaint = Paint()
      ..color = isActive ? PixelTheme.elevatorCyan : const Color(0xFF334155)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, 24), 3, hubPaint);

    // Twin steel hoist tension cables hanging from pulley
    final cablePaint = Paint()
      ..color = isActive ? const Color(0xFF00E5FF).withValues(alpha: 0.8) : const Color(0xFF4B5563)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(size.width * 0.44, 24), Offset(size.width * 0.44, size.height - 20), cablePaint);
    canvas.drawLine(Offset(size.width * 0.56, 24), Offset(size.width * 0.56, size.height - 20), cablePaint);

    // Horizontal shaft support cross-beams
    final beamPaint = Paint()
      ..color = const Color(0xFF1E2533)
      ..strokeWidth = 2;
    for (double y = 45; y < size.height - 25; y += 38) {
      canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), beamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

