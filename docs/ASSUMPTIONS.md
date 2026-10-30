# ASSUMPTIONS.md — Recorded Assumptions for Oshodimushin RPG

This document logs all engineering, design, and content assumptions made during development.
Any item with status `Pending Owner Review` can be verified or changed by the project owner.

| Date | Phase | Assumption | Reason / Context | Status |
|---|---|---|---|---|
| 2026-10-30 | Phase 0 | Godot 4.x GL Compatibility renderer selected in `project.godot` | Best performance, battery efficiency, and hardware compatibility on budget Android devices (~2GB RAM) per technical specification. | Confirmed per Tech Spec |
| 2026-10-30 | Phase 0 | 720x1280 base resolution with portrait orientation and `canvas_items` stretch mode | Follows 02_TECH_SPEC.md requirements for single-hand mobile portrait gameplay. Desktop preview window override set to 360x640 for convenient development. | Confirmed per Tech Spec |
| 2026-10-30 | Phase 0 | Standalone autoload singletons registered with `*res://` prefix | Standard Godot 4 convention to make GameState, DataLoader, SaveSystem, EventBus, and Monetization globally accessible without circular references. | Confirmed |
