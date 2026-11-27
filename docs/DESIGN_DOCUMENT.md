# OVERLORD 2 // Game Design & Technical Blueprint

> **DOCUMENT ID:** `OV2-GDD-001`  
> **DATE:** 27-11-2026  
> **STATUS:** ACTIVE DEVELOPMENT (MOBILE & CHROME WEB)  

---

## 🏢 1. High-Level Concept: Building Expedition Crawler

**Overlord 2** shifts from pure text/terminal telemetry to a **2D Side-Cutaway Building Dungeon Crawler**, fusing the quest structure of *Fallout Shelter* with the gritty 2D pixel aesthetic and room progression inspired by *Dead Cells*.

```
   ┌─────────┬─────────┬─────────┐  [ROOF / EXTRACTION]
   │  Room   │  Room   │  Stairs │
   ├─────────┼─────────┼─────────┤  [FLOOR 2]
   │ Elevator│  Room   │  Room   │
   ├─────────┼─────────┼─────────┤  [FLOOR 1: GROUND]
   │ [TEAM]  │ [LOCKED]│ [HIDDEN]│
   └─────────┴─────────┴─────────┘
```

---

## 🔁 2. Core Exploration Loop

1. **Approach & Entrance**:
   - The expedition team arrives outside a multi-story building / ruin structure.
   - Ground floor entrance room is active and visible.
2. **Room Engagement**:
   - Inside a room, the encounter resolves:
     - **Loot**: Containers, salvage, caps, weapons, supplies.
     - **Enemy Combat**: Hostile vermin, bandits, automated security, or mutants.
     - **Empty / Narrative Event**: Abandoned office, environmental hazard, survivor, or trap.
3. **Fog of War & Room Discovery**:
   - Neighboring rooms are hidden until the current room is cleared.
   - Cleared rooms reveal outlines of adjacent rooms.
   - Tapping an outlined room commands the team to travel there.
4. **Vertical Traversal**:
   - Key rooms contain transit points (elevators, rusted stairwells, fire escapes).
   - Reaching stairs/elevators transitions the squad between floors (upwards or downwards into subterranean basements).
5. **Extraction / Boss**:
   - Clearing the pinnacle, basement vault, or reaching the extraction point concludes the expedition and transfers collected spoils to the home base.

---

## 🎨 3. Visual & Aesthetic Architecture

- **Visual Style**: 2D Pixelated Cross-Section / Side-Cutaway view.
- **Rendering Strategy in Flutter**:
  - `CustomPainter` / Canvas with crisp pixel scaling (`FilterQuality.none`).
  - Procedural building tilemaps: floor slabs, doorways, walls, stairwells, and interactive props.
  - Pixel sprites / silhouette animations for the dweller squad and adversaries.
  - High performance, 60/120 FPS responsive touch controls on mobile and web.
- **100% Offline**: No network dependencies, no external web fonts.

---

## 💰 4. Progression, Starters & Contract Economy

- **Playable Scouts & Milestone Unlocks:**
  - Players choose from 5 starter scouts (`Vance`, `Shina`, `Drifter`, `Sentry Bot`, and unlockable `Alley Cat`), each with distinct max HP and signature starter weapon/armor.
  - Permanent milestones (`ChallengesScreen`) unlock new loot-pool weapons (`Nail-Studded Bat`) and starters (`Alley Cat`) across runs.
  - Note: Paid Requisition (`MarketScreen`) and `StashScreen` are currently hidden/standby while the direct starter-deployment and Medbay synthesis loop is active.
- **3-Tier Mission Contracts:**
  - `Abandoned Clinic` (Tier 1, 2 Floors, Low Hazard), `Industrial Depot` (Tier 2, 3 Floors, Moderate Hazard), and `Black-Site Bunker` (Tier 3, 4 Floors, Lethal Threats, 2x Bounty Payout).

---

## 🗺️ 5. Roadmap & Milestone Horizons

- [x] Flutter project initialization (Android + mobile-framed Chrome Web `420×860`)
- [x] Core Room & Building Data Structures (Grid, Room Types, Traversal Graph)
- [x] 2D Cross-Section Building Renderer (Fog of war, room outlines, auto-follow camera)
- [x] Tap-to-Move squad navigation engine & cleared-room backtracking
- [x] Modular 1v1 auto-battler with turn cadence, hit recoil, floating damage numbers, and 3-stage knockdown
- [x] Direct-to-backpack Scrap Piles, Fallout-style rations, Stealthboy bypass, and `BackpackSheet`
- [x] 2D pixel-art cutaway rooms & narrow rickety elevator shaft
- [x] Dynamic combatant orientation & sequential two-way combat banter (`BanterEngine`)
- [x] Tactical survival emergency heal gating (<=25% HP only)
- [x] In-room Safes, Medical Cabinets & Tripwire Traps (`EventModal`)
- [x] 3-Tier Mission Contracts, 5 Playable Starters, Weapons Codex, Challenges & Medbay Synthesis
- [ ] Re-enable Paid Requisition & Pre-Run Loadout Selection (when store economy is finalized)

