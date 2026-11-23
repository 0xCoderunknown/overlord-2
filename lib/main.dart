import 'package:material_ui/material_ui.dart';
import 'core/pixel_theme.dart';
import 'presentation/bunker/overseer_screen.dart';

void main() {
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
      home: const OverseerScreen(),
    );
  }
}
