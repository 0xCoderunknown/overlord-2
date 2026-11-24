# OVERLORD 2 // Agent Constitution & Engineering Rules (`AGENTS.md`)

> **MANDATORY CONTEXT FOR ALL AI AGENTS**  
> Read this file **first** before planning, analyzing, or modifying any code.  
> This project is **100% AI-developed and AI-maintained**. Prioritize clean layer boundaries, deterministic tests, and maintainability over rushed shortcuts.  
> **App:** Overlord 2 (2D Pixel-Art Building Expedition Crawler)  
> **Tech Stack:** Flutter / Dart `^3.14.0` / `material_ui` / `ChangeNotifier` (100% Offline)  
> **Docs:** `docs/DESIGN_DOCUMENT.md` | `docs/BESTIARY_AND_LOOT.md` | `docs/OVERLORD_IMPORT_MANIFEST.md`

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
5. **Git, Versioning & Changelog Hygiene:**
   - **Explicit User Trigger Only:** Never autonomously `git commit`, `git push`, deploy, or bump versions in `pubspec.yaml`, `CHANGELOG.md`, or `README.md` unless explicitly commanded.
   - **Descriptive Commit Headlines:** Never use version tags (e.g. `feat(vX.Y.Z)`) or dump changelogs into commit titles. Summarize the actual features or fixes added.
   - **Player-Facing Changelog Only:** Keep `CHANGELOG.md` focused on gameplay, UI, and content changes—never log internal refactors, line counts, or test runs.

---

## 2. Core Gameplay Invariants

| Invariant | Rule |
|---|---|
| **Fog of War & Backtracking** | Unexplored rooms stay blacked out. Clearing a room reveals adjacent outlines; cleared rooms unlock free back-and-forth traversal to reach elevators. |
| **Vertical Transit** | Designated elevator shafts connect floors vertically for ascending/descending multi-story facilities. |
| **Mandatory Auto-Battler & Death Cadence** | 1v1 duels auto-resolve with 1.0s pre-strike announcements. Defeated units freeze 0.5s at 0 HP, lie rotated $90^\circ$ on the floor for 1.0s, then become a searchable scrap pile. |
| **Emergency Heal Gating** | Medkit healing is strictly locked until Scout HP drops to $\le 25\%$ max vitality. |
| **Scrap Pile & Salvage** | Defeated enemies spawn searchable scrap piles; discovered gear can be equipped (auto-scrapping old gear) or scrapped for currency. |
| **Bunker Meta-Layer & Requisition** | Overseer Hub (`MarketScreen`, `StashScreen`, `FacilityScreen`) manages Caps, 50-slot storage, and Medbay Medkit synthesis before expeditions. |

---

## 3. Architecture & Layer Import Rules

```
lib/
├── core/                        # Design tokens & themes (pixel_theme.dart, app_theme.dart)
├── data/                        # Static datasets (game_database.dart, vault_archive/)
├── domain/                      # Pure Dart models (models.dart, vault_models.dart)
├── engine/                      # Core logic & controllers (building_generator.dart, bunker_manager.dart, combat_engine.dart, exploration_controller.dart, engine.dart)
└── presentation/                # Bunker screens, expedition screen, terminal & room widgets
```

- **`domain/` Purity:** Pure Dart only (`dart:*` and sibling `domain/` files). Never import Flutter, `engine/`, `data/`, or `presentation/`.
- **`data/` Purity:** Static datasets importing only `dart:*` and `domain/`.
- **`engine/` Purity:** Never import `presentation/`, `package:material_ui/`, or `package:flutter/widgets.dart`. Pure engines (`BuildingGenerator`, `CombatEngine`) use `dart:*`, `domain/`, and `data/` only; reactive controllers (`ExplorationController`, `BunkerManager`) may import `package:flutter/foundation.dart` solely for `ChangeNotifier`.
- **`presentation/` Modularity:** Keep presentation files modular (<400 lines target); split oversized screens or widgets into dedicated sub-widgets when touched.
- **Test Integrity & Verification Gate:** Support seeded RNG for deterministic engine tests. Never use `skip:` or weaken assertions to pass tests. Before concluding any code change, run `flutter analyze` (0 issues) and `flutter test` (100% passing).
