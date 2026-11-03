# Google Play Store Visual Assets Brief & Specifications

This document outlines the visual specifications, composition guidelines, color palettes, and production requirements for the Google Play Store graphics of **Oshodimushin: Lagos Street RPG**.

All visual assets must adhere strictly to the **Danfo Poster** art direction defined in `docs/07_UI_UX_GUIDE.md`: bold high-contrast palettes, vintage hand-painted transport lettering, sharp geometric silhouettes, and **zero emojis**.

---

## 1. Palette & Typography Standards

| Role | Color Name | Hex Code | Visual Context |
|---|---|---|---|
| **Primary Brand** | Danfo Yellow | `#FCD116` | Main bus body, vibrant poster backdrop, badge highlights |
| **Primary Contrast** | Dark Charcoal / Asphalt | `#14171D` | Bus stripes, deep background, high-contrast headline text |
| **Accent Primary** | Lagos Green | `#1E7E34` | Naira currency text, prosperity badges, success indicators |
| **Accent Secondary** | Terracotta / Brick | `#C0392B` | Heat danger levels, high-stakes warnings, badge borders |
| **Card Fill** | Warm Card Stock | `#FFFDF5` | Paper textured message boxes, readable dialog surfaces |
| **Subtle Border** | Poster Border | `#E5B80B` | Framed borders, distinct clean dividing lines |

**Typography Guidelines:**
- **Headlines:** Ultra-bold, condensed sans-serif (e.g., Oswald, Bebas Neue, Montserrat Black, or Impact). All uppercase, tight tracking, heroic street poster feel.
- **Body & Subtitles:** Clean, readable geometric sans-serif (e.g., Roboto, Inter, Segoe UI). High legibility at small mobile preview sizes.

---

## 2. App Icon (512 × 512 px)

Google Play displays this icon across search results, top charts, category lists, and device home screens.

### Technical Specifications:
- **Dimensions:** Exactly 512 × 512 pixels
- **Format:** 32-bit PNG (with alpha channel)
- **Max File Size:** 1024 KB
- **Shape:** Square. Google Play automatically applies the standard squircle (curved corner) mask with uniform drop shadow. Do **not** upload pre-rounded corners.

### Composition & Layout:
1. **Background:** Rich Danfo Yellow (`#FCD116`) square background fill.
2. **Iconic Dual Stripes:** Two horizontal asphalt-black bands (`#14171D`) spanning the width of the lower-middle half (reminiscent of the ubiquitous Lagos Danfo bus livery).
3. **Central Emblem:** A deep charcoal rounded shield (`#14171D`) centered with a subtle warm card border (`#FFFDF5`).
4. **Hero Lettering / Motif:**
   - Bold, stylized "OSH" lettering in Danfo Yellow (`#FCD116`) at the top center.
   - Clean, high-contrast "RPG" lettering in crisp white (`#FFFFFF`) directly below.
   - Distinctive silhouette of a Danfo transit van front grill or stylized steering wheel beneath the text.
5. **Rules:** No photographs, no fine gradients, no low-contrast elements, and **strictly no emojis**.

---

## 3. Feature Graphic (1024 × 500 px)

The Feature Graphic is the marquee banner shown at the top of the store listing and featured across Google Play editorial promotions.

### Technical Specifications:
- **Dimensions:** Exactly 1024 × 500 pixels
- **Format:** JPG or 24-bit PNG (no alpha)
- **Max File Size:** 15 MB
- **Safe Zone:** Keep all critical text, titles, and focal artwork within the center 80% (approx. 820 × 400 px) to prevent clipping across various Android screen ratios.

### Composition & Layout:
- **Left / Center Focus (Hero Title):**
  - Large display title: **OSHODIMUSHIN** (Bold Danfo Yellow `#FCD116` with deep black shadow/outline).
  - Subtitle banner: **LAGOS STREET RPG** in high-contrast white with dark charcoal pill background.
  - Tagline: *"Survive • Hustle • Rise"* in warm terracotta `#C0392B`.
- **Right Focus (Hero Artwork):**
  - Stylized graphic silhouette of an iconic yellow Lagos Danfo bus alongside a bustling Oshodi market stall.
  - Silhouettes representing the diverse playable classes: a trader holding a ledger, a transporter with driver cap, and a suited worker commuting.
- **Background Atmosphere:**
  - Sunlit Lagos sky gradient shifting from warm sunrise cream into golden yellow, with geometric outlines of the Oshodi pedestrian bridge and highway pillars in the background.
- **Badge:**
  - Subtle corner stamp: *"100% Offline-First Life Sim"*.

---

## 4. Phone Screenshots (Min 4, Recommended 6)

Upload at least 4 high-resolution portrait screenshots showcasing genuine gameplay and clear feature value propositions.

### Technical Specifications:
- **Aspect Ratio:** 9:16 or 9:20 portrait (e.g., 1080 × 1920 px or 1080 × 2400 px)
- **Format:** 24-bit PNG or high-quality JPEG (no alpha)
- **Layout Style:** Top 20% contains a bold poster-style caption banner; bottom 80% contains clean, crisp actual in-game screen capture.

### Screenshot Sequence Plan:

#### Screenshot 1: Character Creation & Classes
- **Caption Banner:** *"CHOOSE YOUR HUSTLE — 6 PLAYABLE STREET CLASSES"*
- **In-Game Screen:** Character Creation screen displaying class selection (Trader, Transporter, Area Boy, Working Class, Road Official, Faith Leader) with base attributes and perks.

#### Screenshot 2: Oshodi District Hub & Routine
- **Caption Banner:** *"NAVIGATE THE PULSE OF LAGOS — OSHODI TO ISOLO"*
- **In-Game Screen:** Oshodi Hub screen showing Underbridge location, daytime cycle (Morning/Afternoon/Night), Energy/Naira/Respect/Heat resource bars, and street action cards.

#### Screenshot 3: Dynamic Street Situations
- **Caption Banner:** *"MAKE CRITICAL CHOICES WITH REAL CONSEQUENCES"*
- **In-Game Screen:** Situation resolution encounter (e.g., "Underbridge Gridlock Haggling" or "Checkpoint Paper Check") showing clear choices, stat requirements, and branching outcomes.

#### Screenshot 4: Market Stalls & Economy
- **Caption Banner:** *"BUY LOW, HAGGLE HARD & BUILD YOUR NAIRA"*
- **In-Game Screen:** Market Stall / Shop screen showcasing goods (provisions, electronics, spare parts), buy/sell price margins, and inventory weight capacity.

#### Screenshot 5: Progression & 36 Subclasses
- **Caption Banner:** *"SPECIALIZE YOUR CAREER INTO 36 UNIQUE ROLES"*
- **In-Game Screen:** Subclass selection screen showing unlocks (e.g., Boutique Owner, Keke Cruiser, Street Mediator, Civil Servant, Traffic Warden, Tenement Pastor).

#### Screenshot 6: Offline-First & Fair Play
- **Caption Banner:** *"100% OFFLINE-FIRST — NO PAY-TO-WIN, PLAY ANYWHERE"*
- **In-Game Screen:** Clean settings and profile view highlighting seamless offline play with zero forced interstitial ads.

---

## 5. Summary Asset Checklist for Owner

- [ ] `icon_512.png` — 512 × 512 px 32-bit PNG.
- [ ] `feature_graphic_1024x500.png` — 1024 × 500 px 24-bit PNG.
- [ ] `screenshot_1_classes.png` — 1080 × 2400 px portrait PNG.
- [ ] `screenshot_2_hub.png` — 1080 × 2400 px portrait PNG.
- [ ] `screenshot_3_situations.png` — 1080 × 2400 px portrait PNG.
- [ ] `screenshot_4_shop.png` — 1080 × 2400 px portrait PNG.
- [ ] `screenshot_5_subclasses.png` — 1080 × 2400 px portrait PNG.
- [ ] `screenshot_6_offline.png` — 1080 × 2400 px portrait PNG.
