# OVERLORD 2 // Game Design & Technical Blueprint

> **DOCUMENT ID:** `OV2-GDD-001`  
> **DATE:** 22-11-2026  
> **STATUS:** CONCEPT & ARCHITECTURAL FOUNDATION  

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

## 💰 5. The Paid Requisition & Risk/Reward Economy

- **Permanent Unlocks $\neq$ Free Gear**:
  - Unlocking a weapon (via kill mastery, milestones, or blueprints) registers it in the Vault Armory.
  - Bringing an unlocked weapon as your starting loadout costs an upfront **Deployment Fee (Requisition Cost)** in Vault Gold.
- **Economic Tension & Profit Margins**:
  - **Starter Gear (Pipe Pistol):** Cost 0 Gold. High risk, 100% profit margin.
  - **Mid-Tier (Combat Shotgun):** Cost ~300 Gold. Balances risk on Medium contracts.
  - **Heavy / Legendary (RPG / Plasma Cannon):** Cost 2,000 Gold. Overkill on Easy/Medium missions causes a net financial loss even with a victory. On Hard/Nightmare missions (3,000+ Gold payout), it ensures survival but risks a devastating financial crash if you wipe!
- **Mission Contracts (Choose 1 of 3)**:
  - Each contract displays: Target Objective, Difficulty Tier, Base Gold Payout, and Enemy Threat Rating.

---

## 🗺️ 6. Roadmap & Milestone Horizons

- [x] Flutter project initialization (Android + Web)
- [x] Core Room & Building Data Structures (Grid, Room Types, Traversal Graph)
- [x] 2D Cross-Section Building Renderer (Fog of war, room outlines, team marker)
- [x] Tap-to-Move squad navigation engine
- [x] Modular 1v1 combat foundation
- [x] Scrap Piles upon enemy defeat (25% rare salvage & equip/scrap modal)
- [x] 2D pixel-art cutaway rooms & narrow rickety elevator shaft
- [x] Auto-battler loop with turn cadence, hit recoil, and floating damage numbers
- [x] Dynamic combatant orientation (Scout & Enemy always face each other)
- [x] Tactical survival emergency heal gating (<=25% HP only)
- [ ] Tiered Key Safes (T1-T3) & In-run Weapon Upgrade Kits
- [ ] Contract Selection Board (Choose 1 of 3 missions) & Paid Loadout Requisition

