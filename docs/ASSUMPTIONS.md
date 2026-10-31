# ASSUMPTIONS.md — Recorded Assumptions for Oshodimushin RPG

This document logs all engineering, design, and content assumptions made during development.
Any item with status `Pending Owner Review` can be verified or changed by the project owner.

| Date | Phase | Assumption | Reason / Context | Status |
|---|---|---|---|---|
| 2026-10-30 | Phase 0 | Godot 4.x GL Compatibility renderer selected in `project.godot` | Best performance, battery efficiency, and hardware compatibility on budget Android devices (~2GB RAM) per technical specification. | Confirmed per Tech Spec |
| 2026-10-30 | Phase 0 | 720x1280 base resolution with portrait orientation and `canvas_items` stretch mode | Follows 02_TECH_SPEC.md requirements for single-hand mobile portrait gameplay. Desktop preview window override set to 360x640 for convenient development. | Confirmed per Tech Spec |
| 2026-10-30 | Phase 0 | Standalone autoload singletons registered with `*res://` prefix | Standard Godot 4 convention to make GameState, DataLoader, SaveSystem, EventBus, and Monetization globally accessible without circular references. | Confirmed |
| 2026-10-30 | Phase 2 | Visual layout revised to bright, vibrant Lagos aesthetic | Owner requested bright and vibrant overall layout instead of dark theme. Reusable theme with warm sunlit canvas and Danfo yellow styling applied. | Confirmed by Owner |
| 2026-10-30 | Phase 3 | Moving characters via 2D Animated Street Stage & Avatars (Option 1) | Owner requested moving characters. Selected Option 1 (animated street window, traffic, and character reaction avatars) over joystick walk-around for superior one-handed portrait mobile ergonomics and battery/RAM efficiency. | Confirmed by Owner |
| 2026-10-31 | Phase 4 | Strict ban on all emojis across the entire game (UI, labels, scripts, data) | Owner rule: Emojis make the game look cheap. Use clean text, Danfo sign-writer lettering, and custom 2D icons instead. | Confirmed by Owner |
| 2026-10-31 | Phase 5 | Strict ban on dev scaffolding, phase tags ('Phase 1 Ready'), engine names ('Godot 4'), and debug buttons on user-facing screens | Owner directive: Keep game presentation commercial, immersive, and polished; run tests headlessly and hide internal dev tools. | Confirmed by Owner |
