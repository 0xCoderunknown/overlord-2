import 'package:material_ui/material_ui.dart';
import '../../../core/pixel_theme.dart';

class BunkerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final Widget? leading;

  const BunkerAppBar({
    super.key,
    required this.title,
    this.titleColor = PixelTheme.neonGreen,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 38,
      backgroundColor: PixelTheme.roomVoid,
      elevation: 0,
      centerTitle: true,
      leading: leading,
      iconTheme: const IconThemeData(color: PixelTheme.neonGreen, size: 20),
      title: Text(
        title,
        style: PixelTheme.pixelStyle(
          fontSize: 13,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          color: titleColor,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: Divider(height: 2, color: PixelTheme.borderPixel),
      ),
    );
  }
}

class OverseerStatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const OverseerStatBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PixelTheme.roomUnrevealed,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        '$label: $value',
        style: PixelTheme.pixelStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class OverseerDeckTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const OverseerDeckTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: PixelTheme.pixelBox(
          background: PixelTheme.roomVoid,
          borderColor: PixelTheme.borderPixel,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              style: PixelTheme.pixelStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: PixelTheme.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: PixelTheme.pixelStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: accent,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
