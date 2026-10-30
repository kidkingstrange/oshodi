# 02 — Technical Specification

## 1. Stack and why
| Choice | Why |
|---|---|
| **Godot 4.x (stable)** | Free, light, exports to Android easily, good 2D UI tools |
| **GDScript** | Simple, fast to write, ideal for an agent and a non-expert owner |
| **JSON data files** | Content separated from code; easy to review and expand |
| **Git + GitHub (private repo)** | Safe history and rollback |
| **Android export (AAB for Play, APK for testing)** | Google Play requires AAB for new apps |

## 2. Project structure
```
oshodimushin-rpg/
├─ AGENTS.md
├─ docs/                 (this pack + research/ + ASSUMPTIONS.md + ASSET_LICENSES.md)
├─ data/                 (JSON content: classes, subclasses, items, locations, quests, events, dialogue, economy)
├─ scenes/               (.tscn: main menu, character creation, hub, situation, shop, settings)
├─ scripts/
│  ├─ core/              (game logic, no UI)
│  ├─ ui/                (UI controllers)
│  └─ autoload/          (GameState, DataLoader, SaveSystem, EventBus, Monetization)
├─ assets/               (art, audio, fonts — only licensed/original)
├─ tests/                (simple test scenes/scripts for core logic)
└─ export/               (export presets; NO keystores in repo)
```

## 3. Architecture rules
1. **DataLoader** reads all JSON at startup, validates it against `docs/03_DATA_SCHEMAS.md`, and reports clear errors (file, id, field). Why: bad content should fail loudly, not crash mid-game.
2. **GameState** holds the player (stats, resources, class, inventory, flags, day/time). It is the single source of truth.
3. **EventBus** (signals) connects logic to UI so they stay decoupled.
4. **SituationResolver** (core) takes a Situation + GameState and returns an outcome. No UI inside. It must be unit-testable with a seeded random number generator so tests are repeatable.
5. **SaveSystem** writes JSON to `user://saves/slot_N.json` with a `save_version` number and a migration function. Why: updates to the game must not break old saves.
6. **Monetization** is an interface with a stub implementation (always "no ads, nothing purchased") until Phase 9. Why: the game logic stays clean and testable offline.

## 4. UI/UX requirements
- Portrait orientation, one-handed play, minimum touch target 48 dp (about 9 mm).
- Base design resolution 720×1280 using Godot's `canvas_items` stretch mode and `expand` aspect. Test on multiple aspect ratios.
- Text-forward UI: large readable fonts, high contrast, light/dark friendly.
- Every screen reachable with Back button behaviour that matches Android conventions.
- Settings: sound, music, text size, language (English, Pidgin-flavoured English), data/ads preferences, delete save.

## 5. Performance and size budgets
- Target devices: ~2 GB RAM, Android 8.0+ (verify current Godot minimum and Play target API requirements before release).
- APK/AAB under **100 MB** (aim under 50 MB). Compress textures, use short audio loops (OGG), avoid large fonts.
- Stable 30+ FPS on low-end phones; no per-frame heavy allocation.
- Cold start under 5 seconds.

## 6. Android export steps (done in Phase 8; agent prepares, owner confirms)
1. Install Android export templates from the Godot editor (Editor → Manage Export Templates). Why: Godot cannot export without them.
2. Set the Android SDK and JDK paths in Editor Settings.
3. Create an export preset "Android" with package name `com.<owner>.oshodimushinrpg` (owner chooses), version code 1, version name `0.1.0`, min SDK per current Godot defaults, target SDK per current Google Play requirement.
4. Enable **Use Gradle Build** (needed for plugins and AAB output).
5. Create a **debug keystore** for testing. Create the **release keystore** ONLY with the owner, who stores it and its password safely off the repo. Why: losing the upload key is painful; leaking it is a security risk.
6. Export an APK, install on a real phone, test. Then export an AAB for Play.
7. Use **Play App Signing** when creating the app in Play Console.

## 7. Testing
- Core logic tested with scripts in `tests/` (stat checks, economy, save/load round-trip, schema validation).
- Manual test checklist per phase in the roadmap.
- Final: test on at least 2 real low-end Android devices.

## 8. Plugins (Phase 9 only; verify current versions and Godot compatibility first)
- Google Play Billing: the official/maintained Godot Google Play Billing plugin for Godot 4.
- AdMob: a maintained Godot 4 AdMob plugin.
Agent must confirm each plugin works with the Godot version in use, read its licence, and note setup steps. If a plugin is unmaintained or incompatible, stop and report options.
