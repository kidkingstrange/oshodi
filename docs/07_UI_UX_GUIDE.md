# 07 — UI/UX Guide

Goal: a game that looks and feels like a polished, original product with a clear Lagos identity, while running smoothly on low-end Android phones. Read this before building ANY screen. Each rule includes its reason.

## 1. Art direction

**LOCKED: Option A — "Danfo Poster" (chosen by the owner).** Do not use Options B or C. Use the Option A palette as the source of truth for `theme_tokens.gd`. Options B and C are kept below for reference only.

Suggested roles: `primary` Danfo Yellow, `surface` Asphalt Black, `text` Chalk White, `money`/success Naija Green, `danger` Signal Red, `accent`/`energy` Sky Teal, `border`/wood Mud Brown.

Direction notes: thick black outlines, flat colour fills, sign-writer style lettering for headings, slightly imperfect hand-painted edges, danfo-style black stripe bands as dividers, and poster-style panels. Keep body text in a clean, highly readable font on solid dark or chalk-white surfaces.

### Original options considered

### Option A — "Danfo Poster" (recommended)
Hand-painted Lagos street-sign look. Thick outlines, flat colour, bold sign-writer lettering, slightly imperfect edges.
- Palette: Danfo Yellow `#F7B500`, Asphalt Black `#1B1B1F`, Chalk White `#F5F1E8`, Naija Green `#1E8E4E`, Signal Red `#D8402F`, Sky Teal `#2BA6A0`, Mud Brown `#6B4A2F`
- Why: instantly local, cheap to render (flat shapes), high contrast in sunlight.

### Option B — "Market Cloth"
Ankara/Adire-inspired patterns as panel backgrounds and borders; warm, rich, textile feel.
- Palette: Indigo `#2B2D6E`, Cowrie White `#FAF6EE`, Terracotta `#C4552D`, Gold `#E0A526`, Leaf `#2F7D4F`, Plum `#6A2C5B`
- Why: distinctive and beautiful; patterns must be original and kept subtle so text stays readable.

### Option C — "Night Lagos Comic"
Dark, neon-lit comic-book look: halftone shading, glowing signs, night-time energy.
- Palette: Midnight `#0F1020`, Neon Magenta `#FF2E88`, Electric Cyan `#18E0FF`, Lagos Lime `#B6F23C`, Warm White `#F4F0E6`, Ember `#FF7A2F`
- Why: dramatic and modern; needs care for battery use and outdoor readability.

The agent builds a style-guide scene in Godot showing the Danfo Poster palette, type, buttons, cards and icons, and waits for the owner's approval before polishing any screen. All designs must be original: no real brands, logos or copied artwork.

## 2. Design system (build once, reuse everywhere)
1. **Palette:** 5–7 colours with fixed roles: `primary`, `accent`, `surface`, `text`, `money`, `energy`, `danger`. Store in `scripts/ui/theme_tokens.gd` and the Godot Theme. *Why: one change updates the whole game.*
2. **Typography:** one display font (headings, short labels) and one highly readable body font. Only fonts with licences allowing commercial/app embedding; log in `ASSET_LICENSES.md`. Type scale: 14, 18, 24, 32, 48 (sp equivalents). Body text never below 16.
3. **Spacing:** 8 px grid (8, 16, 24, 32, 48). *Why: consistent rhythm makes layouts look professional.*
4. **Shape language:** one corner radius and one border thickness used everywhere.
5. **Icons:** one consistent set (original, or CC0/commercial-licensed) for Energy, Naira, Respect, Heat, XP, Time, Location. Always pair icons with a label or number. *Why: never rely on colour alone.*
6. **Theme resource:** `res://assets/ui/main_theme.tres` applied at the root; screens must not hand-style controls.

## 3. Reusable components (each a scene in `scenes/ui/components/`)
`AppButton` (primary/secondary/danger, press feedback), `Card`, `DialogueBox`, `StatBar`, `ResourceChip`, `ChoiceButton` (big, thumb-friendly), `Popup`, `Toast`, `TopBar` (day, time, Naira, Energy), `ScreenHeader`.
Rule: if a screen needs a new control, add it to the component library first.

## 4. Layout rules
- Portrait, base 720×1280, stretch mode `canvas_items`, aspect `expand`. Respect safe areas (notches, gesture bars).
- **Thumb zone:** primary actions in the bottom third; info at the top.
- Touch targets at least 48 dp; at least 8 px between buttons.
- One focal point per screen; maximum 3 levels of visual hierarchy.
- Text: short paragraphs (max ~3 lines per block), generous line height, never white text on light backgrounds.
- Empty space is a feature. If a screen feels crowded, split it.
- Android Back button always goes back or closes a popup; never exits unexpectedly.

## 5. Screen specs (wireframe first, then polish)
1. **Main Menu:** logo, Play/Continue, Settings; ambient animated background.
2. **Character Creation:** class carousel (swipe), stat bars, perk text, confirm.
3. **Hub:** location illustration, time/day, resource chips, activity buttons.
4. **Situation:** illustration/portrait, setup text, 2–5 big choice buttons, result card with animated effect chips (+₦1,500, −5 Energy).
5. **Shop/Inventory:** grid of item cards, clear price, owned count.
6. **Settings:** sound, music, text size, reduce motion, language, delete save.
Process: build greybox wireframes of all six, get owner approval, then apply the art direction.

## 6. Juice (feedback) spec
- Button press: scale to 0.95 in 80 ms, release with a small overshoot; click sound.
- Numbers: count up over 400 ms (Naira) with a coin tick sound.
- Panels: slide/fade in with ease-out, 200–300 ms. No linear motion.
- Success: green flash + rising sound. Failure: gentle shake + low sound (never harsh).
- Ambient: subtle looping city sounds per location (original or licensed), low volume, toggleable.
- Every animation under 300 ms unless it is a deliberate moment (level up, Showdown). **Settings → Reduce motion** disables non-essential animation. *Why: comfort, accessibility and battery.*

## 7. Audio direction
Short OGG loops, a warm Afrobeats-inspired original score (do not imitate or sample real songs), UI sounds that are soft and satisfying. Separate sliders for music and effects.

## 8. Performance and size
- Prefer vector-like flat shapes, gradients and small atlases; compress textures. Avoid full-screen high-resolution images; use 720-px-wide art.
- No per-frame heavy effects (no large blurs, real-time shadows). Target 30+ FPS on ~2 GB RAM phones.
- Total build under the budget in `02_TECH_SPEC.md`.

## 9. Accessibility
Adjustable text size (3 levels), high-contrast mode, no colour-only signals, readable fonts, reduce-motion toggle, subtitles for any voice or key sounds.

## 10. Art production workflow
1. Mood board + palette (this file) → owner approves.
2. Style guide page: colours, fonts, buttons, cards, icons (one scene in Godot showing all components).
3. Key art: logo, 6 class portraits, 4 location backdrops. The owner may commission an illustrator; the agent prepares a clear brief (sizes, style, count, licence terms: full commercial rights).
4. If AI-generated drafts are used, the owner must confirm the tool's commercial licence, keep style consistent, and avoid imitating any living artist or real brand. Log everything in `ASSET_LICENSES.md`.
5. Polish pass per phase: spacing, alignment, animation timing.

## 11. Playtest checklist (every phase that adds UI)
- [ ] A new player understands each screen in under 5 seconds.
- [ ] Every button reachable with one thumb.
- [ ] Readable outdoors at low brightness.
- [ ] No text cut off on 16:9, 19.5:9 and small screens.
- [ ] Animations smooth on the lowest-end test phone.
- [ ] Reduce motion and text size settings work.
