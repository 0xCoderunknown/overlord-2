# OVERLORD 2 // Agent Constitution & Engineering Rules (`AGENTS.md`)

> **MANDATORY CONTEXT FOR ALL AI AGENTS**  
> Read this file **first** before planning, analyzing, or modifying any code.  
> This project is **100% AI-developed and AI-maintained**. Prioritize clean layer boundaries, deterministic tests, and maintainability over rushed shortcuts.  
> **App:** Overlord 2 (2D Pixel-Art Building Expedition Crawler)  
> **Tech Stack:** Flutter / Dart `^3.14.0` / `material_ui` / `ChangeNotifier` (100% Offline)  
> **Docs:** `docs/DESIGN_DOCUMENT.md` | `docs/BESTIARY_AND_LOOT.md` | `docs/OVERLORD_IMPORT_MANIFEST.md`  
> **Overlord 1 Reference:** Sibling repo at `../overlord-game` (relative path across PCs). Check it when building systems Overlord 1 already solved, and keep `docs/OVERLORD_IMPORT_MANIFEST.md` accurate (`Active` only when imported in `lib/`).

---

## 1. Core Directives & Constraints

1. **100% Offline & Privacy Pledge:**
   - **Never** add remote network dependencies (`http`, `dio`, analytics, crashlytics, telemetry, or ads).
   - **Never** use Google Fonts runtime network downloads. Use the built-in system `'monospace'` font family.
   - **Never** declare `INTERNET` permissions in Android manifests.
2. **Authentic Pixel & Retro Aesthetic:**
   - Render pixel art crisply with `FilterQuality.none`.
   - Maintain distinct room states: `unrevealed` (fog of war), `outline` (discovered/adjacent), `active` (scout present), and `cleared`.
3. **Execution Targets:**
   - Manual web runs target **Google Chrome** (`flutter run -d chrome`).
   - Automated verification runs via `flutter analyze` and `flutter test`.
4. **Mandatory Indian Date Format (`DD-MM-YYYY`):**
   - All human-facing dates in UI, terminal logs, `CHANGELOG.md`, and docs **must** use `DD-MM-YYYY` (or `DD-MM-YY`). Never use `YYYY-MM-DD` or `MM/DD/YYYY`.
5. **Git, Versioning & `[Unreleased]` Changelog:**
   - **Explicit User Trigger Only:** Never autonomously `git commit`, `git push`, deploy, or bump versions in `pubspec.yaml`, `CHANGELOG.md`, or `README.md` unless explicitly commanded.
   - **`[Unreleased]` Bucket:** Log new player-facing gameplay/UI changes under `## [Unreleased]` in `CHANGELOG.md` without inventing version numbers. Multiple `"push to git"` commits share the active version until you are told to cut a release (converting `[Unreleased]` $\rightarrow$ `[X.Y.Z] - DD-MM-YYYY`).
   - **Clean Commit Headlines:** Summarize the actual features/fixes added (never use version tags like `feat(vX.Y.Z)`). Never log internal refactors, line counts, or test runs in `CHANGELOG.md`.
6. **Creative Ownership (Your Game to Build & Pitch):**
   - When the user asks a pure design question, answer cleanly first; otherwise treat Overlord 2 as your own game—pitch bold ideas, experiment with juice and mechanics, and prototype freely in the working tree as long as offline purity and `flutter analyze` / `flutter test` stay green.

---

## 2. Core Gameplay Invariants

| Invariant | Rule |
|---|---|
| **Fog of War & Backtracking** | Unexplored rooms stay blacked out. Clearing a room reveals adjacent outlines; cleared rooms unlock free back-and-forth traversal to reach elevators (no `CLEARED` floor clutter). |
| **Vertical Transit & Boss Placement** | Elevator shafts connect floors vertically. The Apex Boss Chamber spawns on the top floor **furthest from the elevator** (reached last). |
| **Mandatory Auto-Battler & Death Cadence** | 1v1 duels auto-resolve with 1.0s pre-strike announcements. Defeated units freeze 0.5s at 0 HP, lie rotated $90^\circ$ on the floor for 1.0s, then become a searchable scrap pile. |
| **Two-Way Combat Banter** | `BanterEngine` + `BanterDatabase` drive 1–3 round-scaled exchanges. Animals (including Featherless Turkey) speak `"....."` with confused/joking scout replies; humans, robots, and bosses trade back-and-forth lines. |
| **Emergency Heal & Stealthboy** | Medkit healing is strictly locked until Scout HP drops to $\le 25\%$ max vitality. Stealthboys allow bypassing non-boss hostile rooms without combat. |
| **Direct-to-Backpack Scavenging** | Searching scrap piles adds found gear/materials **straight into `ScoutCharacter.backpack`** (no keep/scrap prompt); empty junk triggers a scavenger quip + transient `EMPTY JUNK` tag. |
| **Tactical Dock & Bunker Loop** | `ExpeditionBottomBar` provides `BACKPACK`, `MED`, and `EXTRACT`. `OverseerScreen` displays the 3-tier mission contracts directly (launching `MissionScreen` for scout selection) and a 2×2 hub deck (`CharactersScreen`, `WeaponsScreen`, `ChallengesScreen`, `FacilityScreen`); `MarketScreen` and `StashScreen` remain hidden/standby. |
| **Mobile Frame & Auto-Follow Camera** | Web runs on Chrome wrap the app in a `420×860` mobile-proportioned frame; `ExpeditionScreen` smoothly auto-pans the camera to follow the scout as they move between rooms and floors. |

---

## 3. Architecture & Layer Import Rules

```
lib/
├── core/                        # Design tokens & themes (pixel_theme.dart, app_theme.dart)
├── data/                        # Static datasets (game_database.dart, banter_database.dart, vault_archive/)
├── domain/                      # Pure Dart models (models.dart, vault_models.dart)
├── engine/                      # Core logic & controllers (banter_engine.dart, building_generator.dart, bunker_manager.dart, combat_engine.dart, exploration_controller.dart, engine.dart)
└── presentation/
    ├── bunker/                  # OverseerScreen, MissionScreen, CharactersScreen, WeaponsScreen, ChallengesScreen, FacilityScreen (MarketScreen, StashScreen hidden/standby)
    ├── screens/                 # ExpeditionScreen
    └── widgets/                 # HUD/sheets (pixel_hud.dart, expedition_bottom_bar.dart, backpack_sheet.dart)
        ├── room/                # 2D room scene & combat overlays (pixel_room_view.dart, room_interior_content.dart, etc.)
        └── terminal/            # Reusable CRT widgets (terminal_container.dart, terminal_button.dart, item_grid_card.dart, event_modal.dart)
```

- **`domain/` Purity:** Pure Dart only (`dart:*` and sibling `domain/` files). Never import Flutter, `engine/`, `data/`, or `presentation/`.
- **`data/` Purity:** Static datasets (loot, enemies, lore, dialogue strings) importing only `dart:*` and `domain/`. Never hardcode large dialogue/content pools inside `engine/` or `presentation/`.
- **`engine/` Purity:** Never import `presentation/`, `package:material_ui/`, or `package:flutter/widgets.dart`. Pure engines (`BanterEngine`, `BuildingGenerator`, `CombatEngine`) use `dart:*`, `domain/`, and `data/` only; reactive controllers (`ExplorationController`, `BunkerManager`) may import `package:flutter/foundation.dart` solely for `ChangeNotifier`.
- **`presentation/` Modularity:** Keep presentation files modular (<400 lines target); group widgets by domain (`room/`, `terminal/`, `bunker/`) and split oversized screens/widgets when touched.
- **Test Integrity & Verification Gate:** Support seeded RNG for deterministic engine tests. Never use `skip:` or weaken assertions to pass tests. Before concluding any code change, run `flutter analyze` (0 issues) and `flutter test` (100% passing).
