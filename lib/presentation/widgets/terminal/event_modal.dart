import 'package:material_ui/material_ui.dart';
import '../../../core/app_theme.dart';
import 'terminal_button.dart';
import 'terminal_container.dart';

class EventModal extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? accentColor;

  const EventModal({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    required this.onConfirm,
    this.onCancel,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? AppTheme.terminalGreen;

    return Center(
      child: Material(
        color: AppTheme.transparent,
        child: TerminalContainer(
          width: 340,
          padding: const EdgeInsets.all(20),
          borderColor: effectiveColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTheme.retroText(
                  color: effectiveColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Divider(color: effectiveColor.withValues(alpha: 0.4), height: 1),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTheme.retroText(
                  color: AppTheme.white,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: TerminalButton(
                        text: cancelText!,
                        padding: 10,
                        borderColor: AppTheme.grey,
                        textColor: AppTheme.grey,
                        onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TerminalButton(
                      text: confirmText,
                      padding: 10,
                      borderColor: effectiveColor,
                      textColor: effectiveColor,
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

