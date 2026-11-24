import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../domain/vault_models.dart';
import '../../engine/bunker_manager.dart';
import '../widgets/terminal/item_grid_card.dart';
import '../widgets/terminal/terminal_button.dart';
import '../widgets/terminal/terminal_container.dart';

class StashScreen extends StatefulWidget {
  final BunkerManager bunkerManager;

  const StashScreen({super.key, required this.bunkerManager});

  @override
  State<StashScreen> createState() => _StashScreenState();
}

class _StashScreenState extends State<StashScreen> {
  @override
  void initState() {
    super.initState();
    widget.bunkerManager.addListener(_onUpdate);
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    widget.bunkerManager.removeListener(_onUpdate);
    super.dispose();
  }

  void _showItemInspectionModal(BuildContext context, Item item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            final currentItem = widget.bunkerManager.globalStash
                .where((i) => i.id == item.id)
                .firstOrNull;

            if (currentItem == null) {
              Navigator.pop(modalContext);
              return const SizedBox.shrink();
            }

            final currentQty = currentItem.quantity;
            final singleValue = widget.bunkerManager.getSellValue(currentItem, 1);
            final bulkValue = widget.bunkerManager.getSellValue(currentItem, currentQty);

            return TerminalContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        color: AppTheme.bgBlack,
                        child: Image.asset(
                          currentItem.imagePath ?? 'assets/images/items/${currentItem.id}.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.handyman, color: AppTheme.terminalGreen, size: 36),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.name.toUpperCase(),
                              style: AppTheme.retroText(
                                color: AppTheme.tierColor(currentItem.tier),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'TIER ${currentItem.tier} ${currentItem.type.toUpperCase()} [QTY: $currentQty]',
                              style: AppTheme.retroText(
                                color: AppTheme.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentItem.description ?? 'Standard wasteland salvage item.',
                    style: AppTheme.retroText(color: AppTheme.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  if (currentItem.isStackable && currentQty > 1) ...[
                    TerminalButton(
                      text: 'SELL 1 [ +$singleValue CAPS ]',
                      borderColor: AppTheme.orangeAccent,
                      textColor: AppTheme.orangeAccent,
                      padding: 12,
                      onPressed: () {
                        widget.bunkerManager.sellItem(currentItem, 1);
                        setLocalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  TerminalButton(
                    text: currentQty > 1
                        ? 'SELL ALL ($currentQty) [ +$bulkValue CAPS ]'
                        : 'SELL [ +$singleValue CAPS ]',
                    borderColor: AppTheme.alertRed,
                    textColor: AppTheme.alertRed,
                    padding: 12,
                    onPressed: () {
                      widget.bunkerManager.sellItem(currentItem, currentQty);
                      Navigator.pop(modalContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stash = widget.bunkerManager.globalStash;
    final maxStash = GameConfig.maxStashSize;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.green),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VAULT ARMORY STASH',
              style: AppTheme.retroText(
                color: AppTheme.green,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${stash.length} / $maxStash',
              style: AppTheme.retroText(
                color: stash.length >= maxStash ? AppTheme.alertRed : AppTheme.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.green.withValues(alpha: 0.4), height: 1.0),
        ),
      ),
      body: stash.isEmpty
          ? Center(
              child: Text(
                '[ ARMORY STASH EMPTY ]',
                style: AppTheme.retroText(color: AppTheme.grey, letterSpacing: 2),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: stash.length,
              itemBuilder: (context, index) {
                final item = stash[index];
                return ItemGridCard(
                  item: item,
                  onTap: () => _showItemInspectionModal(context, item),
                );
              },
            ),
    );
  }
}

