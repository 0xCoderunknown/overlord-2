# OVERLORD 2 // Game Design Blueprint

> **DOCUMENT ID:** `OV2-GDD-001`  
> **DATE:** 27-11-2026  
> **STATUS:** ACTIVE DEVELOPMENT (ANDROID & CHROME WEB)

---

## 🏢 1. High-Level Concept

**Overlord 2** is a **2D Side-Cutaway Building Dungeon Crawler**, fusing the quest loop of *Fallout Shelter* with the 2D pixel aesthetic and room progression of *Dead Cells*.

```
   ┌───────────┬─────────┬──────────┬────────┐  [ROOF / BOSS]
   │ [★ BOSS ★]│  Room   │  Room    │ [ELEV] │
   ├───────────┼─────────┼──────────┼────────┤  [FLOOR 2]
   │   Room    │  Room   │  Room    │ [ELEV] │
   ├───────────┼─────────┼──────────┼────────┤  [FLOOR 1: GROUND]
   │[▶ AIRLOCK]│[OUTLINE]│ [HIDDEN] │ [ELEV] │
   └───────────┴─────────┴──────────┴────────┘
```

---

## 🔁 2. Core Exploration Loop

1. **Mission & Scout Selection**:
   - Pick a Tier 1–3 contract directly on `OverseerScreen`, then select a scout on `MissionScreen` and drop into Floor 1's Airlock.
2. **Room Encounters**:
   - **Hostiles:** 1v1 auto-battler with 1.0s pre-strike cadence, sequential two-way banter (`BanterEngine`), 3-stage knockdown, and searchable scrap piles.
   - **Events & Lore:** Empty rooms seed indoor lore plus interactive Floor Safes, Medical Cabinets, and Tripwire Traps (`EventModal`).
3. **Fog of War & Vertical Transit**:
   - Unexplored rooms stay blacked out; clearing a room reveals adjacent outlines. Cleared rooms allow free backtracking to the elevator shaft.
   - The Apex Boss Chamber spawns on the top floor furthest from the elevator (`col 0`).
4. **Extraction or Defeat**:
   - Defeating the Apex Boss (or returning to the Ground Airlock) unlocks `EXTRACT` to bank earned Caps, consumables/materials, unused Medkits, and challenge progress back to `BunkerManager` (weapons/armor are run-only).

---

## 💰 3. Progression & Contract Economy

- **Playable Scouts & Challenges**:
  - 5 starters (`Vance`, `Shina`, `Drifter`, `Sentry Bot`, and unlockable `Alley Cat`), each with distinct HP and starter gear.
  - Permanent milestones (`ChallengesScreen`) unlock new loot (`Nail-Studded Bat`) and starters (`Alley Cat`).
- **3-Tier Contracts**:
  - `ABANDONED CLINIC` (Tier 1, 2 Floors), `INDUSTRIAL DEPOT` (Tier 2, 3 Floors), and `BLACK-SITE BUNKER` (Tier 3, 4 Floors, 2x Bounty Payout).

---

## 🗺️ 4. Open Roadmap

- [ ] Re-enable Paid Requisition & Pre-Run Loadout Selection (when store economy is finalized)
- [ ] Tiered Key Safes (T1–T3) & In-run Weapon Upgrade Kits
