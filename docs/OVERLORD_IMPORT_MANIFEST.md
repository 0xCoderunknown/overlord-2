# OVERLORD 1 $\rightarrow$ OVERLORD 2 // Master Import & Integration Manifest

> **DOCUMENT ID:** `OV2-MANIFEST-001`  
> **DATE:** 27-11-2026  
> **SOURCE REPOSITORY:** `../overlord-game` (Overlord 1 — relative sibling folder across PCs)  
> **TARGET REPOSITORY:** `.` (`overlord-2`)  
> **STATUS:** TRACKING ACTIVE VS UNUSED IMPORTS (Mark `Active` only when imported in `lib/`)  

---

## 🧭 Executive Overview

To accelerate development and maximize the depth of **Overlord 2** without sacrificing clean code, modular architecture, or offline purity, all high-value systems, balance math, lore tables, graphic assets, and UI components from **Overlord 1** have been extracted, modernised, and integrated into Overlord 2.

This manifest documents **every imported asset, file, database, model, and screen**, detailing its exact location in Overlord 2, original source location in Overlord 1, current operational state, and both current and future use cases.

---

## 🗺️ Master Architecture & Dual-Layer Topology

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

## 📁 1. Master Catalog: Imported Files & Location Mapping

| Component | Target Location in Overlord 2 | Source Location in Overlord 1 | Type | Current Status | Primary Use Case |
|---|---|---|---|---|---|
| **Theme System** | [`lib/core/app_theme.dart`](file:///k:/Android/overlord-2/lib/core/app_theme.dart) | `lib/utils/app_theme.dart` | Theme Tokens | **Active** | Terminal typography (`'monospace'`), CRT greens, borders, modal colors. |
| **Bunker State** | [`lib/engine/bunker_manager.dart`](file:///k:/Android/overlord-2/lib/engine/bunker_manager.dart) | `lib/engine/game_manager.dart` | ChangeNotifier | **Active** | Manages Caps treasury, global stash, scout roster, and Medbay synthesis. |
| **Domain Models** | [`lib/domain/vault_models.dart`](file:///k:/Android/overlord-2/lib/domain/vault_models.dart) | `lib/models/game_models.dart` | Domain Models | **Active** | `Item`, `Scavenger`, `VaultFacility`, `GameConfig`, and `toEquipmentItem()` bridge. |
| **Item Database** | [`lib/data/vault_archive/item_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/item_database.dart) | `lib/content/item_database.dart` | Static Archive | **Active** | Weapons (Tier 1-3), Armor (Tier 1-3), Consumables, Materials, Scrap. |
| **Enemy Database** | [`lib/data/vault_archive/enemy_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/enemy_database.dart) | `lib/content/enemy_database.dart` | Static Archive | **Unused (Standby)** | 0 imports in `lib/`; crawler uses `game_database.dart` & `enemy.png` (`enemies/*.png` not bundled). |
| **Lore Database** | [`lib/data/vault_archive/lore_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/lore_database.dart) | `lib/content/lore_database.dart` | Static Archive | **Unused (Standby)** | 0 imports in `lib/`; `game_database.dart` supplies indoor & ambient lore pools. |
| **Incident Database** | [`lib/data/vault_archive/incident_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/incident_database.dart) | `lib/content/incident_database.dart` | Static Archive | **Unused (Standby)** | 0 imports in `lib/`; combat outcomes & POI hazard/trap triggers ready for wiring. |
| **Character Database** | [`lib/data/vault_archive/character_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/character_database.dart) | `lib/content/character_database.dart` | Static Archive | **Unused (Standby)** | 0 imports in `lib/`; `game_database.dart` `starters` powers the active 5-scout roster. |
| **POI Database** | [`lib/data/vault_archive/poi_database.dart`](file:///k:/Android/overlord-2/lib/data/vault_archive/poi_database.dart) | `lib/content/poi_database.dart` | Static Archive | **Unused (Standby)** | 0 imports in `lib/`; in-room safes/lockers/terminals (`poi/*.png` not bundled). |
| **Terminal Container** | [`lib/presentation/widgets/terminal/terminal_container.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/terminal_container.dart) | `lib/widgets/terminal_container.dart` | UI Widget | **Active** | High-contrast retro CRT bounding boxes for panels, banners, and modals. |
| **Terminal Button** | [`lib/presentation/widgets/terminal/terminal_button.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/terminal_button.dart) | `lib/widgets/terminal_button.dart` | UI Widget | **Active** | Monospace terminal buttons with border glows and disabled null handling. |
| **Item Grid Card** | [`lib/presentation/widgets/terminal/item_grid_card.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/item_grid_card.dart) | `lib/widgets/item_grid_card.dart` | UI Widget | **Active** | Tier-colored inventory and shop cards displaying sprite, stats, and badges. |
| **Event Modal** | [`lib/presentation/widgets/terminal/event_modal.dart`](file:///k:/Android/overlord-2/lib/presentation/widgets/terminal/event_modal.dart) | `lib/widgets/event_modal.dart` | UI Widget | **Active** | Retro bottom sheets and alert dialogs for choices, inspection, and loot. |
| **Overseer Hub** | [`lib/presentation/bunker/overseer_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/overseer_screen.dart) | `lib/screens/overseer_screen.dart` | Presentation | **Active** | Primary app home: Overseer briefing, Caps/Runs/Kills ledger, 2×2 hub deck, and direct mission launch. |
| **Requisition Market**| [`lib/presentation/bunker/market_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/market_screen.dart) | `lib/screens/market_screen.dart` | Presentation | **Hidden (Standby)** | 0 imports in `OverseerScreen`; retained in `lib/` for future store re-enablement. |
| **Armory Stash** | [`lib/presentation/bunker/stash_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/stash_screen.dart) | `lib/screens/stash_screen.dart` | Presentation | **Hidden (Standby)** | 0 imports in `OverseerScreen`; replaced on the hub grid by `ChallengesScreen`. |
| **Facility Screen** | [`lib/presentation/bunker/facility_screen.dart`](file:///k:/Android/overlord-2/lib/presentation/bunker/facility_screen.dart) | `lib/screens/facility_screen.dart` | Presentation | **Active** | Medical Bay restoration (10,000 Caps), multi-material recipe synthesis, and Medkits. |

---

## 🎨 2. Graphic Asset Inventory (100% Offline)

All assets are bundled locally in the app, registered in [`pubspec.yaml`](file:///k:/Android/overlord-2/pubspec.yaml), and rendered crisply using `FilterQuality.none`.

| Asset File | Target Path in Overlord 2 | Source Path in Overlord 1 | Type | Current & Potential Use Cases |
|---|---|---|---|---|
| `pistol.png` | [`assets/images/items/pistol.png`](file:///k:/Android/overlord-2/assets/images/items/pistol.png) | `assets/images/items/pistol.png` | Item Sprite | **Tier 2: 9mm Pipe Pistol icon.** Used in Market, Stash, and in-room Scrap Loot dialogs. |
| `weapon.png` | [`assets/images/items/weapon.png`](file:///k:/Android/overlord-2/assets/images/items/weapon.png) | `assets/images/items/weapon.png` | Item Sprite | **Tier 2/3: Service Rifle & Nailgun icon.** Longarm representation for high-tier loot. |
| `mace.png` | [`assets/images/items/mace.png`](file:///k:/Android/overlord-2/assets/images/items/mace.png) | `assets/images/items/mace.png` | Item Sprite | **Tier 1: Heavy Staple Gun / Blunt Mace.** Starter makeshift weapon. |
| `staff.png` | [`assets/images/items/staff.png`](file:///k:/Android/overlord-2/assets/images/items/staff.png) | `assets/images/items/staff.png` | Item Sprite | **Tier 1: Rusted Rebar Club.** Heavy blunt scrap weapon. |
| `vest.png` | [`assets/images/items/vest.png`](file:///k:/Android/overlord-2/assets/images/items/vest.png) | `assets/images/items/vest.png` | Item Sprite | **Tier 1: Taped Phonebook / Motorcycle Leathers.** Light ballistic protection icon. |
| `vest_2.png` | [`assets/images/items/vest_2.png`](file:///k:/Android/overlord-2/assets/images/items/vest_2.png) | `assets/images/items/vest_2.png` | Item Sprite | **Tier 2/3: Welded Scrap Plate / Pre-War Riot Suit.** Heavy body armor icon. |
| `medkit.png` | [`assets/images/items/medkit.png`](file:///k:/Android/overlord-2/assets/images/items/medkit.png) | `assets/images/items/medkit.png` | Item Sprite | **Wasteland Trauma Medkit icon.** Displayed across HUD triage buttons and Medbay. |
| `caps.png` | [`assets/images/items/caps.png`](file:///k:/Android/overlord-2/assets/images/items/caps.png) | `assets/images/items/caps.png` | Item Sprite | **Caps / Currency indicator.** Used in Bunker header and market price badges. |
| `can_food.png` | [`assets/images/items/can_food.png`](file:///k:/Android/overlord-2/assets/images/items/can_food.png) | `assets/images/items/can_food.png` | Item Sprite | **Field Rations & Canned Dog Food.** Restores minor HP / stamina during runs. |
| `overseer.webp` | [`assets/images/char/overseer.webp`](file:///k:/Android/overlord-2/assets/images/char/overseer.webp) | `assets/images/char/overseer.webp` | Portrait | **Vault Overseer Badge.** Command Center banner portrait and mission debriefings. |
| `jonny.webp` | [`assets/images/char/jonny.webp`](file:///k:/Android/overlord-2/assets/images/char/jonny.webp) | `assets/images/char/jonny.webp` | Portrait | **Scout Vance Dossier Avatar.** Roster selection and expedition death certificate. |

---

## 📊 3. Detailed Data & Content Breakdown

### A. Items & Equipment (`ItemDatabase`)
- **Weapons Pool:**
  - `w_stapler`: Heavy Duty Staple Gun (DMG: 3–6, Val: 75)
  - `w_rebar`: Rusted Rebar (DMG: 4–9, Val: 120)
  - `w_pipe_pistol`: 9mm Pipe Pistol (DMG: 8–14, Val: 350)
  - `w_nailgun`: Modified Nailgun (DMG: 10–18, Val: 450)
  - `w_service_rifle`: Pre-War Service Rifle (DMG: 20–35, Val: 1,500)
  - `w_plasma`: Plasma Torch (DMG: 30–50, Val: 2,500)
- **Armor Pool:**
  - `a_phonebooks`: Taped-Up Phonebooks (DR: 2–6, Val: 80)
  - `a_leather`: Boiled Leather Apron (DR: 4–10, Val: 150)
  - `a_motorcycle`: Motorcycle Leathers (DR: 8–14, Val: 400)
  - `a_scrap_plate`: Welded Scrap Plate (DR: 12–18, Val: 600)
  - `a_riot_gear`: Pre-War Riot Suit (DR: 18–22, Val: 1,800)
  - `a_power_frame`: Scrap-Iron Power Frame (DR: 25–35, Val: 3,000)
- **Consumables & Crafting Materials:**
  - `c_medkit`: Wasteland Medkit (Heal: 50% HP)
  - `med_syringe`: Used Syringe (Synthesis ingredient)
  - `med_herb`: Irradiated Herb (Synthesis ingredient)
  - `chem_expired`: Expired Chemicals (Synthesis ingredient)
  - `c_dog_food`, `c_rad_radish`, `c_purified_water`, `c_dirty_water`

### B. Bestiary & Threat Profiles (`EnemyDatabase`)
- **Floor 1 (Ground / Grunt Tiers):**
  - `e_rat`: Mutated Rat (HP: 16, DMG: 2–6, Bounty: 8 Caps)
  - `e_hound`: Feral Hound (HP: 22, DMG: 4–10, Bounty: 12 Caps)
- **Floor 2 (Mid Tiers):**
  - `e_scrapper`: Desperate Scrapper (HP: 30, DMG: 6–12, Bounty: 16 Caps)
  - `e_raider`: Raider Enforcer (HP: 38, DMG: 10–16, Bounty: 22 Caps)
- **Floor 3 (High Threat / Automaton Tiers):**
  - `e_drone`: Security Drone (HP: 48, DMG: 15–22, Bounty: 30 Caps)
  - `e_feral_family`: Feral Ghoul Pack (HP: 44, DMG: 8–16, Bounty: 26 Caps)
- **Floor 4+ (Apex Boss Chambers):**
  - `e_turkey`: Featherless Turkey (*martial artist mutant bird*, HP: 75, DMG: 20–30, Bounty: 75 Caps)
  - `e_titan`: Pre-War Battlemech (HP: 90, DMG: 22–38, Bounty: 100 Caps)
  - `e_behemoth`: Irradiated Behemoth (HP: 85, DMG: 20–32, Bounty: 90 Caps)

### C. Lore & Narrative Databases
- **Ambient Lore (`LoreDatabase`):** Contains 80+ lines across 3 distinct tonal tiers:
  - *Grim Reality:* "Found a skeleton clutching a teddy bear. I didn't move them."
  - *Isolation:* "Started talking to my shadow. It didn't talk back. Good."
  - *Tribute Easter Eggs:* Fallout 101, S.T.A.L.K.E.R. Cheeki Breeki, Resident Evil "4 / Itchy / Tasty", Dark Souls Coiled Sword.
- **Incident Logs (`IncidentDatabase`):**
  - Combat announcements, critical strikes, narrow escapes, trap triggering, and jackpot scrap discovers.
- **Points of Interest (`PoiDatabase`):**
  - Definitions for sealed safes, military gun lockers, locked blast doors, and water treatment terminals. Ready to be seeded into Overlord 2's room generator.

---

## 🔄 4. The Domain Bridge: Converters & Compatibility

To connect the Overlord 1 databases with Overlord 2's active 2D dungeon crawler engine without breaking type safety, [`lib/domain/vault_models.dart`](file:///k:/Android/overlord-2/lib/domain/vault_models.dart) provides direct adapter converters:

```dart
// Bidirectional Bridge: Vault Archive Item -> Overlord 2 EquipmentItem
EquipmentItem toEquipmentItem() {
  ItemType it = type == 'weapon' ? ItemType.weapon : 
                type == 'armor'  ? ItemType.armor  : ItemType.consumable;

  return EquipmentItem(
    id: id,
    name: name,
    type: it,
    minStat: minStat ?? 0,
    maxStat: maxStat ?? minStat ?? 0,
    scrapValue: max(1, value ~/ 10),
    consumableEffect: id == 'c_medkit' ? ConsumableEffect.heal : null,
    description: description ?? '',
  );
}
```

This allows items purchased in the **Requisition Store** or retrieved from the **Vault Armory Stash** to be handed directly to Scout Vance before stepping into the expedition elevator.

---

## 🚀 5. Near-Term Expansion Roadmap (Experimental Ideas)

Because we are in active development, we now have immediate access to all these systems for rapid experimentation:

1. **In-Room Points of Interest (POIs):**
   - Seed `PoiDatabase` structures (e.g. *Locked Gun Safe*, *Automated Terminal*, *Medical Cabinet*) into empty rooms alongside ambient lore.
   - Touching the POI opens `EventModal` giving players choices: `[FORCE LOCK (AGILITY)]`, `[HACK TERMINAL (INTEL)]`, or `[LEAVE]`.
2. **Dynamic Squad Roster & Recruitment:**
   - Use `CharacterDatabase` to allow the Overseer to recruit new scouts when Vance dies, each with distinctive traits (e.g., *Claustrophobic: +10% DMG in small rooms*, *Leadbelly: immunity to irradiated water*).
3. **Multi-Item Scrap Drops:**
   - Defeating high-tier enemies or bosses drops crafting materials (`med_syringe`, `chem_expired`, `med_herb`) directly into the scrap pile to feed the Medbay synthesis loop.
4. **Loadout Requisition Screen Before Breach:**
   - Right after pressing `>> LAUNCH FACILITY EXPEDITION <<`, prompt a quick 1-tap "Select Requisition Loadout" popup allowing the player to spend Caps to equip a Pipe Pistol or Riot Vest before entering Floor 1.

---

## 🔒 Verification & Compliance Status

- **100% Offline Integrity:** Zero network dependencies, zero remote font calls, all assets resolved locally.
- **Strict Presentation File Limit:** All UI files strictly $< 400$ lines.
- **Mandatory Indian Date Format:** All dates formatted as `DD-MM-YYYY` (e.g. `24-11-2026`).
- **Test Suite:** All unit and widget tests passing (`flutter test`) with 0 static analysis warnings (`flutter analyze`).

