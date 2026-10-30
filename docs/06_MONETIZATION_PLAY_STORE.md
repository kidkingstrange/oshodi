# 06 — Monetization and Google Play Release

> Policies, fees and requirements change. The agent must check the **current** Google Play Console Help and Developer Policy pages before each step and tell the owner what it found. This file states intent; official pages are the authority.

## 1. Freemium principles
1. The free game must feel **complete and fair**. No hard paywalls in the first hour.
2. No pay-to-win: money never buys exclusive power over free players' progression in a way that breaks the game.
3. Ads are **opt-in and rewarded** (player chooses to watch for a benefit). No interstitials during Situations or at launch.
4. The game works **fully offline**; purchases and ads simply don't appear without internet.
5. No dark patterns (no fake countdowns, no misleading buttons, no pressure on young players).

## 2. Free vs paid
| Free | Paid (in-app purchases, via Google Play Billing) |
|---|---|
| All base gameplay, first 2 classes, first district | **Remove Ads** (one-time) |
| Rewarded ads: refill Energy, double a day's earnings (capped per day) | **Cosmetic packs**: outfits, stall/bus banners, titles |
| 1 save slot | **Extra save slots** |
| | **Class/district packs** (e.g. Faith Leader pack) that add content, not power over earned progress |
| | Optional **Supporter pack** (thank-you cosmetics) |
Prices are set by the owner in Play Console (use low naira price points; check which payment methods are available in Nigeria).

## 3. Implementation steps (Phase 9)
1. Keep the `Monetization` interface: `show_rewarded_ad(reward_id)`, `purchase(product_id)`, `restore_purchases()`, `is_owned(product_id)`, `ads_removed()`. *Why: the game talks to one clean interface; swapping providers later is easy.*
2. Install the Godot 4 compatible Google Play Billing plugin and an AdMob plugin (verify versions and licences). Add to the Android export (Gradle build enabled).
3. Use **only test ad unit IDs and licensed test accounts** during development. Never click real ads on your own device. *Why: self-clicking can get the AdMob account banned.*
4. Define product IDs in `data/products.json` (e.g. `remove_ads`, `save_slots_3`, `cosmetic_pack_1`). They must match Play Console exactly.
5. On purchase: verify, grant, **acknowledge the purchase** (required or it is refunded), and save entitlement locally. Implement **restore purchases** at start-up. *Why: players reinstall and change phones.*
6. Rewarded ad flow: show only on player tap, grant reward only on completion, cap rewards per day, handle "ad failed to load" gracefully.
7. Consent: implement Google's user messaging/consent flow where required, and respect the in-game "ads/data" setting.
8. Test: no internet, ad fails, purchase cancelled, purchase pending, app killed mid-purchase, reinstall + restore.

## 4. Play Console checklist (owner does the account steps; agent prepares drafts)
- [ ] Google Play developer account created and identity verified (one-time registration fee; owner pays).
- [ ] Merchant/payments profile set up for selling in-app items; check Nigeria payout and tax requirements.
- [ ] Create app in Play Console; opt into **Play App Signing**.
- [ ] Complete app content forms: **Content rating questionnaire**, **Data safety** form, **Ads declaration**, target audience (do NOT target children unless intentionally designed for that), news/government/financial declarations as applicable.
- [ ] **Privacy policy** URL (agent drafts; owner hosts and reviews; mention ads, purchases, any analytics, data retention, contact email).
- [ ] Store listing: title, short description (80 chars), full description, icon (512×512), feature graphic (1024×500), phone screenshots, optional trailer.
- [ ] Upload **AAB**; versioning (`versionCode` increments every upload).
- [ ] **Testing requirement:** for newer personal developer accounts Google requires a closed test with a minimum number of testers for a minimum period before production access. Check the current numbers; recruit testers early (friends, church media team, university contacts).
- [ ] Fix pre-launch report issues, then submit to production with staged rollout (e.g. 20% → 100%).

## 5. Policy guardrails for this game
- Depicting street life, crime consequences and belief systems is allowed in games but must not be hateful, sexually explicit, or promote illegal activity. Keep violence mild.
- No real brands or impersonation. Original assets only.
- Accurate store listing: screenshots must show real gameplay; don't promise features that are missing.
- Ads must follow AdMob policies (no accidental-click layouts, appropriate placement).

## 6. Post-launch
Read reviews, fix crashes first (Android vitals), ship small updates, and add content packs gradually. Keep `save_version` migrations working so updates don't wipe progress.
