class_name EventManager
extends RefCounted

## EventManager
## Evaluates and triggers weighted random street events per time block and location.
## Supports seeded RandomNumberGenerator for deterministic unit testing.

## Checks whether a random event triggers during an activity block (e.g. 60% chance)
static func maybe_trigger_event(
	time_block: String,
	location_id: String,
	trigger_chance: float = 0.65,
	rng: RandomNumberGenerator = null
) -> Dictionary:
	var roll = 0.0
	if rng:
		roll = rng.randf()
	else:
		roll = randf()
	
	if roll > trigger_chance:
		return { "triggered": false }
	
	return roll_and_apply_event(time_block, location_id, rng)

## Rolls an eligible event from DataLoader and applies its effects
static func roll_and_apply_event(
	time_block: String,
	location_id: String,
	rng: RandomNumberGenerator = null
) -> Dictionary:
	var eligible_events: Array[Dictionary] = []
	var total_weight = 0
	
	for ev in DataLoader.get_all_events():
		var conds = ev.get("conditions", {})
		
		# Filter by time_block if specified
		var allowed_times = conds.get("time_blocks", [])
		if not allowed_times.is_empty() and not allowed_times.has(time_block):
			continue
		
		# Filter by location if specified
		var allowed_locs = conds.get("location_ids", [])
		if not allowed_locs.is_empty() and not allowed_locs.has(location_id):
			continue
		
		var weight = int(ev.get("weight", 10))
		eligible_events.append(ev)
		total_weight += weight
	
	if eligible_events.is_empty() or total_weight <= 0:
		return { "triggered": false }
	
	var picked_val = 0
	if rng:
		picked_val = rng.randi_range(1, total_weight)
	else:
		picked_val = (randi() % total_weight) + 1
	
	var cumulative = 0
	var selected_event: Dictionary = {}
	for ev in eligible_events:
		cumulative += int(ev.get("weight", 10))
		if picked_val <= cumulative:
			selected_event = ev
			break
	
	if selected_event.is_empty():
		selected_event = eligible_events[0]
	
	# Apply effects to GameState
	var effects = selected_event.get("effects", {})
	if effects.has("naira"):
		GameState.modify_resource("naira", int(effects["naira"]))
	if effects.has("energy"):
		GameState.modify_resource("energy", int(effects["energy"]))
	if effects.has("respect"):
		GameState.modify_resource("respect", int(effects["respect"]))
	if effects.has("heat"):
		GameState.modify_resource("heat", int(effects["heat"]))
	if effects.has("xp"):
		GameState.xp += int(effects["xp"])
	
	EventBus.situation_triggered.emit(selected_event.get("id", ""))
	
	return {
		"triggered": true,
		"event": selected_event,
		"effects": effects
	}
