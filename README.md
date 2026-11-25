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

[![Flutter](https://img.shields.io/badge/Flutter-3.50+-02569B?logo=flutter)](https://flutter.dev)
[![Target: Chrome](https://img.shields.io/badge/Web-Google%20Chrome-4285F4?logo=googlechrome)](https://www.google.com/chrome/)
[![Target: Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![Privacy](https://img.shields.io/badge/100%25%20Offline-Zero%20Trackers-brightgreen)](#-100-offline--zero-bloat)
[![Changelog](https://img.shields.io/badge/Changelog-0.0.4-green.svg)](CHANGELOG.md)

**Overlord 2** is a gritty 2D side-cutaway pixel-art dungeon crawler inspired by *Fallout Shelter* and *Dead Cells*.

You're the Overseer of Vault Bunker 42. Dispatch **Scout Vance** alone into ruined, radiation-soaked pre-war facilities—breach rooms, survive 1v1 ambushes, crack open scrap piles, ride rickety elevators, and take down the apex monstrosity waiting on the roof.

```
                  ┌──────────────┬──────────────┬──────────────┬────────┐
  FLOOR 3 (ROOF)  │  Corridor    │  Generator   │ [★ BOSS ★]   │ [ELEV] │
                  ├──────────────┼──────────────┼──────────────┼────────┤
  FLOOR 2 (MID)   │  Clinic      │  Office      │  Storage     │ [ELEV] │
                  ├──────────────┼──────────────┼──────────────┼────────┤
  FLOOR 1 (GROUND)│ [AIRLOCK]    │ [▶ VANCE]    │ [UNEXPLORED] │ [ELEV] │
                  └──────────────┴──────────────┴──────────────┴────────┘
```

---

## 🎮 How It Plays

### 🏢 One Living Cutaway Building
No split minimaps or detached battle arenas. Everything happens right inside the building cross-section:
* **Pan, Zoom & Breach:** Drag and zoom freely across floors. Tap glowing doorways (`ENTER`) to push into the fog of war.
* **Backtrack Through Cleared Rooms:** Hostile rooms lock down until the fight is over. Once cleared, walk freely back (`RETURN`) to reach the rickety elevator shaft (`BOARD`) and climb to the next floor.
* **Eyes on the Action:** Your HP bar sits right over Vance's head, enemy HP bars sit over theirs, and all of Vance's solo banter and room observations appear right inside the room.

### ⚔️ Snappy 1v1 Room Duels
* **Aggro & Impact:** Enemies step forward when they spot Vance. Every strike shakes the target, flashes on impact, and pops floating numbers straight off the fighter—amber/red damage (`-14`), cyan armor blocks (`BLOCKED`), or green medkit heals (`+50`).
* **No Walls of Math:** No cluttered turn banners or combat spreadsheets—just crisp animations and Vance muttering to himself in the dark.
* **Dramatic Knockdowns:** Defeated fighters freeze at `0 HP`, tip `90°` flat onto the steel floor, and dissolve into a searchable scrap pile.

### 🧰 Scavenging & 25% Critical Triage
* **Loot or Scrap:** Tap `[SCRAP PILE]` drops to scavenge. Empty piles flash `EMPTY JUNK` and fade away; lucky finds (`25%` chance) let you compare stats and either `[EQUIP]` (auto-scrapping your old gear for Gold) or `[SCRAP]` on the spot.
* **Emergency Medkits:** Trauma Medkits stay locked until Vance drops to **25% HP or lower**—pop one at the brink of death to swing a losing duel.

### 🏛️ Vault Bunker 42 (Between Runs)
* **Requisition & Stash:** Spend Caps on weapons, armor, and supplies, and manage your 50-slot Armory Stash.
* **Medbay Synthesis:** Unlock the Medbay for `10,000` Caps to brew, overclock, and claim fresh Trauma Medkits before heading back out.

---

## 👾 Facility Threats & Gear

| Floor Tier | Hostiles | Loot Pool |
|---|---|---|
| **Tier 1 (Ground)** | Mutated Rat (`16 HP`), Feral Hound (`22 HP`) | Staple Gun (`5-9 DMG`), Rebar Club, Phonebook Vest (`2-4 DR`) |
| **Tier 2 (Mid)** | Desperate Scrapper (`30 HP`), Raider Enforcer (`38 HP`) | Pipe Pistol (`9-15 DMG`), Modified Nailgun, Motorcycle Leathers |
| **Tier 3 (Upper)** | Security Drone (`48 HP`), Feral Ghoul Pack (`44 HP`) | Service Rifle (`16-26 DMG`), Plasma Torch, Riot Suit, Power Frame |
| **Tier 4 (Roof Boss)** | **Featherless Turkey** (`75 HP`, martial artist bird), Battlemech, Behemoth | High-tier gear + big Gold bounties |

> Full stat tables and formulas: [Bestiary & Loot Compendium](docs/BESTIARY_AND_LOOT.md) · Design notes: [Design Document](docs/DESIGN_DOCUMENT.md)

---

## 🔒 100% Offline & Zero Bloat

* **No Network Calls:** Zero `http`, `dio`, analytics, telemetry, or ads.
* **System Monospace Font:** Built-in `'monospace'` only—no runtime Google Fonts downloads.
* **Zero Internet Permissions:** Safe, self-contained local play.

---

## 🚀 Run Locally

Requires [Flutter SDK](https://docs.flutter.dev) (`3.50+` / Dart `3.14+`) and **Google Chrome** for web runs.

```powershell
# Play in Google Chrome
flutter run -d chrome

# Static analysis & automated tests
flutter analyze
flutter test
```

### Project Layout
* `lib/domain/` — Pure Dart models (`models.dart`, `vault_models.dart`)
* `lib/data/` — Bestiary, gear tables, and Vault archive datasets
* `lib/engine/` — Procedural building generator, combat math, bunker manager, and exploration controller
* `lib/presentation/` — Bunker screens, cutaway expedition viewport, and pixel room widgets
* `test/` — Engine, bunker economy, and widget tests

---

## 📄 License

Copyright © 2026 0xCoderunknown. Licensed under the MIT License.
