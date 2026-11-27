# OVERLORD 1 $\rightarrow$ OVERLORD 2 // Import & Asset Manifest

> **DOCUMENT ID:** `OV2-MANIFEST-001`  
> **DATE:** 27-11-2026  
> **SOURCE REPOSITORY:** `../overlord-game`  
> **STATUS:** TRACKING ACTIVE VS STANDBY IMPORTS (`Active` only when imported in `lib/`)

---

## 🗺️ Architecture & Dual-Layer Topology

```
┌────────────────────────────────────────────────────────────────────────┐
│             BUNKER HUB META-LAYER (OVERLORD 1 IMPORT SUITE)            │
│                                                                        │
│  [OverseerScreen]  ──►  [CharactersScreen] / [WeaponsScreen]           │
│  Command Center         [ChallengesScreen] / [FacilityScreen]          │
│         │                                            ▲                 │
│         │ (Select T1-T3 Mission)                     │ (Extracts       │
│         ▼                                            │  Caps & Loot)   │
│  [MissionScreen] (Pick Scout) ───────────────────────┼─────────────────┘
└─────────┼────────────────────────────────────────────┘
          │
          ▼
┌────────────────────────────────────────────────────────────────────────┐
│            2D EXPEDITION CRAWLER (OVERLORD 2 CORE RUNTIME)             │
│                                                                        │
│  • Procedural Multi-Story Facilities (BuildingGenerator)               │
│  • Auto-Follow Camera & 1v1 Auto-Battler with Realistic Death Cadence  │
│  • Rickety Elevators, Traversal, and Cleared Sector Backtracking       │
│  • Direct-to-Backpack Scrap Piles & Two-Way Banter (BanterEngine)      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 1. Imported Files & Status

| Component | Location in Overlord 2 | Source in Overlord 1 | Status | Role |
|---|---|---|---|---|
| **Theme System** | [`lib/core/app_theme.dart`](file:///k:/Android/overlord-2/lib/core/app_theme.dart) | `lib/utils/app_theme.dart` | **Active** | Terminal typography (`'monospace'`), CRT greens, tier & modal colors. |
| **Bunker State** | [`lib/engine/bunker_manager.dart`](file:///k:/Android/overlord-2/lib/engine/bunker_manager.dart) | `lib/engine/game_manager.dart` | **Active** | Caps treasury, starter selection, challenge unlocks, Medbay synthesis. |
| **Domain Models** | [`lib/domain/vault_models.dart`](file:///k:/Android/overlord-2/lib/domain/vault_models.dart) | `lib/models/game_models.dart` | **Active** | `Item`, `Scavenger`, `VaultFacility`, `GameConfig`, `toEquipmentItem()`. |
| **Item Database** | [`lib/data/vault_archive/item_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/item_database.dart) | `lib/content/item_database.dart` | **Active** | Imported by `bunker_manager.dart`. |
| **Terminal Container** | [`lib/presentation/widgets/terminal/terminal_container.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/terminal_container.dart) | `lib/widgets/terminal_container.dart` | **Active** | Retro CRT bounding boxes for panels and modals. |
| **Terminal Button** | [`lib/presentation/widgets/terminal/terminal_button.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/terminal_button.dart) | `lib/widgets/terminal_button.dart` | **Active** | Monospace terminal buttons with disabled handling. |
| **Item Grid Card** | [`lib/presentation/widgets/terminal/item_grid_card.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/item_grid_card.dart) | `lib/widgets/item_grid_card.dart` | **Active** | Tier-colored inventory cards displaying sprite and stats. |
| **Event Modal** | [`lib/presentation/widgets/terminal/event_modal.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/event_modal.dart) | `lib/widgets/event_modal.dart` | **Active** | Bottom sheets and alert dialogs for room events and choices. |
| **Overseer Hub** | [`lib/presentation/bunker/overseer_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/overseer_screen.dart) | `lib/screens/overseer_screen.dart` | **Active** | App home: Overseer briefing, 2×2 hub deck, and direct mission launch. |
| **Facility Screen** | [`lib/presentation/bunker/facility_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/facility_screen.dart) | `lib/screens/facility_screen.dart` | **Active** | Medical Bay restoration (10,000 Caps) and Medkit synthesis. |

---

## 🎨 2. Bundled Graphic Assets (100% Offline)

All assets are registered in [`pubspec.yaml`](file:///k:/Android/overlord-2/pubspec.yaml) and rendered with `FilterQuality.none`.

| File | Path | Role |
|---|---|---|
| `pistol.png` | [`assets/images/items/pistol.png`](file:///k:/Android/overlord-2/assets/images/items/pistol.png) | Pipe Pistol icon |
| `weapon.png` | [`assets/images/items/weapon.png`](file:///k:/Android/overlord-2/assets/images/items/weapon.png) | Service Rifle / Nailgun icon |
| `mace.png` | [`assets/images/items/mace.png`](file:///k:/Android/overlord-2/assets/images/items/mace.png) | Heavy Staple Gun / Nail-Studded Bat icon |
| `staff.png` | [`assets/images/items/staff.png`](file:///k:/Android/overlord-2/assets/images/items/staff.png) | Rusted Rebar Club icon |
| `vest.png` | [`assets/images/items/vest.png`](file:///k:/Android/overlord-2/assets/images/items/vest.png) | Phonebook Vest / Motorcycle Leathers icon |
| `vest_2.png` | [`assets/images/items/vest_2.png`](file:///k:/Android/overlord-2/assets/images/items/vest_2.png) | Welded Scrap Plate / Pre-War Riot Suit icon |
| `medkit.png` | [`assets/images/items/medkit.png`](file:///k:/Android/overlord-2/assets/images/items/medkit.png) | Wasteland Trauma Medkit icon |
| `caps.png` | [`assets/images/items/caps.png`](file:///k:/Android/overlord-2/assets/images/items/caps.png) | Caps currency icon |
| `can_food.png` | [`assets/images/items/can_food.png`](file:///k:/Android/overlord-2/assets/images/items/can_food.png) | Field Rations icon |
| `overseer.webp` | [`assets/images/char/overseer.webp`](file:///k:/Android/overlord-2/assets/images/char/overseer.webp) | Overseer & Sentry Bot portrait |
| `jonny.webp` | [`assets/images/char/jonny.webp`](file:///k:/Android/overlord-2/assets/images/char/jonny.webp) | Shina & Drifter portrait |
| `hero.png` | [`assets/images/hero.png`](file:///k:/Android/overlord-2/assets/images/hero.png) | Scout sprite & Vance / Alley Cat portrait |
| `enemy.png` | [`assets/images/enemy.png`](file:///k:/Android/overlord-2/assets/images/enemy.png) | Hostile & Boss sprite |
