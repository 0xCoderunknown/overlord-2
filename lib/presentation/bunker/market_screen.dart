import 'package:material_ui/material_ui.dart';
import '../../core/app_theme.dart';
import '../../data/vault_archive/item_database.dart';
import '../../domain/vault_models.dart';
import '../../engine/bunker_manager.dart';
import '../widgets/terminal/item_grid_card.dart';
import '../widgets/terminal/terminal_button.dart';
import '../widgets/terminal/terminal_container.dart';

class MarketScreen extends StatefulWidget {
  final BunkerManager bunkerManager;

  const MarketScreen({super.key, required this.bunkerManager});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
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
                      item.imagePath ?? 'assets/images/items/${item.id}.png',
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
                          item.name.toUpperCase(),
                          style: AppTheme.retroText(
                            color: item.tier == 3 ? AppTheme.orangeAccent : (item.tier == 2 ? AppTheme.blueAccent : AppTheme.grey),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "TIER ${item.tier} ${item.type.toUpperCase()}",
                          style: AppTheme.retroText(color: AppTheme.green300, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item.description ?? "No description available.",
                style: AppTheme.retroText(color: AppTheme.green300, fontSize: 12),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(8),
                color: AppTheme.bgBlack,
                child: Text(
                  item.type == 'consumable'
                      ? "RESTORES 50 HP (<=25% HP ONLY)"
                      : item.type == 'weapon'
                          ? "BASE DAMAGE: ${item.minStat} TO ${item.maxStat}"
                          : "DAMAGE REDUCTION: ${item.minStat} DR",
                  style: AppTheme.retroText(color: AppTheme.alertRed, fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              TerminalButton(
                text: "REQUISITION [ ${item.value} CAPS ]",
                borderColor: AppTheme.warningYellow,
                textColor: AppTheme.warningYellow,
                padding: 12,
                onPressed: () {
                  final success = widget.bunkerManager.buyItem(item);
                  Navigator.pop(modalContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: success ? AppTheme.green[900] : AppTheme.red[900],
                      content: Text(
                        success ? "> ACQUIRED: ${item.name.toUpperCase()}" : "> ERROR: INSUFFICIENT CAPS",
                        style: AppTheme.retroText(color: AppTheme.white, fontSize: 12),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableWeapons = ItemDatabase.weapons.map((d) => Item.fromDatabase(d)).toList();
    final availableArmor = ItemDatabase.armor.map((d) => Item.fromDatabase(d)).toList();
    final availableConsumables = ItemDatabase.consumables.map((d) => Item.fromDatabase(d)).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(
          backgroundColor: AppTheme.bgDark,
          iconTheme: const IconThemeData(color: AppTheme.green),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("REQUISITION STORE", style: AppTheme.retroText(color: AppTheme.green, letterSpacing: 1.5)),
              Text("CAPS: ${widget.bunkerManager.caps}", style: AppTheme.retroText(color: AppTheme.warningYellow)),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: AppTheme.warningYellow,
            labelColor: AppTheme.warningYellow,
            unselectedLabelColor: AppTheme.grey,
            tabs: [
              Tab(text: "WEAPONS"),
              Tab(text: "ARMOR"),
              Tab(text: "SUPPLIES"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGrid(availableWeapons),
            _buildGrid(availableArmor),
            _buildGrid(availableConsumables),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Item> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemGridCard(
          item: item,
          onTap: () => _showItemInspectionModal(context, item),
        );
      },
    );
  }
}

