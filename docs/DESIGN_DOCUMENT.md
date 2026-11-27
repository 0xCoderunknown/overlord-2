# OVERLORD 2 // Game Design Blueprint

> **DOCUMENT ID:** `OV2-GDD-001`  
> **DATE:** 27-11-2026  
> **STATUS:** ACTIVE DEVELOPMENT (LANDSCAPE ANDROID & CHROME WEB)

---

## 🏢 1. High-Level Concept

**Overlord 2** is a **Landscape 2D Side-Cutaway Building Dungeon Crawler**, fusing the quest loop of *Fallout Shelter* with the 2D pixel aesthetic and room progression of *Dead Cells*.

* **Premise ("Broke Overseer"):** The Overseer blew the budget on the sequel, so Vault 42 has no fancy armory or free Medkit handouts—scouts deploy with makeshift junk, eat questionable wasteland rations to survive, and risk back-alley Medbay injections between runs.
* **Landscape Presentation:** `860×420` mobile-proportioned Chrome frame and landscape Android orientation so the active room, adjacent room(s), and elevator are visible and tappable side-by-side.

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

## 🔁 2. Core Exploration & Bunker Loop

1. **Quest Board & Scout Selection**:
   - `OverseerScreen` (2-column landscape Command Deck) opens `MissionScreen` (**Quest Board**) to pick a location (`Abandoned Clinic`, `Industrial Depot`, `Haunted Home`, `Black-Site Bunker`), then pick an available scout and drop into Floor 1's Airlock.
2. **Room Encounters & Scarce Survival**:
   - **Hostiles:** 1v1 auto-battler with 1.0s pre-strike cadence, sequential two-way banter (`BanterEngine`), 3-stage knockdown, and searchable scrap piles.
   - **Scarce Medkits & Rations:** Scouts deploy with only the Medkits actually in Bunker storage (`0` when dry). Eating sketchy wasteland rations (*Rad-Radish*, *Dirty Water*, *Spoiled Canned Meat*) can trigger food poisoning (`caughtSickness`).
   - **Events & Lore:** Empty rooms seed indoor lore plus interactive Floor Safes, Medical Cabinets, and Tripwire Traps (`EventModal`).
3. **3-Bed Medbay, Scrap Cooking & Permadeath**:
   - **Post-Run Recovery:** Flatlining benches a scout as `INJURED` (`2` runs); ration sickness benches them as `SICK` (`1` run), occupying 1 of **3 Medbay beds** (`maxMedbayBeds = 3`). Completing a run with another scout ticks down recovery by `1`.
   - **Instant Triage vs. Mystery Cooking:** Spend `1` Medkit for a guaranteed cure, OR cook `1` scavenged material (*Used Syringe*, *Irradiated Herb*, *Expired Chemicals*) for a roulette outcome: **Heal (`60%`)**, **Poison `+2R` (`25%`)**, or **Fatal Overdose (`15%`)**.
   - **Corpse Disposal (`Burial Cloth`):** Dead scouts permanently lock their Medbay bed until wrapped with `1 Burial Cloth` (looted in **Haunted Home**).
   - **Anti-Softlock:** If every unlocked scout is dead or recovering, an expendable **Vault Intern** (`70 HP`) deploys so the player is never stuck.

---

## 💰 3. Progression, Locations & Stats

- **Per-Character Progression (`CharacterStats`)**:
  - Each scout tracks **Level** (`1 + kills ~/ 5`), **Runs**, **Kills**, and **Condition** (`healthy`, `injured`, `sick`, `dead`) independently.
- **Locations & Purpose**:
  - `ABANDONED CLINIC` (Tier 1, 2 Floors) — Medbay scrap & syringes.
  - `INDUSTRIAL DEPOT` (Tier 2, 3 Floors) — Balanced weapons, armor & XP.
  - `HAUNTED HOME` (Tier 2, 3 Floors) — Haunted lore & **Burial Cloth** drops.
  - `BLACK-SITE BUNKER` (Tier 3, 4 Floors) — `2×` Coins & Apex Bosses.
- **Challenges**:
  - Permanent milestones (`ChallengesScreen`) unlock loot (`Nail-Studded Bat`) and scouts (`Alley Cat`).

---

## 🗺️ 4. Open Roadmap

- [ ] **Step 4 — The Store:** Spend extracted Coins on scarce Medkits, clean rations (`Purified Water`, `Canned Dog Food`), emergency `Burial Cloth`, or re-cloning buried scouts.
- [ ] **Extract Auto-Scrap:** Convert spare run weapons/armor in the backpack into bonus Coins on extraction.
- [ ] **Haunted Home Threats:** Add dedicated spooky enemies/bosses for `Haunted Home` instead of shared floor pools.
- [ ] **Tiered Key Safes (T1–T3) & In-Run Upgrade Kits.**
