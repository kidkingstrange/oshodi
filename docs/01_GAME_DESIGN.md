# 01 — Game Design Document: Oshodimushin RPG

## 1. Pitch
A single-player life-sim RPG set in the Oshodi–Isolo area of Lagos. You are an ordinary person trying to survive, earn and rise in the neighbourhood. There are no swords or dragons: your "dungeons" are traffic, bus parks, markets, light (power) cuts, landlords, and the daily hustle. Your "boss fights" are negotiations, confrontations and big risky jobs.

**Tone:** funny, warm, observant, a little dramatic. Nigerian Pidgin and Lagos English in dialogue (see research guide for accuracy).

**Why this works:** the setting is instantly familiar to the target audience, and mundane jobs are a fresh twist on RPG classes.

## 2. Core loop (one in-game day)
1. **Morning:** check Energy, Money, Heat, Respect. Read a short "street news" line.
2. **Choose an activity block:** work your job, travel, rest, socialise, side-hustle, study/train.
3. **Resolve events:** each block can trigger a random event (road blocked, customer dispute, checkpoint, power cut, neighbour drama).
4. **Evening:** spend money (food, rent, transport, fuel/light), save progress.
5. **Progress:** XP and Respect level up your class; milestones unlock subclasses and districts.

## 3. Stats
Primary (grow with levels): **Hustle**, **Street Smarts**, **Charisma**, **Stamina**, **Grit**.
Resources (change daily): **Energy** (0–100), **Naira**, **Respect** (local reputation), **Heat** (attention from authorities/rivals; high Heat has consequences).
Why these: they map onto what actually matters in the setting, so choices feel real.

## 4. Conflict system ("Situations")
Instead of combat, each challenge is a **Situation** with 2–5 options (e.g. argue, pay, flatter, run, call a friend). Outcome = stat check + a modifier from items, class perks and Respect, with some randomness. Failures cost Energy, Naira, Respect or raise Heat; they should be funny and never a hard game over. A few **Showdowns** (story climaxes) chain multiple Situations.

## 5. The six classes and their subclasses
Each class has: a signature mechanic, a passive perk, and 6 subclasses unlocked at class level 5 (the player picks one first, others unlock later).

| # | Class | Fantasy | Signature mechanic |
|---|---|---|---|
| 1 | **Area Boy** | Street muscle and influence | *Turf*: control spots to earn "levies"; high Heat risk |
| 2 | **Working Class** | The salary/skill grind | *Overtime*: steady pay, boss/boss-mood events |
| 3 | **Road Official** | Authority on the road | *Checkpoint*: stop vehicles, choose fair play vs. shortcuts; Integrity meter |
| 4 | **Faith Leader** | Community and congregation | *Congregation*: grow members, manage donations and trust |
| 5 | **Trader** | Market and hawking | *Stock & Price*: buy low, sell high, haggle |
| 6 | **Transporter** | Moving Lagos | *Route*: run routes, fuel, passenger moods, park dues |

**Subclasses (6 each):**
- **Area Boy:** Agbero (park tout), Vigilante, "One Chance" Operator (a risky-con path with strong moral consequences), Landlord's Enforcer, Pickpocket, Politician's Youth Wing
- **Working Class:** Mechanic, Factory Hand (Isolo industrial area), Bank Clerk, Security Guard, Generator Repairer, Teacher/Nurse
- **Road Official:** LASTMA Officer, Traffic Warden, Police Checkpoint Officer, Vehicle Inspector, Tow-Truck Operator, Road Safety Volunteer
- **Faith Leader:** Pastor, Imam, Prophet/Prayer Warrior, Evangelist, Usher/Choirmaster, Traditional Priest
- **Trader:** Market Woman, Pure-Water Seller, Traffic Hawker, Phone Accessories Dealer, Foodstuff Wholesaler, Mama Put
- **Transporter:** Danfo Driver, Conductor, Okada Rider, Keke Driver, Bus Park Chairman, Dispatch Rider

The agent must give each subclass: a one-line fantasy, 2 unique perks, 1 unique Situation set, and 1 weakness. Write these into `data/subclasses.json`.

*Note on sensitive roles:* "One Chance Operator", "Pickpocket" and "Traditional Priest" need careful, respectful, non-glorifying treatment. Show consequences, and for belief systems show them as part of community life without ridicule.

## 6. Legendary classes (unlock after max class level + a long quest chain)
Candidates (agent may refine, owner approves): **The Landlord** (owns half the street), **The Iyaloja** (market queen), **The Chairman** (union boss), **The Baale** (community head), **The Japa Legend** (made it abroad, returns as a myth). Each has a unique mechanic that combines two base classes. Do NOT build these until Phase 7.

## 7. World (verify details with research)
Districts to represent: Oshodi interchange and bus terminal, Oshodi market, Isolo, Ejigbo, Mafoluku, Ilasamaja, Okota, Ajao Estate, Isolo industrial area, Shogunle. Each has 3–5 sub-locations, an economy flavour, typical events and NPCs. Start the MVP with **one district** (Oshodi).

## 8. Time, economy and risk
- Day has 4 blocks (Morning, Afternoon, Evening, Night). Weekdays/weekends and "light on/off" change events.
- Prices in naira at believable, adjustable levels stored in `data/economy.json` (do not hardcode; the owner may tune them).
- Daily costs: food, transport, rent (weekly/monthly), power (generator/fuel). Falling behind creates story pressure, not game over.

## 9. Progression
Class XP → class levels → subclass unlock → district unlock → Showdowns → legendary class. Also a "Street Rep" meta-level across playthroughs (New Game+ perks).

## 10. MVP definition (what ships first)
1 district (Oshodi), 2 classes fully playable (Trader and Transporter recommended: easiest to make fun), 6 subclasses total, 40 Situations, 10 quests, save/load, English + light Pidgin, no ads or purchases yet.
