import 'package:material_ui/material_ui.dart';
import '../../core/pixel_theme.dart';

class ExpeditionDefeatView extends StatelessWidget {
  final int floorIndex;
  final int roomIndex;
  final bool hasBunker;
  final VoidCallback onConfirm;

  const ExpeditionDefeatView({
    super.key,
    required this.floorIndex,
    required this.roomIndex,
    required this.hasBunker,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.alertRed,
          borderWidth: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber,
              color: PixelTheme.alertRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'EXPEDITION TERMINATED',
              style: PixelTheme.pixelStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PixelTheme.alertRed,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scout flatlined in Sector F${floorIndex + 1}:R${roomIndex + 1}.',
              style: PixelTheme.pixelStyle(
                fontSize: 11,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelTheme.alertRed,
                shape: const RoundedRectangleBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: onConfirm,
              child: Text(
                hasBunker ? 'RETURN TO BUNKER' : 'DEPLOY NEW SQUAD',
                style: PixelTheme.pixelStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: PixelTheme.roomVoid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
