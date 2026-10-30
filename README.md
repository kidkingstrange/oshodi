# Oshodimushin RPG

A single-player, offline-first life-sim RPG set in the vibrant Oshodi–Isolo axis of Lagos, Nigeria. Built with **Godot 4.x** (GDScript) targeting Android and desktop platforms.

---

## Prerequisites

1. **Godot Engine 4.x (stable)**: Download from [godotengine.org](https://godotengine.org/).
   - Recommended: Godot 4.2+ or 4.3 (Standard 64-bit version).
2. **Android Studio & OpenJDK 17** (only needed later in Phase 8 for Android APK/AAB export).

---

## How to Open and Run the Project

### Option A: Via the Godot Editor
1. Launch **Godot Engine**.
2. Click **Import** in the Project Manager.
3. Browse to this directory (`c:\Users\david\OneDrive\Desktop\oshodi RPG\`) and select `project.godot`.
4. Click **Import & Edit**.
5. Press **F5** (or the **Play** button in the top-right corner) to run the game.
   - The game launches directly into `res://scenes/main_menu.tscn`.
   - The viewport is configured for 720×1280 portrait mode (desktop preview window scales cleanly to 360×640).

### Option B: Via Command Line (if Godot is on your PATH)
```bash
godot --path .
```
Or to run the Main Menu scene directly:
```bash
godot --path . res://scenes/main_menu.tscn
```

---

## Project Structure

```
oshodimushin-rpg/
├─ AGENTS.md                 # Standing engineering and content rules
├─ docs/                     # Specifications, roadmaps, research notes, licenses
│  ├─ 00_START_HERE.md
│  ├─ 01_GAME_DESIGN.md
│  ├─ 02_TECH_SPEC.md
│  ├─ 03_DATA_SCHEMAS.md
│  ├─ 04_ROADMAP.md
│  ├─ 05_RESEARCH_GUIDE.md
│  ├─ 06_MONETIZATION_PLAY_STORE.md
│  ├─ ASSUMPTIONS.md
│  ├─ ASSET_LICENSES.md
│  └─ research/
├─ data/                     # Content JSONs (classes, subclasses, items, quests, etc.)
├─ scenes/                   # Godot .tscn scenes (main_menu, hub, situation, etc.)
├─ scripts/
│  ├─ core/                  # Pure game logic (no UI dependencies)
│  ├─ ui/                    # UI controller scripts
│  └─ autoload/              # Global singletons (GameState, DataLoader, SaveSystem, etc.)
├─ assets/                   # Textures, audio, and fonts
├─ tests/                    # Test scenes and unit test scripts
└─ export/                   # Export presets and build configs (NO credentials)
```

---

## Development Roadmap Status
- **Phase 0 (Project Setup)**: Complete. Clean Godot 4 project, autoload singletons, Main Menu scene, docs structure, and Git setup.
- **Phase 1 (Data Layer & Character Creation)**: Pending owner review and kickoff.
