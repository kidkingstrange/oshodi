# 04 — Roadmap (one phase at a time)

For every phase: post a plan first, build, test, commit, then deliver the report from AGENTS.md and **stop for owner approval**. Each step lists the "why".

---
## Phase 0 — Project setup
**Goal:** a clean, runnable empty Godot project with the structure and docs.
1. Create the Godot 4 project and the folder structure from `02_TECH_SPEC.md`. *Why: everything later depends on a consistent layout.*
2. Create `.gitignore` (Godot cache, `*.keystore`, `*.jks`, `export_credentials.cfg`, `.import` if applicable). *Why: keeps secrets and junk out of Git.*
3. Add the autoload singletons as empty scripts. *Why: later phases plug into them.*
4. Create `docs/ASSUMPTIONS.md` and `docs/ASSET_LICENSES.md` (empty templates).
5. Write a README with how to open and run the project.
6. Create a Main Menu scene with Play, Settings, Quit placeholders.
**Done when:** project opens in Godot with no errors, runs to the main menu, files are committed.

## Phase 1 — Data layer and character creation
**Goal:** load content from JSON and let the player create a character.
1. Implement `DataLoader` with validation per `03_DATA_SCHEMAS.md`. *Why: catches content mistakes early.*
2. Create sample data: all 6 classes (names, taglines, base stats only), and subclasses for **Trader** and **Transporter** only. *Why: smallest useful content.*
3. Build the character creation screen: name, class pick (shows stats and perk), confirm.
4. Create `GameState` and fill it from creation. Show a Stats screen.
5. Write tests: loader rejects bad data; GameState initialises correctly.
**Done when:** you can start a new game, choose a class, see stats; the validator reports a deliberately broken JSON clearly.

## Phase 2 — World, time and events
**Goal:** a day cycle and a place to be.
1. Implement time blocks (morning/afternoon/evening/night) and day counter. *Why: the whole loop is built on time passing.*
2. Create the Oshodi district: 4 locations with travel costs. Hub screen shows location, time, resources.
3. Implement the activity picker (work, rest, travel, shop, socialise) that spends a time block.
4. Implement the event system: weighted random events from `events.json`, seeded RNG for tests.
5. Add daily costs (food, transport) from `economy.json`.
**Done when:** you can play several in-game days moving between locations, paying costs and seeing random events trigger.

## Phase 3 — Situations (the conflict system)
**Goal:** make choices matter.
1. Implement `SituationResolver` (stat check + modifiers + randomness). Unit tests with a fixed seed. *Why: fairness and tuning need repeatable results.*
2. Build the Situation screen (setup text, options, result text, effects shown clearly).
3. Write 20 Situations for Oshodi (10 general, 5 Trader, 5 Transporter) in original words using research notes. *Why: content is the game.*
4. Apply effects to GameState; handle Energy 0 (forced rest with a cost, not game over).
**Done when:** Situations appear in play, results are consistent with stats, and tests pass.

## Phase 4 — Class mechanics and progression
**Goal:** classes feel different.
1. Implement the **Trader** signature mechanic (stock & price) and the **Transporter** mechanic (routes, fuel, passenger mood).
2. XP, class levels, perks. Unlock subclass choice at level 5 and apply subclass perks.
3. Add the Respect and Heat systems with real consequences (e.g. high Heat triggers special events).
4. Add basic inventory and shop.
**Done when:** a Trader and a Transporter play noticeably differently; levelling and subclass choice work.

## Phase 5 — Save/load and settings
1. Implement `SaveSystem` with 3 slots, `save_version`, migration stub, autosave at day end. *Why: mobile apps get closed often.*
2. Settings screen (sound, text size, delete save, language placeholder).
3. Handle app pause/resume cleanly (save on pause).
**Done when:** you can quit mid-game and resume exactly; save round-trip tests pass.

## Phase 6 — Content expansion (MVP complete)
1. Add subclasses and 40 Situations total, 10 quests, NPCs and dialogue. Use `05_RESEARCH_GUIDE.md`.
2. Add short, original music loops and sound effects (licensed/original only, logged in `ASSET_LICENSES.md`).
3. Pass over UI polish: fonts, spacing, icons, button feedback.
4. Playtest notes in `docs/PLAYTEST.md`. Tune `economy.json`.
**Done when:** a full 30–60 minute session is fun and bug-free on desktop.

## Phase 7 — Remaining classes and legendary classes (optional after MVP)
1. Add classes 1, 2, 3, 4 (Area Boy, Working Class, Road Official, Faith Leader) one at a time, each with a signature mechanic, 6 subclasses and Situation sets. *Why: one class at a time keeps quality high.*
2. Add additional districts.
3. Design legendary classes with the owner, then implement.
**Done when:** each added class passes the same checks as Phase 4.

## Phase 8 — Android build and performance
1. Follow `02_TECH_SPEC.md` section 6 to set up export. Owner assists with keystore.
2. Export APK, test on real low-end phones. Fix touch, layout, performance and size problems.
3. Add Android back button, pause/resume, and safe-area handling.
**Done when:** the APK installs, plays smoothly and passes the checklist on two real devices.

## Phase 9 — Ads and in-app purchases
Follow `06_MONETIZATION_PLAY_STORE.md`. Implement real `Monetization` behind the existing interface, test with Google's test ads and test purchases only.
**Done when:** rewarded ad, remove-ads purchase and restore purchases work in test mode; game still works with zero connection.

## Phase 10 — Release preparation
1. Store listing assets and text drafts, privacy policy draft, Data Safety answers, content rating notes.
2. Final AAB export. Closed testing track, fix feedback, then owner submits to production.
**Done when:** the owner has everything needed to submit; nothing has been uploaded by the agent.
