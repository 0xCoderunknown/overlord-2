import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'core/pixel_theme.dart';
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
        final content = CrtOverlay(child: child ?? const SizedBox.shrink());
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 900) {
              return content;
            }
            const phoneWidth = 860.0;
            final phoneHeight = constraints.maxHeight.clamp(0.0, 420.0);
            return Container(
              color: const Color(0xFF05060A),
              alignment: Alignment.center,
              child: Container(
                width: phoneWidth,
                height: phoneHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: PixelTheme.borderPixel, width: 2),
                ),
                clipBehavior: Clip.hardEdge,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(phoneWidth, phoneHeight),
                  ),
                  child: content,
                ),
              ),
            );
          },
        );
      },
      home: const OverseerScreen(),
    );
  }
}
