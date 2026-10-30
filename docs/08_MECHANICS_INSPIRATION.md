# 08 — Mechanics Inspiration (original redesigns)

## Purpose and rules
Progression-fantasy RPGs (the "ordinary person quietly becomes legendary" genre) share common game systems. This file redesigns those general systems for Oshodimushin RPG using original names, Lagos settings and original stories.

**Hard rules for the agent:**
1. Mechanics are free to use; **stories, characters, names, skill names, items and scenes from any specific book, comic, game or show are not.** Do not copy or closely imitate any specific work's plot, characters or terminology.
2. Do not research or reproduce any specific series. If a design here reminds you of a known work, change the names and structure until it is clearly its own.
3. All stories, NPCs and quest chains are written fresh, using `05_RESEARCH_GUIDE.md`.
4. Every mechanic below is built in the phase noted, data-driven (JSON), and tuned in `economy.json` or its own data file.

---

## M1. Underdog Snowball (Phases 2–4)
**Idea:** the player starts poor and overlooked; small wins compound into neighbourhood fame.
- Start: low Naira, low Respect, 1 job slot, no perks.
- **Momentum** (0–5): each success in a row adds +1; a failure resets to 0. Momentum adds a small bonus to checks and income.
- **Breakthrough events:** when Respect crosses set thresholds (10, 25, 50, 100), a one-time story Situation fires and unlocks a perk, a new location or a new activity.
- *Why:* gives a steady feeling of rising, which keeps players returning.
- Data: `momentum` rules in `economy.json`; thresholds in `progression.json`.

## M2. Hidden Classes and Secret Unlocks (Phase 7)
**Idea:** some subclasses and legendary classes are never shown in the menu; they appear when hidden conditions are met.
- Each hidden class has a `hidden_unlock` block: conditions (flags, stats, repeated behaviours, quest chain completed, days played in a role).
- Examples (original): **The Iyaloja** unlocks after 60 days as a Trader with high Respect, zero cheating flags and a completed "Market Peace" quest chain. **The Baale** unlocks after resolving 10 community disputes fairly.
- Discovery: a cryptic **rumour** NPC line hints at it; the **Street Journal** (collection log) shows "???" slots.
- *Why:* mystery and replay value.
- Data: `hidden_unlock` fields in `subclasses.json` and a `legendary_classes.json` file.

## M3. Craft and Repair Quality Tiers (Phase 4–7)
**Idea:** work output has a quality grade that affects price and reputation.
- Tiers: **Rough, Fine, Excellent, Masterwork.** Quality = skill + care (extra time/Energy) + materials + a small luck roll.
- Applies to: Mechanic and Generator Repairer repairs, Mama Put dishes, Tailor-style items, Trader goods grading.
- **Masterwork** creates a "talk of the street" flag that boosts Respect and attracts better customers.
- Optional **Signature Work**: the player names one masterwork; NPCs reference it later.
- Data: `crafting.json` (recipes, materials, tier thresholds, price multipliers).

## M4. Skills That Grow With Use and Branch (Phase 4)
**Idea:** skills improve by doing, then specialise.
- Each skill (Haggling, Driving, Preaching, Fixing, Negotiating, Street Awareness) has XP that rises with use.
- At skill levels 3 and 7 the player picks a **specialisation** (e.g. Haggling → "Bulk Deals" or "Sweet Talk").
- Skill choices affect Situation options, so builds feel different.
- Data: `skills.json` (id, xp_curve, branches, effects).

## M5. Set Bonuses and Gear Synergies (Phase 6)
**Idea:** items work better together.
- Item sets (e.g. "Market Day": apron, scale, umbrella) give bonuses at 2/3 pieces.
- Items have **traits** (durable, lucky, flashy) that interact with Situations.
- Cosmetic sets also act as Play Store packs (cosmetic only; see `06`).
- Data: `item_sets.json`.

## M6. Reputation Titles (Phases 4–6)
**Idea:** earned titles change how NPCs treat you and give small perks.
- Titles come from actions, not purchases: e.g. "Fair-Price Mama", "Never Late Driver", "Peacemaker".
- One equipped title gives a small bonus; others show on the profile.
- NPCs call you by your title in dialogue; some Situations only appear with a given title.
- Data: `titles.json` (conditions, perk, flavour text). Keep all titles original.

## M7. Chain Quests with Branching Consequences (Phases 6–7)
**Idea:** long quest chains where earlier choices change later options.
- Quests store `flags`; later steps check them. Consequences can appear days later (a favour returns, a grudge resurfaces).
- Show a **Consequence Log** so the player sees the effect of past choices.
- Data: `quests.json` with `requires_flags` and `sets_flags`.

## M8. Rivals and Mentors (Phase 6)
**Idea:** recurring NPCs who shape the story.
- 1 rival and 1 mentor per class, fictional and original. The rival progresses in parallel; the mentor offers training Situations and a final trial.
- Relationship meter (−10 to +10) changes dialogue and available help.
- Data: `npcs.json` with `relationship` fields.

## M9. Showdowns (Phases 4, 7)
**Idea:** class milestones culminate in a multi-step Situation chain, like a boss fight made of choices.
- 3–5 linked Situations, each with checks, with a shared "pressure" bar. Win by keeping pressure below a limit.
- Examples (original): the Market Dispute Hearing, the Bus-Park Election, the Flood Night Rescue.
- Reward: class level, title, a hidden unlock clue.
- Data: `showdowns.json` referencing `situations.json`.

## M10. Daily Contracts and Weekly Events (Phases 6, 9)
**Idea:** short goals and local events create habit loops that work offline.
- 3 daily contracts per class (e.g. "Sell 20 sachets of pure water", "Complete 3 routes without a fine").
- Weekly **Street Events** (e.g. Sallah market rush, rainy-season flooding, election week) change prices and Situations.
- Rewarded-ad doubling of a contract reward is allowed (capped), never required.
- Data: `contracts.json`, `weekly_events.json`.

## M11. Collection Log: The Street Journal (Phase 6)
**Idea:** a log of discoveries that rewards curiosity.
- Tracks NPCs met, locations found, items crafted, titles earned, Situations seen, and hidden-class clues.
- Completion percentages give small permanent perks (New Game+ "Street Rep").
- Data: derived from existing ids; `journal.json` for display text.

## M12. Risk and Reward Gambles (Phase 4)
**Idea:** optional high-risk choices with big upside.
- Some Situations offer a "risky route" (more Naira, more Heat or Energy cost). Insurance-style items reduce downside.
- Failure never ends the game; it creates a story consequence.
- Data: `risk` field in Situation options (`success_multiplier`, `fail_penalty`).

## M13. Apprenticeship and Teaching (Phase 7)
**Idea:** later in the game the player trains an apprentice NPC who runs a stall, route or shop and sends passive income.
- Apprentice quality depends on how the player treated them (Respect and relationship).
- Teaches a social, non-violent growth loop that fits mundane jobs.
- Data: `apprentices.json`.

---

## Implementation order for the agent
1. M1, M4, M6 with the core loop (Phases 2–4).
2. M3, M5, M12 with crafting and the shop (Phases 4–6).
3. M7, M8, M10, M11 with content expansion (Phase 6).
4. M2, M9, M13 with classes and legendary content (Phase 7).

## Done-when checks for any mechanic
- [ ] Fully data-driven; no hardcoded content.
- [ ] Has at least one original, Lagos-flavoured example in the data.
- [ ] Unit tests cover its core rule with a seeded RNG.
- [ ] Explained in a one-line tooltip in the UI.
- [ ] Works fully offline and never requires a purchase.
- [ ] Names, text and stories contain nothing copied from any existing work.
