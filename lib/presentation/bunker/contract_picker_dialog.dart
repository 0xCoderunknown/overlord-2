import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../core/pixel_theme.dart';
import '../../data/game_database.dart';
import '../../domain/models.dart';
import '../widgets/terminal/terminal_container.dart';

class ContractPickerDialog extends StatelessWidget {
  final void Function(ExpeditionContract contract) onSelect;

  const ContractPickerDialog({super.key, required this.onSelect});

  Color _hazardColor(int level) {
    if (level >= 3) return AppTheme.alertRed;
    if (level == 2) return AppTheme.orangeAccent;
    return PixelTheme.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: AppTheme.transparent,
        child: TerminalContainer(
          width: 350,
          padding: const EdgeInsets.all(16),
          borderColor: PixelTheme.neonGreen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SELECT INFILTRATION CONTRACT',
                style: AppTheme.retroText(
                  color: PixelTheme.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...GameDatabase.contracts.map((contract) {
                final color = _hazardColor(contract.hazardLevel);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => onSelect(contract),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgBlack,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contract.title,
                                  style: AppTheme.retroText(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contract.subtitle,
                                  style: AppTheme.retroText(
                                    color: AppTheme.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: color, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '[ CANCEL ]',
                  style: AppTheme.retroText(color: AppTheme.grey, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
