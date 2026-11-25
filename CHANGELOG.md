# OVERLORD 2 // Changelog

All notable changes and milestones for **Overlord 2** are documented in this file.
Versioning adheres to `0.0.1`, `0.0.2`, `0.0.3`... format.
Dates strictly use the Indian numerical date format (`DD-MM-YYYY`).

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
