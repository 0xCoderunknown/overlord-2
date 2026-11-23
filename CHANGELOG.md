# OVERLORD 2 // Changelog

All notable changes and milestones for **Overlord 2** are documented in this file.
Versioning adheres to `0.0.1`, `0.0.2`, `0.0.3`... format.
Dates strictly use the Indian numerical date format (`DD-MM-YYYY`).

---

## [0.0.1] - 23-11-2026

### 🚀 Initial Release & Architectural Foundation
- **Project Genesis & Target Platforms:**
  - Initialized Flutter 3.50+ / Dart 3.14+ project targeting Android and Web (Chrome-first).
  - 100% Offline pledge: zero external runtime dependencies (`http`, `dio`, analytics, ads, or remote Google Fonts). System `'monospace'` font family used throughout.
- **Autonomous Agent Constitution & Documentation:**
  - Created [AGENTS.md](file:///D:/Android/overlord-2/AGENTS.md) establishing core invariants, code granularity (<400 lines per presentation file), offline pledge, Chrome web target, and local-only git protocol.
  - Authored [docs/DESIGN_DOCUMENT.md](file:///D:/Android/overlord-2/docs/DESIGN_DOCUMENT.md) detailing the 5-minute micro-run roguelite loop, forward-only room locks, key economy, and paid loadout requisition.
  - Authored [docs/BESTIARY_AND_LOOT.md](file:///D:/Android/overlord-2/docs/BESTIARY_AND_LOOT.md) documenting enemy tiers, damage spreads, and armor damage reduction (DR) tables.

### 🏢 World Generation & Fallout Shelter Unified Layout
- **Procedural Facility Generator (`BuildingGenerator`):**
  - Generates multi-floor facilities (Ground Floor 1 to Upper Levels) with seedable deterministic RNG.
  - Configurable room distribution: entrance airlock, storage, clinics, generator rooms, corridors, elevator shafts, and top-floor apex boss chambers.
- **Fog of War & Traversal (`ExplorationController`):**
  - Unexplored sectors are blacked out (`unrevealed`).
  - Adjacent rooms reveal glowing outlines with `[TAP TO ENTER]` prompts upon clearing current sector.
  - Moving forward locks previous rooms (no backtracking).
- **Single Unified Building Viewport (`PixelRoomView`, `ExpeditionScreen`):**
  - Refactored away from split minimap/arena into a single continuous building cross-section.
  - Infinite smooth pan-and-zoom navigation powered by `InteractiveViewer`.
  - In-room staging: Scout, adversaries, elevator cables, and scrap piles exist directly on the physical room floor.

### 🎨 Pixel Art & Visual Polish
- **16-Bit Local Sprite Integration:**
  - Added pixel art assets: `assets/images/hero.png` (tactical scout Vance) and `assets/images/enemy.png` (scrap-armored raider).
  - Implemented horizontal mirroring (`Transform.flip`) so combatants face each other in an authentic 1v1 duel stance.
- **Flat-Floor 2D Cutaway (`RoomBackgroundView`):**
  - 18px horizontal steel floor slab with 2px walking rail baseline.
  - Low-contrast, desaturated matte bunker wall panels (`#121620` / `#1B2230`) preventing sprite blending.
  - Grounded contact shadows beneath both hero and enemy feet.
- **Narrow Rickety Elevator Column (`RicketyElevatorView`):**
  - Vertically aligned 100px narrow shaft with twin steel tension cables, overhead hoist pulley drum with hub, corrugated iron wall, cross-braced platform, and glowing amber work lamp.

### ⚔️ Auto-Battler Combat & Juice
- **Calibrated Auto-Exchange (`CombatEngine`, `InRoomCombatBar`):**
  - Automatic 1v1 turn exchanges with rhythmic ~2.2s round cycle (400ms scout attack, 400ms counter-strike, 1400ms pause for tactical decisions).
  - Manual pause/resume toggle (`[AUTO-BATTLING / PAUSED]`).
- **Hit Feedback & Combat Juice (`HitShake`):**
  - Decaying sine wave horizontal jitter on hit (`sin(progress * pi * 8) * 6.0 * decay`).
  - Visual hit flashes: white flash for enemies, red flash for player.
  - Drifting animated floating damage numbers (`-14 DMG`).
- **Armor Damage Reduction (DR):**
  - Equipped armor actively mitigates incoming enemy damage per strike: $\text{Damage Taken} = \max(0, \text{Enemy DMG} - \text{Armor DR})$.

### 🎒 Scavenging, Scrap Economy & Emergency Triage
- **Bounty Gold & Rare Scrap Piles:**
  - Defeating hostiles awards immediate bounty Gold (`+8` to `+100` Gold).
  - Enemies collapse into a searchable `[SCRAP PILE]` on the room floor.
  - 25% rare salvage discovery rate; 75% empty junk searches.
- **Salvage Modal (`ScrapLootDialog`):**
  - Discovered weapons/armor display stat comparison against currently equipped items.
  - `[EQUIP]`: Equips found item and automatically scraps previous gear for Gold.
  - `[SCRAP (+X G)]`: Dismantles found item into instant Gold currency.
- **Emergency Medkit Gating (25% Critical Rule):**
  - Medkits can only be consumed when Scout HP drops to $\le 25\%$ critical threshold (`canEmergencyHeal`).
  - Locked button (`HEAL LOCKED (<=25% HP)`) dynamically transforms into an active amber button (`EMERGENCY HEAL (+50)`).

### 📚 Content Compendium (`GameDatabase`)
- **4-Tier Bestiary:**
  - Tier 1: Mutated Rat, Feral Hound.
  - Tier 2: Desperate Scrapper, Raider Enforcer.
  - Tier 3: Security Drone, Feral Ghoul Pack.
  - Tier 4 Apex Bosses: Featherless Turkey (*martial artist bird*), Pre-War Battlemech, Irradiated Behemoth.
- **Tiered Weapons & Armor:**
  - Weapons: Heavy Duty Staple Gun, Rusted Rebar Club, 9mm Pipe Pistol, Modified Nailgun, Pre-War Service Rifle, Plasma Torch.
  - Armors: Taped Phonebook Vest, Boiled Leather Apron, Motorcycle Leathers, Welded Scrap Plate, Pre-War Riot Suit, Scrap-Iron Power Frame.
- **Consumables & Lore:**
  - Combat Psycho (+6 DMG), Stealthboy Cloaks, Security Master Keys, Wasteland Trauma Medkits.
  - 30+ ambient environmental lore snippets displayed in quiet/empty sectors.

### 🧪 Verification & Engineering
- **Modular Quality:** All presentation widgets extracted (`RicketyElevatorView`, `RoomBackgroundView`, `RoomEnemyView`, `InRoomCombatBar`, `HitShake`, `PixelHud`, `ScrapLootDialog`) keeping every presentation file strictly under 350 lines (limit <400).
- **Test Suite:** 100% pass rate across 9 unit and widget tests (`flutter test`) and 0 static analysis warnings (`flutter analyze`).
