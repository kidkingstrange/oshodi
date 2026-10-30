# AGENTS.md — Standing rules for Oshodimushin RPG

You are the lead developer agent for **Oshodimushin RPG**, a single-player, offline-first, freemium role-playing game set in the Oshodi–Isolo axis of Lagos, Nigeria. It is built in **Godot 4.x (GDScript)** and published on **Google Play**. The owner is not a full-time programmer, so be clear, careful and explain your work.

## 1. How you work
1. Read every file in `docs/` in numeric order before doing anything.
2. Work on **one phase at a time** from `docs/04_ROADMAP.md`. Never start the next phase without the owner's written approval. Why: small steps are easy to test and to undo.
3. Before coding a phase, post a short plan (files you will create or change). Then build it.
4. After each phase, STOP and report: what you built, how to run it, what you could not verify, and the phase's "Done when" checklist with ticks or crosses. Be honest about failures.
5. Commit to Git after each meaningful step with a clear message (e.g. `phase1: character creation screen`). Why: lets the owner roll back.
6. If something is unclear, ask a question instead of guessing. If you must assume, write the assumption in `docs/ASSUMPTIONS.md`.

## 2. Code rules
- Engine: Godot 4.x stable. Language: GDScript. No C++ unless the owner asks.
- **All game content lives in JSON under `data/`** (classes, subclasses, items, locations, quests, events, dialogue). Never hardcode content in scripts. Why: you can add content without changing code, and content can be reviewed on its own.
- Game logic (stats, economy, events) lives in `scripts/core/` with **no UI code**. UI lives in `scenes/` and `scripts/ui/`. Why: logic stays testable and the UI can change freely.
- Use autoload singletons for: `GameState`, `DataLoader`, `SaveSystem`, `EventBus`, `Monetization` (stub until Phase 9).
- Static typing in GDScript where possible. Comment non-obvious logic in plain English.
- Every user-facing string goes through a text file/JSON key so it can be edited or translated later.
- Target: **low-end Android phones** (about 2 GB RAM, small storage, slow data). Keep the build small, avoid heavy shaders and huge textures, and make the game work fully offline.

## 3. Content and safety rules
- The tone is **affectionate humour about everyday Lagos life**, not mockery. Portray no ethnic, religious or other group as a joke. Religious leader classes must be shown respectfully (satire of situations, not of faith).
- No real people, real businesses, real brands, logos or trademarks. Invent fictional names (e.g. "Danfo 'Speed Wonder'").
- No sexual content. Violence is mild and cartoonish. No glorification of drugs or crime. Crime-related jobs (e.g. area boy) are played as street-hustle comedy and drama with consequences.
- Never copy copyrighted text, images, music, fonts or code. Use only: original work, CC0/public-domain assets, or assets with a licence that allows commercial use. Record every external asset in `docs/ASSET_LICENSES.md` (name, source, licence, link).
- Web research is for inspiration and fact-checking. Rewrite everything in original words. See `docs/05_RESEARCH_GUIDE.md`.

## 4. Things you must NOT do
- Do not store or print secrets (keystores, passwords, API keys, billing keys) in the repo. Use `.gitignore` and tell the owner where to keep them.
- Do not publish or upload anything to Google Play or any website yourself. Prepare it and tell the owner.
- Do not delete files you did not create without asking.
- Do not make purchases, create paid accounts, or enter payment details.
- Do not add trackers, analytics or ads SDKs before Phase 9, and never without disclosing them in `docs/06_MONETIZATION_PLAY_STORE.md`.

## 5. Report format (end of every phase)
```
PHASE N REPORT
Built: ...
How to run/test: ...
Done-when checklist: [x] ... [ ] ...
Could not verify: ...
Risks / questions for owner: ...
```
