# OVERLORD 2 // Changelog

All notable changes and milestones for **Overlord 2** are documented in this file.
Versioning adheres to `0.0.1`, `0.0.2`, `0.0.3`... format.
Dates strictly use the Indian numerical date format (`DD-MM-YYYY`).

---

## [Unreleased]

### 🧭 Landscape Mode, CRT Terminal & Quest Board
- **Fallout-Style CRT Overlay (`CrtOverlay`, `main.dart`):**
  - Added a global non-interactive CRT scanline, dark vignette, and subtle `#00E676` phosphor rim overlay across the entire game.
- **Landscape Orientation & Full-Width Desktop Scaling (`ViewportConfig`, `main.dart`, `ExpeditionScreen`, `OverseerScreen`, `MissionScreen`):**
  - Flipped the app to Landscape (mobile landscape lock, fullscreen landscape on wide desktop/Chrome with `860×420` fallback for narrow windows, 2-column `OverseerScreen`, 5-column scout/weapon grids, 2-column Quest Board grid, and unified compact `38px` `BunkerAppBar`).
  - Scaled `ExpeditionScreen` on wide desktop displays (HD, FHD, QHD) to fill **100% of screen width** edge-to-edge while keeping vertical floor-follow camera panning smooth.
- **Quest Board & Haunted Home (`MissionScreen`, `BuildingGenerator`):**
  - Replaced inline home mission cards with a full-screen **Quest Board** featuring location loot-focus tags and the new **Haunted Home** (`3 Floors`, haunted lore, **Burial Cloth** drops).

### 🩺 Per-Character Stats, Scarce Medkits & 3-Bed Medbay
- **Per-Character Progression (`CharacterStats`):**
  - Tracked **Level**, **Runs**, and **Kills** separately per scout across `CharactersScreen` and `MissionScreen`.
- **Scarce Medkits & 3-Bed Medbay Roulette (`BunkerManager`, `MedbayBedsPanel`, `FacilityScreen`):**
  - Removed the free guaranteed Medkit on deployment (`0` when dry), opened the 3-bed Medbay from Day 1 (renaming the 10K Caps lock to `MEDKIT SYNTHESIZER [OFFLINE]`), added post-run `INJURED` (`2R`) and ration-poisoning `SICK` (`1R`) states, mystery scrap-cooking shots (`60%` Heal / `25%` Poison `+2R` / `15%` Fatal Overdose), `Burial Cloth` corpse disposal, and **Vault Intern** anti-softlock deployment.

---

## [0.0.6] - 27-11-2026

### 🏛️ Vault Command Center, Multi-Scout Roster & Challenges
- **Bottom-Anchored Command Deck (`OverseerScreen`):**
  - Redesigned the Command Center with an expanded **Vault 42 // Overseer** briefing panel (`CAPS`, `RUNS`, `KILLS`, and live PA / Last-Run Debrief ticker), a 2×2 hub grid (`CHARACTERS`, `WEAPONS`, `CHALLENGES`, `MEDBAY`), and direct 3-tier Mission Cards (`T1`–`T3`) anchored in the lower thumb zone.
  - Hid the unused `REQUISITION` store and `ARMORY STASH` tiles to keep the hub focused on missions, roster/weapons codexes, milestones, and Medbay synthesis.
- **Playable Scouts & Direct Mission Deployment (`CharactersScreen`, `MissionScreen`):**
  - Added 5 distinct starters with unique HP, starter weapons/armor, and inspectable bios: **Vance**, **Shina**, **Drifter**, **Sentry Bot**, and unlockable **Alley Cat**.
  - Clicking any mission card on `OverseerScreen` opens `MissionScreen` to pick your scout and drop straight into the facility.
- **Weapons Codex & Challenges Tracker (`WeaponsScreen`, `ChallengesScreen`):**
  - Added `WeaponsScreen` to inspect all Tier 1–3 and unlockable weapons, and `ChallengesScreen` to track milestone progress (*Slugger Initiate*, *Rat Exterminator*, *Apex Survivor*).

### 📱 Mobile Chrome Frame, Auto-Follow Camera & Wasteland Rations
- **Mobile-Sized Browser Frame & Smooth Camera:**
  - Framed Chrome web runs inside a `420×860` mobile viewport so desktop play matches phone proportions.
  - Added smooth auto-follow camera panning in `ExpeditionScreen` so the view tracks your scout automatically across rooms and floors.
- **Fallout-Style Field Rations & Backpack Auto-Equip:**
  - Added wasteland food items (*Purified Water*, *Canned Dog Food*, *Rad-Radish*, *Dirty Water*, *Spoiled Canned Meat*) usable out of combat, plus one-tap best-gear auto-equip in `BackpackSheet`.

### 💬 Call-and-Response Banter, Boss Taunts & Indoor Lore
- **Sequential Combat Banter:**
  - Updated combat banter to play sequentially (`2.0s` enemy taunt $\rightarrow$ `1.4s` scout reply) without a 3-round cap, keeping banter visible even when Stealthboys or Emergency Heal are active.
  - Added breathing space after room entry (`450ms`), during enemy knockdowns, and before post-fight scrap quips.
- **Enemy-Matched & Boss Dialogue:**
  - Added *Bad Boys II*-style absurd random-word confusion lines for mutated animals & Turkey, feral ghoul rasps, robotic `Pre-War Battlemech` lines, and *Borderlands 1* Sledge-inspired Apex Boss taunts (timed cleanly after the boss intro overlay).
- **Indoor Room-Type Lore:**
  - Matched empty-room observations to `clinic`, `generator`, `office`, `storage`, and `corridor` interiors.

---

## [0.0.5] - 25-11-2026

### 🏛️ Complete Bunker ↔ Expedition Loop & Contracts
- **3-Tier Infiltration Contracts (`ContractPickerDialog`):**
  - Launching an expedition from `OverseerScreen` now offers 3 contracts: **Abandoned Clinic** (2 Floors), **Industrial Depot** (3 Floors), and **Black-Site Bunker** (4 Floors, 2x Bounty Payout).
- **Live Loadout Deployment & Extraction:**
  - Vance deploys directly with the Vault Armory's best weapon, armor, and Medkits, and `OverseerScreen` displays live loadout & vitals.
  - Defeating the top-floor Boss (or returning to the Ground Airlock with spoils) unlocks **Extract**, banking earned Caps, scavenged backpack loot, and unused Medkits back into `StashScreen`.
  - Flatlining returns to the Bunker with unbanked expedition loot lost.

### 🎒 Tactical Dock, Visual Backpack & Stealthboy Bypass
- **Expedition Bottom Bar (`ExpeditionBottomBar`):**
  - Replaced cramped HUD chips with a dedicated bottom tactical dock featuring **BACKPACK (N)**, **MED (N)**, and **EXTRACT**.
- **Upgraded Visual Backpack (`BackpackSheet`):**
  - Displays Vance's `[ EQUIPPED ]` Weapon & Armor sprite cards alongside a 2-column `ItemGridCard` grid for live mid-run gear swapping and consumable use.
- **Stealthboy Cloak Bypass:**
  - Added an in-room **STEALTH** button allowing Vance to slip past non-boss enemies without combat and reveal adjacent rooms.

### 🗝️ Room Events, Traps, Medbay Drops & Boss Polish
- **Interactive Safes, Med Cabinets & Tripwires (`EventModal`):**
  - Empty rooms now seed sealed **Floor Safes** (unlockable with Master Keys or risky lock-forcing), **Medical Cabinets** (dropping Medkits + Medbay crafting materials: *Used Syringes*, *Irradiated Herbs*, *Expired Chemicals*), and armor-mitigated **Tripwire Traps**.
  - Expanded empty-room atmosphere with Overlord 1's `passiveLore` pool.
- **Apex Boss Placement & Intro Alert:**
  - Moved the Apex Boss Chamber to the top-floor room **furthest from the elevator** (`col 0`) so it is reached last.
  - Added a crimson `⚠ APEX THREAT DETECTED ⚠` alert pulse when breaching the Boss Chamber, and removed `CLEARED` floor clutter.

### 💬 Two-Way Combat Banter
- **Call-and-Response Combat Dialogue (`BanterEngine`):**
  - Combat dialogue now goes both ways across Rounds 1–3: human raiders, security drones, and bosses trade back-and-forth taunts with Vance, while animals (including the **Featherless Turkey**) speak `"....."` with confused or joking replies from Vance.

---

## [0.0.4] - 25-11-2026

### ⚔️ In-Room Combat & HUD Polish
- **Overhead Vitality & Eyes-In-Game HUD:**
  - Added color-coded overhead HP bars directly above Scout Vance, matching enemies and bosses.
  - Stripped the redundant top HP bar and event log from the top HUD so all action, banter, and status stay inside the active room.
- **Tactile Floating Popups & Clean Room Real Estate:**
  - Extended floating hit popups (`-DMG`, cyan `BLOCKED` on armor absorption, green `+50` on medkit heal) over `850ms` while keeping hit shakes and flashes crisp.
  - Removed `[PLAYER'S TURN]` / `[ENEMY'S TURN]` banner pills and dry combat math from the room board.
  - Fixed enemy/boss `90°` floor knockdown rendering so defeated enemies visibly tip over before turning into scrap piles.
- **Vance's Solo Banter & Transient Scrap Alerts:**
  - Replaced third-person narrator logs with Vance's first-person scavenger banter, and removed the `> ` prefix from dialogue banners.
  - Added 1–3 dynamic combat banter lines per fight scaling with round count (opening, mid-fight / critical low-HP, and prolonged-fight reactions).
  - Searching scrap piles now packs discovered gear straight into Vance's backpack (`BAG` HUD counter) with no keep/scrap popup, while empty scrap triggers a scavenger quip alongside the transient `EMPTY JUNK` tag.

### 🎨 Bunker UI & Economy Polish
- **Unified Rarity & Liquidation Previews:**
  - Standardized item tier rarity colors (`AppTheme.tierColor`) across inventory grid cards and Armory Stash inspection modals.
  - Synchronized Armory Stash sell-value previews (`BunkerManager.getSellValue`) with Vault liquidation rules (minimum 1 Cap per item).

### 🏗️ Architecture & Documentation Sync
- **Engine Layer Isolation:**
  - Decoupled `ExplorationController` and `BunkerManager` from UI widget imports and added the `lib/engine/engine.dart` barrel export.
- **Documentation & Constitution Rewrite:**
  - Rewrote `AGENTS.md` to remove redundant/stale rules and establish clear layer import boundaries.
  - Updated `README.md`, `DESIGN_DOCUMENT.md`, and `OVERLORD_IMPORT_MANIFEST.md` to reflect the active Bunker Hub and auto-battler loop.

---

## [0.0.3] - 24-11-2026

### 💀 Realistic Death Sequence & Combat Polish
- **Three-Stage Death Cadence:**
  - Upon reaching 0 HP, defeated combatants freeze upright for 0.5 seconds of fatal impact shock.
  - Defeated units collapse and lie prostrate on the room floor for 1.0 second with directional rotation ($90^\circ$ clockwise if facing left, $90^\circ$ counter-clockwise if facing right).
  - After 1.0 second, the fallen body dissolves cleanly into a searchable `[SCRAP PILE]`.
- **Emergency Heal Gating:**
  - Emergency Medkit triage is strictly locked until Scout HP drops to 25% or lower.

### 🏛️ Bunker Meta-Layer & Overlord 1 Systems Integration
- **Command Center (`OverseerScreen`):**
  - Added primary bunker command dashboard with Vault Overseer status, Caps treasury counter, Scout Vance dossier, and direct expedition launch.
- **Requisition Store (`MarketScreen`):**
  - Paid loadout store featuring tabbed Weapon, Armor, and Supplies catalogs with item stat inspection and live purchase using Caps.
- **Armory Stash (`StashScreen`):**
  - 50-slot global storage with item inspection modal supporting single-item sales and bulk-stack liquidation for Caps.
- **Medical Bay (`FacilityScreen`):**
  - Engineering deck facility with 10,000 Caps reconstruction project, multi-ingredient Medkit synthesis (Used Syringes, Irradiated Herbs, Expired Chemicals), and synthesizer overclocking.
- **Offline Pixel & Vector Assets:**
  - Added 10 item icon sprites (`pistol`, `weapon`, `mace`, `staff`, `vest`, `vest_2`, `medkit`, `can_food`, `caps`) and 2 character portraits (`overseer`, `jonny`).
- **Static Vault Archive Compendium:**
  - Integrated 6 core static databases: Weapons/Armor/Items, 4-Tier Bestiary, 80+ ambient lore snippets, incident combat narratives, character profiles, and in-room Points of Interest (POIs).

---

## [0.0.2] - 23-11-2026

### ⚔️ Combat Cadence, Aggro Animation & Dynamic Turn Flow
- **Pre-Strike Turn Anticipation:**
  - Combat announcements precede attacks by 1.0s (`[PLAYER'S TURN]` $\rightarrow$ pause $\rightarrow$ strike $\rightarrow$ `[ENEMY'S TURN]` $\rightarrow$ pause $\rightarrow$ counter-strike) for clear tactical readability.
- **Animated Hostile Aggro Step:**
  - Enemies recognize player entry into the room by smoothly stepping 12–15px towards the scout upon breach.
- **Dynamic In-Room Combat Banner:**
  - Rhythmic status updates (`[COMBAT STARTED]`, `[PLAYER'S TURN]`, `[ENEMY'S TURN]`, `[ENEMY DEFEATED]`) with dynamic border color-coding.
- **Mandatory Auto-Battler Mode:**
  - Streamlined combat into an uninterrupted 1v1 tactical exchange.
- **Instant Stash Replacement:**
  - Searchable `[SCRAP PILE]` immediately spawns in place of defeated enemies upon victory.

### 🧭 Stance, Facing Direction & Traversal Orientation
- **Cleared Room Backtracking & Elevator Return:**
  - Cleared sectors unlock free tap-to-return navigation with glowing borders and `[RETURN]` header prompts.
  - Rickety elevators display interactive `[BOARD]` prompts when adjacent, enabling return transit across floors.
- **Dynamic 1v1 Facing Correction:**
  - Scout and adversaries dynamically face one another based on door entry direction (entering left $\rightarrow$ scout faces right, enemy faces left; entering right $\rightarrow$ scout faces left, enemy faces right).
  - Scout inside narrow elevator shaft consistently faces inward toward the floor.

### 📐 Viewport Optimization & Render Quality
- **Room Dimension Expansion:**
  - Expanded room bounds to $290\text{px} \times 190\text{px}$, preventing render clipping and expanding combat spacing.
  - Compact in-room combat HUD with shrink-wrapped emergency heal controls.

---

## [0.0.1] - 23-11-2026

### 🏢 World Generation & Fallout Shelter Unified Layout
- **Procedural Facility Generator:**
  - Generates multi-floor facilities (Ground Floor 1 to Upper Levels) with seedable deterministic RNG.
  - Diverse room types: airlocks, storage, clinics, generator rooms, corridors, elevator shafts, and apex boss chambers.
- **Fog of War & Traversal:**
  - Unexplored sectors remain blacked out; adjacent rooms reveal glowing outlines upon clearing the active sector.
- **Single Unified Building Viewport:**
  - Continuous building cross-section with smooth pan-and-zoom navigation powered by `InteractiveViewer`.
  - In-room staging: Scout, adversaries, elevator cables, and scrap piles exist directly on the physical room floor.

### 🎨 Pixel Art & Visual Polish
- **16-Bit Local Sprites:**
  - Integrated pixel art sprites for tactical scout Vance and scrap-armored raiders.
- **Flat-Floor 2D Cutaway:**
  - 18px horizontal steel floor slab with walking rail baseline.
  - Low-contrast, desaturated bunker wall panels preventing sprite blending.
  - Grounded contact shadows beneath character feet.
- **Narrow Rickety Elevator Column:**
  - Vertically aligned 100px narrow shaft with twin steel tension cables, overhead hoist pulley drum, corrugated iron wall, cross-braced platform, and glowing amber work lamp.

### ⚔️ Auto-Battler Combat & Juice
- **Calibrated Auto-Exchange:**
  - Automatic 1v1 turn exchanges with rhythmic ~2.2s round cycle.
- **Hit Feedback & Combat Juice:**
  - Decaying sine-wave horizontal hit shake on impact.
  - Visual hit flashes: white flash for enemies, red flash for player.
  - Floating animated damage numbers.
- **Armor Damage Reduction (DR):**
  - Equipped armor actively mitigates incoming enemy damage per strike.

### 🎒 Scavenging, Scrap Economy & Emergency Triage
- **Bounty Gold & Rare Scrap Piles:**
  - Defeating hostiles awards immediate bounty Gold.
  - Enemies collapse into searchable scrap piles with rare weapon/armor drops.
- **Salvage Modal:**
  - Stat comparison against currently equipped items with instant `[EQUIP]` or `[SCRAP]` options.
- **Emergency Medkit Gating:**
  - Medkits locked until Scout HP reaches critical threshold ($\le 25\%$).

### 📚 Content Compendium
- **4-Tier Bestiary:**
  - Grunt, speed, heavy, and apex boss encounters (Featherless Turkey, Pre-War Battlemech, Irradiated Behemoth).
- **Tiered Equipment & Consumables:**
  - Makeshift and pre-war weapons, layered scrap armors, combat stimulants, and trauma medkits.
  - 30+ ambient environmental lore snippets displayed in empty sectors.
