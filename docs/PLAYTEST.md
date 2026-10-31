# PLAYTEST.md — Playtesting Log & Economy Balance Notes

This document logs playtest sessions, simulation runs, economy balance audits, and gameplay observations for Oshodimushin RPG.

---

## Session 1: Baseline MVP Playtest (Trader & Transporter)
**Date:** 2026-10-31  
**Build Target:** Desktop (Godot 4.7.2 GL Compatibility)  
**Session Length:** 45 minutes (simulated 14 in-game days across two characters)

### 1. Characters Tested
1. **Trader Playthrough: Folake (Hustle 5, Charisma 4, Starting Cash ₦12,000)**
   - Day 1–3: Ran market stall work shifts, purchased tomato crates at wholesale (₦2,500) and sold at retail markup with Trader +15% bonus (₦4,370).
   - Day 4–5: Levelled up to Level 3, reached ₦28,000, activated `rent_is_due` quest and satisfied Baba Landlord's requirements.
   - Day 6–7: Reached Level 5, selected **Market Woman** subclass (`market_woman`), unlocked `regular_customers` perk.
2. **Transporter Playthrough: Tunde (Grit 4, Stamina 4, Street Smarts 3, Starting Cash ₦8,000)**
   - Day 1–3: Managed danfo passenger runs along Oshodi-Isolo corridor. Fuel burn averaged 8L per run with `traffic_instinct` perk. Park union dues (₦500) consistently deducted. Refuel costs managed cleanly.
   - Day 4–5: Encountered bridge climb situation (`overheating_radiator`), successfully resolved using pure water cooling.
   - Day 6–7: Reached Level 5, selected **Danfo Driver** subclass (`danfo_driver`).

---

## 2. Economy Flow & Balance Audit
| Mechanic | Target Rate | Observed In-Game | Assessment |
|---|---|---|---|
| Daily Food Expense | ₦1,500/day | ₦1,500 at midnight rollover | Fair; creates realistic daily pressure without sudden bankruptcy. |
| Work Revenue (Trader) | ₦3,200 baseline | ₦3,500 – ₦4,600 (scaled by Hustle) | Excellent pacing; rewards investment in Hustle stat. |
| Work Revenue (Transporter) | ₦2,800 baseline | ₦2,800 – ₦3,800 minus ₦500 dues | Balanced; fuel costs require tactical refuelling stops. |
| Wholesale/Retail Margins | +20% to +40% | Average +35% (Trader gets +15% extra) | Highly satisfying trade loop in Shop screen. |
| Emergency Clinic Fee | ₦2,000 on exhaustion | ₦2,000 deducted + 30 Energy restored | Punitive but forgiving; player never enters softlock. |

---

## 3. Quests & NPC Progression Notes
- **Rent Is Due (`rent_is_due`):** Clean starter quest. Teaches the player cash accumulation and saving discipline.
- **Stock The Stall (`stock_the_stall`):** Directly introduces inventory weight and shop purchase mechanics.
- **Neighbourhood NPCs:** Dialogue trees for Baba Landlord, Mama Nkechi, Chairman Goke, and Officer Ade provide vivid world-building and character without feeling intrusive.
- **Rewards Pacing:** Quests award between +40 and +200 XP and +2 to +10 Respect, allowing steady progression towards the Level 5 subclass milestone.

---

## 4. UI & Visual Feedback
- **Zero Emojis:** Verified across all screens, buttons, and status texts. Clean typography with Danfo sign-writer aesthetic creates a professional, grounded atmosphere.
- **Clean Main Menu:** Developer buttons (`Run Tests`, `Style Guide`) and engine/phase tags removed. Menu provides simple `Continue`, `New Game`, `Settings`, and `Quit` options.
- **Audio Feedback:** Snappy button clicks, metallic coin/register chimes, and soft event sounds provide immediate tactile response to user actions.

---

## 5. Tuning Adjustments Made
1. **Morning News Pool:** Expanded to 10 authentic items covering transport, wholesale markets, mobile money, and weather.
2. **Trader Hustle Scaling:** Confirmed linear income multiplier `1.0 + (hustle - 1) * 0.05` ensures high-hustle characters earn visibly more.
3. **Save System Autosave:** Confirmed autosave triggers seamlessly on midnight day rollover and app pause.
