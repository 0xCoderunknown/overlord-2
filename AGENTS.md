# OVERLORD 2 // Autonomous Agent Constitution & Guardrails (`AGENTS.md`)

> **MANDATORY CONTEXT FOR ALL AI AGENTS & CODING ASSISTANTS**  
> Read this file **first** before planning, analyzing, or modifying any code in this repository.  
> The human user is the **Strict Product Manager (PM) / Vault Overseer**. You are the **Senior Clinical & Game Systems Architect**.  
> **App:** Overlord 2 (2D Pixel-Art Building Expedition Crawler)  
> **Tech Stack:** Flutter 3.50+ / Dart 3.14+ / Provider / SharedPreferences (100% Offline)  
> **Design Ref:** `docs/DESIGN_DOCUMENT.md`

---

## 🏛️ 1. Project Manifesto & Core Directives

**Overlord 2** is a 2D side-cutaway pixel-art building dungeon crawler inspired by *Fallout Shelter's* quest/exploration loops and *Dead Cells'* gritty pixel aesthetics. Players send a squad to explore multi-story ruined facilities room-by-room, discovering loot, fighting adversaries, and traversing elevators/stairs floor-by-floor.

All autonomous agents modifying or expanding this codebase **must strictly honor these directives**:

1. **100% Offline & Privacy Pledge:**
   - **Never** introduce remote network dependencies (`http`, `dio`, analytics SDKs, crashlytics, remote telemetry, or ad networks).
   - **Never** use Google Fonts runtime network downloads. Monospace typography uses the built-in system font family (`'monospace'`).
   - **Never** declare internet permissions in Android build configurations.
2. **Authentic Pixel & Retro Aesthetic:**
   - Crisp pixel art rendering with `FilterQuality.none`.
   - Side-cutaway building rooms with distinct states: `unrevealed` (fog of war), `outline` (discovered/adjacent), `active` (team present), `cleared`.
   - CRT / retro atmospheric details preserved through theme tokens.
3. **Execution & Web Environment:**
   - Web development and test target is strictly **Google Chrome** (`flutter run -d chrome`).
4. **Git Push Protocol:**
   - **Never push to remote Git repositories automatically.** Only commit locally when work is verified, and push to remote ONLY when explicitly requested by the user.
4. **Mandatory Indian Date Format (`DD-MM-YYYY`):**
   - **All dates displayed in UI, terminal logs, changelogs (`CHANGELOG.md`), and markdown documentation MUST strictly use Indian numerical date formatting (`DD-MM-YYYY` or `DD-MM-YY`).**
   - Never use `YYYY-MM-DD` or `MM/DD/YYYY` in human-facing text or documentation.

---

## ⚖️ 2. Core Gameplay Invariants (Overlord 2)

| Invariant | Concept | Rule |
|---|---|---|
| **Room Fog of War** | Room Discovery | Unexplored rooms stay blacked out; adjacent rooms show outlines when current room is cleared. |
| **Tap-to-Move & Forward-Only** | Traversal | Tapping an outlined adjacent room advances the scout. Once entered, previous rooms lock. |
| **Vertical Transit** | Stairs & Elevators | Found in designated rooms; allows moving between floors (ground, upper levels, sub-basements). |
| **Scrap Pile System** | Loot Resolution | Defeated hostiles transform into searchables scrap piles (1 drop max for grunts, jackpot for bosses). |
| **Paid Requisition** | Loadout Economy | Unlocked high-tier weapons cost upfront Gold to deploy. High firepower balances against mission payout margins. |
| **1v1 Tactical Combat** | Combat Pacing | 1-on-1 duels keeping turns snappy and mobile-friendly (<5 min runs). |

---

## 🏗️ 3. Architecture & Codebase Topology

```
lib/
├── core/                        # Design tokens, theme, audio/haptic stubs, constants
├── data/                        # Static datasets (room templates, enemy profiles, loot tables)
├── domain/                      # Models (Building, Floor, Room, Squad, Member, Item, Enemy)
├── engine/                      # Core logic (BuildingGenerator, TraversalEngine, CombatEngine)
├── presentation/                # Game views, canvas painters, room widgets, HUD
└── utils/                       # Helpers (RNG, date formatting, math)
docs/
├── DESIGN_DOCUMENT.md           # Core game design blueprint
└── MASTER_BACKLOG.md            # Feature roadmap & tracker
```

### Code Granularity & Quality
- **Strict Line Limit:** Keep presentation and screen files strictly under **400 lines of code**. Extract reusable components into dedicated widgets.
- **RNG Determinism:** Support seeded RNG for testing building generation and combat resolution.

---

## 🛑 4. Codebase Red Lines (Instant Failure Conditions)

- ❌ **Violating the 100% Offline Pledge** (Adding `http`, `dio`, analytics, Firebase, ad networks, or network permissions).
- ❌ **Adding presentation files exceeding 400 lines.**
- ❌ **Using non-Indian date formats (`YYYY-MM-DD` or `MM/DD/YYYY`) in changelogs or markdown documentation.** (Must use `DD-MM-YYYY`).
- ❌ **Pushing to remote Git repositories without explicit user instruction.**
- ❌ **Failing static analysis or breaking automated tests.**
