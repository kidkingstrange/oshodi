# 03 — Data Schemas (JSON)

Rules: UTF-8, snake_case keys, every record has a unique string `id` (lowercase, underscores). IDs are referenced across files, so never rename them casually. All player-visible text uses plain strings now (localisation keys can come later). The DataLoader must validate these and report errors precisely.

## classes.json
```json
{
  "id": "trader",
  "name": "Trader",
  "tagline": "Buy low, sell high, greet everybody.",
  "base_stats": { "hustle": 5, "street_smarts": 4, "charisma": 4, "stamina": 3, "grit": 3 },
  "signature_mechanic": "stock_and_price",
  "passive_perk": { "id": "good_eye", "text": "Better chance to spot cheap stock." },
  "subclass_unlock_level": 5,
  "subclasses": ["market_woman", "pure_water_seller", "traffic_hawker", "phone_accessories_dealer", "foodstuff_wholesaler", "mama_put"]
}
```

## subclasses.json
```json
{
  "id": "market_woman",
  "class_id": "trader",
  "name": "Market Woman",
  "fantasy": "Queen of her stall, knows every price in town.",
  "perks": [ { "id": "price_memory", "text": "See price trends one day ahead." }, { "id": "regular_customers", "text": "Repeat buyers pay 5% more." } ],
  "weakness": "Low Stamina on long market days.",
  "situation_sets": ["market_haggling", "market_disputes"],
  "unlock": { "min_class_level": 5 }
}
```

## situations.json (the "conflict" unit)
```json
{
  "id": "market_haggle_tomatoes",
  "title": "Tomato price war",
  "location_tags": ["oshodi_market"],
  "required_class": null,
  "time_blocks": ["morning", "afternoon"],
  "setup_text": "A buyer says your tomatoes are too costly. Another seller is shouting a lower price.",
  "options": [
    {
      "id": "hold_price",
      "label": "Hold your price",
      "check": { "stat": "charisma", "difficulty": 6 },
      "on_success": { "text": "...", "effects": { "naira": 1500, "respect": 1 } },
      "on_fail": { "text": "...", "effects": { "naira": -300, "energy": -5 } }
    }
  ]
}
```
`effects` keys allowed: `naira`, `energy`, `respect`, `heat`, `xp`, `stat_<name>`, `flag_set`, `flag_clear`, `item_add`, `item_remove`.

## items.json
```json
{ "id": "generator_petrol", "name": "Petrol for generator", "type": "consumable", "price": 3000, "effect": { "energy": 0 }, "description": "Keeps the light on." }
```

## locations.json
```json
{ "id": "oshodi_market", "district": "oshodi", "name": "Oshodi Market", "description": "...", "activities": ["work", "shop", "socialise"], "event_pool": ["market_events"], "travel": [ { "to": "oshodi_bus_terminal", "cost_naira": 200, "time_blocks": 1 } ] }
```

## quests.json
```json
{ "id": "first_landlord", "title": "Rent Is Due", "giver": "npc_landlord", "steps": [ { "id": "s1", "text": "Raise rent money.", "condition": { "naira_at_least": 20000 } } ], "reward": { "xp": 50, "respect": 2 } }
```

## events.json (random daily events)
```json
{ "id": "power_cut", "weight": 10, "conditions": { "time_blocks": ["evening","night"] }, "situation_id": "power_cut_choice" }
```

## npcs.json
```json
{ "id": "npc_landlord", "name": "Baba Landlord (fictional)", "role": "landlord", "location_ids": ["isolo_street"], "dialogue_ids": ["landlord_rent"] }
```

## dialogue.json
```json
{ "id": "landlord_rent", "lines": [ { "speaker": "npc_landlord", "text": "My money no fit wait again!" } ] }
```

## economy.json
Tunable numbers: starting naira per class, daily costs, price ranges per item, rent amounts, event frequency. Never hardcode these in scripts.

## save file (user://saves/slot_N.json)
`save_version`, `timestamp`, `player` (class, subclass, level, xp, stats, resources, inventory, flags), `world` (day, time_block, location, quest_progress), `settings_snapshot`. Include a `migrate(save)` function for older versions.

## Validation checklist for the agent
- Every referenced id exists. No duplicate ids. Required fields present. Numbers within sensible ranges. No empty text. Report all errors together.
