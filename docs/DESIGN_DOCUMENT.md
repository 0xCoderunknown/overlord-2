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

## 🗺️ 4. Roadmap & Milestone Horizons

- [x] Flutter project initialization (Android + Web)
- [x] Git sync with `0xCoderunknown/overlord-2.git`
- [ ] Core Room & Building Data Structures (Grid, Room Types, Traversal Graph)
- [ ] 2D Cross-Section Building Renderer (Fog of war, room outlines, team marker)
- [ ] Tap-to-Move squad navigation engine
- [ ] Room Encounter System (Loot, Combat, Traps)
- [ ] Vertical floor transit (Stairs / Elevators)

