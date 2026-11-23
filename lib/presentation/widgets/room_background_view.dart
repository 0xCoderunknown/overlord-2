import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';
import '../../domain/models.dart';

class RoomBackgroundView extends StatelessWidget {
  final RoomType roomType;
  final bool isActive;
  final bool isCleared;

  const RoomBackgroundView({
    super.key,
    required this.roomType,
    required this.isActive,
    required this.isCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CutawayRoomPainter(
          roomType: roomType,
          isActive: isActive,
          isCleared: isCleared,
        ),
      ),
    );
  }
}

class _CutawayRoomPainter extends CustomPainter {
  final RoomType roomType;
  final bool isActive;
  final bool isCleared;

  _CutawayRoomPainter({
    required this.roomType,
    required this.isActive,
    required this.isCleared,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isBossChamber = roomType == RoomType.bossChamber;

    // 1. Muted, low-contrast modular backwall
    final wallBaseColor = isBossChamber
        ? const Color(0xFF160F14)
        : (isActive ? const Color(0xFF121620) : const Color(0xFF0D1017));
    final wallPaint = Paint()..color = wallBaseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wallPaint);

    // 2. Subtle architectural wall panels (low contrast to keep foreground readable)
    final panelSeamPaint = Paint()
      ..color = isBossChamber
          ? const Color(0xFF2A151C)
          : (isActive ? const Color(0xFF1B2230) : const Color(0xFF141924))
      ..strokeWidth = 1.5;

    final panelWidth = size.width / 3;
    canvas.drawLine(Offset(panelWidth, 14), Offset(panelWidth, size.height - 18), panelSeamPaint);
    canvas.drawLine(Offset(panelWidth * 2, 14), Offset(panelWidth * 2, size.height - 18), panelSeamPaint);

    // Subtle horizontal mid-wall conduit line
    final conduitPaint = Paint()
      ..color = isBossChamber ? const Color(0xFF2E1922) : const Color(0xFF1E2636)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.45), conduitPaint);

    // Faint rivet marks along vertical seams
    final rivetPaint = Paint()
      ..color = const Color(0xFF283246).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    for (double y = 28; y < size.height - 24; y += 22) {
      canvas.drawCircle(Offset(panelWidth, y), 1.2, rivetPaint);
      canvas.drawCircle(Offset(panelWidth * 2, y), 1.2, rivetPaint);
    }

    // 3. Flat Horizontal Ceiling Girder (Top)
    const ceilingHeight = 14.0;
    final ceilingPaint = Paint()
      ..color = isBossChamber ? const Color(0xFF221319) : const Color(0xFF171D27);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, ceilingHeight), ceilingPaint);

    final ceilingLipPaint = Paint()
      ..color = isBossChamber ? const Color(0xFF381B26) : const Color(0xFF242C3C)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(0, ceilingHeight), Offset(size.width, ceilingHeight), ceilingLipPaint);

    // Hazard caution dashes on ceiling girder for active/boss rooms
    if (isBossChamber || isActive) {
      final hazardPaint = Paint()
        ..color = isBossChamber
            ? PixelTheme.alertRed.withValues(alpha: 0.6)
            : PixelTheme.warningAmber.withValues(alpha: 0.35)
        ..strokeWidth = 2;
      for (double x = 4; x < size.width; x += 14) {
        canvas.drawLine(Offset(x, 2), Offset(x + 6, ceilingHeight - 2), hazardPaint);
      }
    }

    // 4. Flat Horizontal Floor Slab (Bottom - strictly horizontal, zero slope)
    const floorHeight = 18.0;
    final floorTop = size.height - floorHeight;

    // Floor beam solid body
    final floorBodyPaint = Paint()..color = const Color(0xFF19202B);
    canvas.drawRect(Rect.fromLTWH(0, floorTop, size.width, floorHeight), floorBodyPaint);

    // Crisp 2px walking rail baseline (where hero and enemy feet stand)
    final floorWalkingRailPaint = Paint()
      ..color = const Color(0xFF384458)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, floorTop), Offset(size.width, floorTop), floorWalkingRailPaint);

    // Floor plate rivet notches
    final floorNotchPaint = Paint()
      ..color = const Color(0xFF2B3648)
      ..strokeWidth = 1.5;
    for (double x = 20; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, floorTop + 3), Offset(x, size.height - 3), floorNotchPaint);
    }

    // 5. Ambient Vignette / Fog Tint for inactive rooms
    if (!isActive) {
      final dimPaint = Paint()
        ..color = PixelTheme.roomVoid.withValues(alpha: isCleared ? 0.35 : 0.6);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CutawayRoomPainter oldDelegate) {
    return oldDelegate.roomType != roomType ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isCleared != isCleared;
  }
}
