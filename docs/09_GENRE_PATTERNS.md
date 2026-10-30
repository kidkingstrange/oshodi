# 09 — Genre Patterns from Manga, Manhwa and Manhua (original redesigns)

## Purpose and rules
Popular manga, manhwa and manhua share recurring **structures and systems**. These are genre conventions, not anyone's property. This file converts them into original Oshodimushin RPG features. It extends `08_MECHANICS_INSPIRATION.md`; do not duplicate those mechanics.

**Hard rules for the agent:**
1. Use the *pattern*, never the *content*. Do not use any series' character names, skill names, terms, plots, scenes, settings or art style. If a name or structure feels recognisable, change it.
2. Do not scrape, quote or summarise specific series. Web research for this file is limited to general genre descriptions (e.g. encyclopedia-style overviews of "progression fantasy", "tournament arc", "cultivation tiers"). Treat all web results as inspiration only and verify nothing from them as fact about our game.
3. Everything is rewritten in Lagos terms, in original words, using `05_RESEARCH_GUIDE.md`.
4. All features are data-driven (JSON), offline-first, never required to pay.

*Research note for the owner:* a quick web search returned mostly low-quality pages. The patterns below therefore come from well-known, widely documented genre conventions rather than from reading any specific series.

---

## P1. Rank Ladder (A–S style tiers) → "Street Rank" (Phase 4)
**Pattern:** characters are graded on a public ladder, and rising ranks gives status and access.
**Our version:** a Street Rank per class: **Newcomer → Known → Respected → Oga → Big Name → Legend.**
- Rank gates districts, jobs, NPC dialogue and Showdowns.
- Rank is shown as a badge on the profile (Danfo Poster style, painted plaque).
- Data: `ranks.json` (id, name, requirement, unlocks).
*Why:* a clear ladder gives a constant next goal.

## P2. Daily Training and Consequences → "Daily Hustle Streak" (Phase 6)
**Pattern:** a daily routine builds power, and skipping it has a cost.
**Our version:** completing 3 contracts in a day extends a **Hustle Streak**; streak days add small, capped bonuses. Missing a day only resets the bonus. It never takes away progress. *Why:* habit without punishment, which is fair on mobile.
- Data: `streaks` rules in `economy.json`. No push notifications unless the owner approves.

## P3. The Tower / Floor Structure → "The Hustle Ladder" (Phase 7)
**Pattern:** a tall structure with escalating floors, each with its own rules and tests.
**Our version:** a repeatable challenge mode, **the Hustle Ladder**, e.g. 20 stages from "sell at one junction" to "run the whole market day". Each stage has a special rule (rainy day, power cut, checkpoint ahead) and a Situation chain.
- Rewards: cosmetics, titles, small Naira.
- Data: `ladder.json`.
*Why:* replayable content that costs little to author.

## P4. Tournament / Contest Arcs → "Neighbourhood Contests" (Phase 6–7)
**Pattern:** structured competition with brackets, rivals and rising stakes.
**Our version:** seasonal local contests: best Mama Put dish of the street, fastest danfo route, best market stall, community football league. Brackets are a series of Situations plus a mini-game scored by stats.
- Rivals appear again across rounds (see M8).
- Data: `contests.json`.

## P5. Ego/Rival Rankings → "Street Leaderboards (offline)" (Phase 6)
**Pattern:** competitors measure themselves against named rivals who rise and fall.
**Our version:** an **offline** leaderboard of fictional NPC rivals per class (earnings, Respect). The player climbs by beating NPCs' simulated progress. No online features required. *Why:* competition without servers.
- Data: `rivals.json`, simulated weekly by `core/RivalSim`.

## P6. Cultivation Realms and Bottlenecks → "Breakthrough Moments" (Phase 4)
**Pattern:** progress in tiers, with a hard "bottleneck" before each tier that needs a special effort.
**Our version:** at class levels 5, 10, 15, 20, the player faces a **Breakthrough**: gather resources, complete a short Situation chain, optionally get a mentor's help. Passing grants a tier title and a permanent perk.
- Failure costs time or Naira, not progress.
- Data: `breakthroughs.json`.

## P7. Sects, Guilds and Factions → "Associations and Unions" (Phase 7)
**Pattern:** joining an organisation gives resources, rivals and politics.
**Our version:** fictional associations (a traders' association, a drivers' union, a church committee, a community youth group, a landlords' forum). Choose one allegiance per season; each gives perks, duties and rival factions. *Why:* social structure is the real Lagos economy.
- Keep all organisations fictional. No real unions, parties or religious bodies.
- Data: `factions.json`.

## P8. Regression / Second Chance → "Fresh Start+" (Phase 6)
**Pattern:** the hero restarts with memory and knowledge from before.
**Our version:** New Game+ called **Fresh Start+**: keep Street Rep, unlocked titles and journal entries; start with an insight perk ("you know what happens on rainy Fridays"). Hidden clues from the first run can unlock secret paths.
- Data: `new_game_plus.json`.

## P9. Hidden Quests and Penalty Zones → "Odd Jobs and Dodgy Offers" (Phase 6)
**Pattern:** surprise quests appear, some with big rewards and big risks.
**Our version:** random offers from NPCs (a stranger wants a favour, a tip about a deal). Accepting can pay well or backfire in a funny, consequence-rich way. Clear cues let careful players spot bad deals. *Why:* surprise keeps sessions fresh.
- Data: `odd_jobs.json`, with `trust_clues` fields.

## P10. Party and Companions → "Your Crew" (Phase 7)
**Pattern:** a recruited team with distinct skills.
**Our version:** recruit 1–3 crew NPCs (a conductor, a bookkeeper, a runner). Crew members add Situation options, have loyalty meters, and have their own mini-quests.
- Data: `crew.json`.

## P11. Power-Level Reveal Moments → "The Whole Street Knows" (Phase 4–7)
**Pattern:** the underestimated hero reveals real ability and bystanders react.
**Our version:** at milestones, a short cinematic Situation where onlookers (NPCs from earlier) react to the player's earned reputation. Uses earlier relationships and titles so the payoff is personal.
- Data: `reveal_scenes.json`.

## P12. Skill Cards and Loadouts → "Hustle Moves" (Phase 4)
**Pattern:** limited ability slots force meaningful choices.
**Our version:** a loadout of 3–4 **Hustle Moves** (e.g. Sweet Talk, Shortcut, Call a Friend, Hold the Line). Each has cooldown or Energy cost and shapes Situation options. Moves are earned, not bought. *Why:* strategy depth without combat.
- Data: `moves.json`.

---

## Build order for the agent
1. P1, P6, P12 (core progression, Phase 4).
2. P2, P5, P8, P9 (retention and replay, Phase 6).
3. P3, P4, P7, P10, P11 (content-heavy, Phase 7).
Do not start a pattern before its roadmap phase is approved. Add each to `docs/ASSUMPTIONS.md` if you interpret it.

## Originality checklist (run before merging any content)
- [ ] No name, term, plot point or setting from any existing work.
- [ ] Reads as Lagos-specific, not a re-skin of a fantasy story.
- [ ] Mechanic works offline and is fair to free players.
- [ ] Respectful portrayal of all groups (see `AGENTS.md`).
- [ ] Logged in `docs/research/USAGE.md` if web research informed it.
