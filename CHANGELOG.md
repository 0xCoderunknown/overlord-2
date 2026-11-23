# OVERLORD 2 // Changelog

All notable changes and milestones for **Overlord 2** are documented in this file.
Dates strictly adhere to the Indian numerical date format (`DD-MM-YYYY`).

---

## [0.2.0] - 23-11-2026

### 🎨 Visual & Aesthetic Overhaul (100% Offline)
- **Local Pixel Art Sprite Bundle:**
  - Added `assets/images/hero.png`: 16-bit wasteland scout (Vance) in tactical combat armor with glowing green visor and service rifle.
  - Added `assets/images/enemy.png`: 16-bit raider enforcer with scrap metal plates and glowing red optics.
  - Mirrored enemy sprite horizontally with `Transform.flip(flipX: true)` so combatants face each other in an authentic 1v1 duel stance.
- **Narrow Rickety Elevator Shaft (`RicketyElevatorView`):**
  - Scaled elevator shaft width down from `260px` to `100px`, creating a vertically aligned column across all facility floors.
  - Implemented authentic rickety elevator aesthetics: dual steel tension cables, overhead hoist pulley drum with hub, corrugated iron shaft wall, cross-braced lift platform with hazard-striped threshold, and overhead glowing amber work lamp.
- **Architectural Flat-Floor 2D Cutaway (`RoomBackgroundView`):**
  - Replaced high-contrast, sloping perspective art with a strictly horizontal 2D cross-section.
  - 18px solid steel floor slab with 2px walking rail baseline (zero slope).
  - Low-contrast, desaturated matte bunker wall panels (`#121620` / `#1B2230`) ensuring high silhouette separation and zero character blending.
  - Grounded contact shadows beneath both hero and enemy feet.

### ⚔️ Auto-Battler & Combat Juice
- **Automated Combat Loop:**
  - When entering a room with an unresolved enemy, the auto-battler activates automatically.
  - **Calibrated Turn Cadence (~2.2s round cycle):**
    - `0.0s – 0.4s` ($400\text{ms}$): Scout strikes $\rightarrow$ enemy takes damage, shakes, and floating damage numbers rise.
    - `0.4s – 0.8s` ($400\text{ms}$): Enemy counter-strikes $\rightarrow$ armor DR mitigation $\rightarrow$ Scout takes damage and shakes.
    - `0.8s – 2.2s` ($1400\text{ms}$): Tactical pause / decision window for health evaluation and medkit deployment.
  - In-room command bar includes an `[AUTO-BATTLING / PAUSED]` toggle allowing players to pause and resume at will.
- **Hit Shake & Damage Popups (`HitShake`):**
  - Built a 102-line reusable oscillation widget with decaying sine wave horizontal jitter (`sin(progress * pi * 8) * 6.0 * decay`).
  - Added hit-flashes (white flash for enemy, red flash for Scout).
  - Animated floating damage text (`-14 DMG`) drifting upwards and fading out.

### 🛡️ Survival Balance: 25% Critical Heal Rule
- **Emergency Medkit Restriction:**
  - Scout healing is strictly restricted: medkits can only be consumed when HP drops to $\le 25\%$ (`canEmergencyHeal`).
  - When HP is above 25%, the heal button is locked and displays `HEAL LOCKED (<=25% HP)`.
  - When HP drops to $\le 25\%$, the button unlocks into a prominent amber `EMERGENCY HEAL (+50)` button.
  - Added automated unit test coverage in `test/engine_test.dart` validating the 25% threshold.

### 🏗️ Code Quality & Architecture
- **$<400$ Lines Rule Maintained:**
  - Extracted `RicketyElevatorView` (194 lines), `RoomBackgroundView` (138 lines), `RoomEnemyView` (95 lines), `HitShake` (102 lines), and `InRoomCombatBar` (89 lines).
  - Main presentation screen and views stay strictly within limits: `pixel_room_view.dart` (348 lines), `expedition_screen.dart` (263 lines).
- **Automated Verification:** Static analysis passing with 0 warnings (`flutter analyze`) and all 9 automated tests passing (`flutter test`).

---

## [0.1.0] - 22-11-2026

- Initial project foundation: 2D building grid, fog-of-war traversal, scrap piles, and turn-based combat.
