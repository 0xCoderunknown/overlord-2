# OVERLORD 2 🏢⚔️

```
  ██████╗ ██╗   ██╗███████╗██████╗ ██╗      ██████╗ ██████╗ ██████╗     ██████╗ 
 ██╔═══██╗██║   ██║██╔════╝██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗    ╚════██╗
 ██║   ██║██║   ██║█████╗  ██████╔╝██║     ██║   ██║██████╔╝██║  ██║     █████╔╝
 ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗██║     ██║   ██║██╔══██╗██║  ██║    ██╔═══╝ 
 ╚██████╔╝ ╚████╔╝ ███████╗██║  ██║███████╗╚██████╔╝██║  ██║██████╔╝    ███████╗
  ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚══════╝
      [ 2D PIXEL-ART FACILITY EXPEDITION CRAWLER // VAULT BUNKER 42 ]
```

[![Changelog](https://img.shields.io/badge/Docs-CHANGELOG.md-green.svg)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.50+-02569B?logo=flutter)](https://flutter.dev)
[![Target: Chrome](https://img.shields.io/badge/Web-Google%20Chrome-4285F4?logo=googlechrome)](https://www.google.com/chrome/)
[![Target: Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline%20%7C%20No%20Trackers-brightgreen)](#-privacy--100-offline-pledge)
[![Architecture](https://img.shields.io/badge/Blueprint-DESIGN__DOCUMENT.md-blueviolet)](docs/DESIGN_DOCUMENT.md)
[![Bestiary](https://img.shields.io/badge/Compendium-BESTIARY__AND__LOOT.md-orange)](docs/BESTIARY_AND_LOOT.md)
[![Constitution](https://img.shields.io/badge/AI%20Maintained-AGENTS.md-blue)](AGENTS.md)

---

## 🎮 What is Overlord 2?

**Overlord 2** is a 2D side-cutaway pixel-art building dungeon crawler fusing the exploration and quest loop of *Fallout Shelter* with the gritty 2D pixel aesthetics of *Dead Cells*.

Players dispatch a solo wasteland scout into procedurally generated multi-story ruined facilities room-by-room. Infiltrate sectors, defeat hostiles in 1v1 auto-battler duels, scavenge scrap piles, ride rickety elevators between floors, and confront lethal apex bosses on the facility pinnacle.

```
                  ┌──────────────┬──────────────┬──────────────┬────────┐
  FLOOR 3 (ROOF)  │  Corridor    │  Generator   │ [★ BOSS ★]   │ [ELEV] │
                  ├──────────────┼──────────────┼──────────────┼────────┤
  FLOOR 2 (MID)   │  Clinic      │  Office      │  Storage     │ [ELEV] │
                  ├──────────────┼──────────────┼──────────────┼────────┤
  FLOOR 1 (GROUND)│ [AIRLOCK]    │ [▶ SCOUT]    │ [UNEXPLORED] │ [ELEV] │
                  └──────────────┴──────────────┴──────────────┴────────┘
```

---

## ⚡ Core Gameplay Highlights

### 🏢 Unified Fallout Shelter Viewport
No disjointed minimaps or detached arena stages. The entire facility *is* the living playfield rendered via a continuous 2D side-cutaway cross-section:
* **Interactive Navigation:** Smooth pan, tilt, and zoom across all floors powered by `InteractiveViewer`.
* **In-Room Staging:** Your scout, adversaries, elevator cables, and scrap piles exist directly on the physical steel floor slabs.
* **Forward-Only Fog of War:** Entering a sector reveals adjacent room outlines with `[TAP TO ENTER]`. Advancing forward permanently seals previous sectors.

### ⚔️ Rhythmic Auto-Battler Combat & Juice
* **Calibrated ~2.2s Exchange Cycles:** Turn cadence alternates automatically:
  - `0.0s – 0.4s`: Scout strikes $\rightarrow$ enemy takes damage, shakes, and floating numbers rise.
  - `0.4s – 0.8s`: Enemy counter-strikes $\rightarrow$ armor DR mitigation $\rightarrow$ Scout takes damage.
  - `0.8s – 2.2s`: Tactical pause for health evaluation and emergency medkit deployment.
* **Combat Juice:** Decaying sine-wave hit-shake jitter, white/red hit flashes, and floating damage numbers (`-14 DMG`).
* **Auto-Battler Flow:** Streamlined mandatory 1v1 auto-exchange loop with 1.0s pre-strike announcements and three-stage death cadence.

### 🛗 Narrow Rickety Elevator Columns
* Vertically aligned 100px elevator shaft connecting ground floors to upper levels.
* Authentic retro industrial details: twin steel hoist cables, overhead hoist drum with hub, corrugated iron walls, cross-braced platform, and glowing amber work lamps.

### 🧰 Scavenging, Scrap Economy & 25% Critical Triage
* **Scrap Piles on Defeat:** Defeated hostiles transform into a searchable `[SCRAP PILE]` on the floor with instant bounty Gold.
* **25% Rare Discovery Rate:** 75% of searches uncover empty junk; 25% yield weapons, armor, or tactical chems.
* **Salvage Modal:** Inspect discovered gear side-by-side with your equipped items $\rightarrow$ `[EQUIP]` (old gear auto-scrapped for Gold) or `[SCRAP]` (convert into instant Gold).
* **Emergency Medkit Gating:** Medkits can only be consumed when Scout HP drops to $\le 25\%$ critical threshold, creating high-stakes tension.

### 💰 Paid Requisition & Economic Risk Loop
* Better starting gear isn't free. Bringing unlocked heavy ordnance costs an upfront **Deployment Fee** in Gold.
* Overkill equipment on low-tier contracts causes a financial deficit. High-risk contracts offer massive payouts, but wiping out triggers a total stock market crash!

---

## 👾 The Bestiary & Loot Compendium

| Tier | Threats & Encounters | Gear & Armory Drops |
|---|---|---|
| **Tier 1 (Ground)** | Mutated Rat (16 HP), Feral Hound (22 HP) | Staple Gun (5-9 DMG), Rebar Club, Phonebook Vest (2-4 DR) |
| **Tier 2 (Mid)** | Desperate Scrapper (30 HP), Raider Enforcer (38 HP) | Pipe Pistol (9-15 DMG), Modified Nailgun, Motorcycle Leathers |
| **Tier 3 (Upper)** | Security Drone (48 HP), Feral Ghoul Pack (44 HP) | Service Rifle (16-26 DMG), Plasma Torch, Riot Suit, Power Frame |
| **Tier 4 (Apex Bosses)** | **Featherless Turkey** (75 HP, martial artist bird), Battlemech, Behemoth | Jackpot Gold Bounties + High-Tier Drops |

> 📖 Complete stat sheets, enemy damage formulas, and armor reduction tables are detailed in the [**Bestiary & Loot Compendium (BESTIARY_AND_LOOT.md)**](docs/BESTIARY_AND_LOOT.md).

---

## 🔒 100% Offline & Privacy Pledge

1. **Zero Remote Dependencies:** Strictly no network libraries (`http`, `dio`, sockets), analytics, crashlytics, or telemetry SDKs.
2. **Built-in System Typography:** Uses `'monospace'` exclusively. No remote Google Fonts runtime downloads to prevent network leaks and comply with strict F-Droid packaging standards.
3. **No Internet Permissions:** Release Android manifests declare zero internet permissions.
4. **Local Data Persistence:** All game state and progress remain 100% on-device.

---

## 🏗️ Codebase Topology

```
lib/
├── core/                        # Pixel & terminal theme tokens, color palettes, typography
├── data/                        # Static datasets (game_database.dart & vault_archive/)
├── domain/                      # Core & Vault models (models.dart, vault_models.dart)
├── engine/                      # Deterministic logic & state controllers (engine.dart barrel)
│   ├── building_generator.dart  # Procedural facility generator with seeded RNG
│   ├── bunker_manager.dart      # Vault Caps, Armory Stash & Medbay state
│   ├── combat_engine.dart       # Modular 1v1 auto-exchange & damage math
│   └── exploration_controller.dart # Fog-of-war, traversal & scrap economy
├── presentation/                # Modular UI screens & widgets (<400 lines per file)
│   ├── bunker/                  # OverseerScreen, MarketScreen, StashScreen, FacilityScreen
│   ├── screens/                 # ExpeditionScreen (2D cutaway infiltration viewport)
│   └── widgets/                 # Room views, HUD, hit-shake, scrap modal & terminal/
└── main.dart                    # Application entry point (starts at OverseerScreen)
test/
├── bunker_test.dart             # BunkerManager economy & Medbay unit tests
├── engine_test.dart             # Unit tests (generator, combat, scrap, gating)
└── widget_test.dart             # Presentation & navigation smoke tests
docs/
├── DESIGN_DOCUMENT.md           # Game design blueprint & mechanics roadmap
├── BESTIARY_AND_LOOT.md         # Full bestiary and equipment compendium
└── OVERLORD_IMPORT_MANIFEST.md  # Overlord 1 asset & system integration catalog
```

---

## 🚀 Running & Development

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev) (`3.50+` / Dart `3.14+`)
* Target Browser: **Google Chrome**

### 1. Launch in Google Chrome (Recommended)
```powershell
flutter run -d chrome
```

### 2. Run via Local Web Server
```powershell
flutter run -d web-server --web-port=8080
```
Open **`http://localhost:8080`** in Chrome.

### 3. Verification & Test Suite
```powershell
# Static analysis (zero warnings)
flutter analyze

# Automated unit & widget tests (100% pass)
flutter test
```

---

## 📄 License

Copyright © 2026 0xCoderunknown.  
Licensed under the [MIT License](LICENSE).
