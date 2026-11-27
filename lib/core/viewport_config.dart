import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'pixel_theme.dart';

/// Centralizes desktop/browser viewport framing and camera zoom presets
/// so mobile layouts remain isolated and unaffected.
class ViewportConfig {
  ViewportConfig._();

  static const double landscapeBreakpoint = 600.0;
  static const double desktopWideBreakpoint = 1000.0;
  static const double fallbackFrameWidth = 860.0;
  static const double fallbackFrameHeight = 420.0;

  static const double minExpeditionScale = 0.45;
  static const double maxExpeditionScale = 3.0;

  static bool isDesktopOverview(Size viewportSize) {
    return viewportSize.width >= desktopWideBreakpoint;
  }

  /// Scales the facility width to 100% of wide desktop viewports (HD, FHD, QHD, etc.)
  /// while keeping mobile at 1.0x room-follow scale.
  static double initialExpeditionScale(
    Size viewportSize, {
    required double buildingWidth,
    required double buildingHeight,
  }) {
    if (!isDesktopOverview(viewportSize) || buildingWidth <= 0) {
      return 1.0;
    }
    return (viewportSize.width / buildingWidth).clamp(
      minExpeditionScale,
      maxExpeditionScale,
    );
  }
}

/// Keeps desktop/Chrome in landscape (fullscreen when wide, or scaled
/// 860x420 fallback if the browser window is narrowed into portrait),
/// while passing mobile layouts through untouched.
class DesktopViewportFrame extends StatelessWidget {
  final Widget child;

  const DesktopViewportFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape =
            constraints.maxWidth >= ViewportConfig.landscapeBreakpoint &&
            constraints.maxWidth >= constraints.maxHeight;
        if (!kIsWeb || isLandscape) {
          return child;
        }
        return Container(
          color: const Color(0xFF05060A),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: ViewportConfig.fallbackFrameWidth,
              height: ViewportConfig.fallbackFrameHeight,
              decoration: BoxDecoration(
                border: Border.all(color: PixelTheme.borderPixel, width: 2),
              ),
              clipBehavior: Clip.hardEdge,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: const Size(
                    ViewportConfig.fallbackFrameWidth,
                    ViewportConfig.fallbackFrameHeight,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
