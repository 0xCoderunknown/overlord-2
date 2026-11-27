import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'core/pixel_theme.dart';
import 'core/viewport_config.dart';
import 'presentation/bunker/overseer_screen.dart';
import 'presentation/widgets/terminal/crt_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const Overlord2App());
}

class Overlord2App extends StatelessWidget {
  const Overlord2App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlord 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: PixelTheme.background,
        colorScheme: const ColorScheme.dark(
          primary: PixelTheme.neonGreen,
          secondary: PixelTheme.elevatorCyan,
          surface: PixelTheme.roomVoid,
        ),
      ),
      builder: (context, child) {
        return DesktopViewportFrame(
          child: CrtOverlay(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const OverseerScreen(),
    );
  }
}
