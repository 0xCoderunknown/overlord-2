import 'package:material_ui/material_ui.dart';

class PixelTheme {
  PixelTheme._();

  // Core Palette
  static const Color background = Color(0xFF0F111A);
  static const Color roomVoid = Color(0xFF08090D);
  static const Color roomUnrevealed = Color(0xFF141724);
  static const Color roomOutline = Color(0xFF2C3E50);
  static const Color roomDiscoveredBorder = Color(0xFF4E7D96);
  static const Color roomCleared = Color(0xFF1A2234);
  static const Color roomActive = Color(0xFF243447);

  // Accents & HUD
  static const Color neonGreen = Color(0xFF00E676);
  static const Color terminalGreen = Color(0xFF69F0AE);
  static const Color alertRed = Color(0xFFFF5252);
  static const Color warningAmber = Color(0xFFFFD740);
  static const Color elevatorCyan = Color(0xFF00E5FF);
  static const Color chestGold = Color(0xFFFFC107);
  static const Color borderPixel = Color(0xFF37474F);
  static const Color textLight = Color(0xFFECEFF1);
  static const Color textMuted = Color(0xFF90A4AE);

  static TextStyle pixelStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textLight,
    double letterSpacing = 1.0,
  }) {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
    );
  }

  static BoxDecoration pixelBox({
    Color background = roomCleared,
    Color borderColor = borderPixel,
    double borderWidth = 2.0,
  }) {
    return BoxDecoration(
      color: background,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }
}

