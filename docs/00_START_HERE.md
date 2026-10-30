# 00 — START HERE (How to use this pack with Antigravity)

## Files in this pack, in the order the agent must read them
1. `AGENTS.md` — standing rules the agent follows at all times
2. `01_GAME_DESIGN.md` — what the game is
3. `02_TECH_SPEC.md` — how it is built (Godot 4, GDScript, Android)
4. `03_DATA_SCHEMAS.md` — the JSON formats for all game content
5. `04_ROADMAP.md` — the phases, step by step (the agent works one phase at a time)
6. `05_RESEARCH_GUIDE.md` — what to research online and how
7. `06_MONETIZATION_PLAY_STORE.md` — ads, purchases, publishing

## Setup (you do this once)
1. Install **Godot 4.x (stable)** from godotengine.org. Why: the agent writes code, but the Godot editor is what builds and exports the game.
2. Install **Android Studio** (for the Android SDK) and **OpenJDK 17**. Why: Godot needs them to export Android builds.
3. Create an empty folder `oshodimushin-rpg` and open it in Antigravity as the workspace.
4. Copy ALL files from this pack into the folder root (put `AGENTS.md` in the root; put the others in a `docs/` folder).
5. If Antigravity has a "Rules" or "Workflows" panel, paste the contents of `AGENTS.md` there too. Why: rules in the panel are loaded automatically for every task.
6. Initialise Git (`git init`) and make a private GitHub repo. Why: lets you undo any agent mistake.

## How to run the work
- Paste the kickoff prompt (see below) into the Antigravity agent.
- The agent does **one phase** from `04_ROADMAP.md`, then stops and reports.
- You open the project in Godot, run it, and check the "Done when" list.
- If it passes, tell the agent: "Phase N approved. Start Phase N+1."
- If it fails, paste the error or describe the problem and ask it to fix it before moving on.

## Kickoff prompt
```
Read AGENTS.md and every file in docs/ in numeric order. Then do Phase 0 of docs/04_ROADMAP.md only. When finished, stop, summarise what you did, list anything you could not verify, and wait for my approval before starting Phase 1.
```
