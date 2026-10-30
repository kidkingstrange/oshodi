class_name SituationResolver
extends RefCounted

## SituationResolver
## Evaluates Situation options against player stats using a 1d6 roll + stat vs difficulty.
## Applies effects, handles Energy 0 exhaustion recoveries, and supports seeded RNG for unit tests.
## Pure core logic with zero UI code.

## Resolves a player's selected option in a Situation
static func resolve_option(
	situation: Dictionary,
	option_id: String,
	rng: RandomNumberGenerator = null
) -> Dictionary:
	var options = situation.get("options", [])
	var chosen_option: Dictionary = {}
	for opt in options:
		if opt.get("id", "") == option_id:
			chosen_option = opt
			break
	
	if chosen_option.is_empty():
		return {
			"success": false,
			"error": "Option id '%s' not found in situation." % option_id
		}
	
	var check = chosen_option.get("check", null)
	var has_check = (check != null and check is Dictionary)
	var stat_name = ""
	var stat_val = 0
	var roll = 0
	var total = 0
	var difficulty = 0
	var is_success = true
	
	if has_check:
		stat_name = check.get("stat", "hustle")
		difficulty = int(check.get("difficulty", 5))
		stat_val = int(GameState.stats.get(stat_name, 1))
		
		# 1d6 dice roll (1 to 6)
		if rng:
			roll = rng.randi_range(1, 6)
		else:
			roll = (randi() % 6) + 1
		
		total = stat_val + roll
		is_success = (total >= difficulty)
	
	# Select resolution outcome branch
	var branch = chosen_option.get("on_success", {}) if is_success else chosen_option.get("on_fail", {})
	var result_text = branch.get("text", "")
	var effects = branch.get("effects", {})
	
	# Apply effects to GameState
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
	if effects.has("flag_set"):
		GameState.flags[effects["flag_set"]] = true
	if effects.has("flag_clear"):
		GameState.flags.erase(effects["flag_clear"])
	
	# Energy 0 Exhaustion Handling: forced rest with a cost, never a hard game over
	var exhaustion_triggered = false
	var exhaustion_message = ""
	if GameState.resources.energy <= 0:
		exhaustion_triggered = true
		var clinic_cost = mini(GameState.resources.naira, 1000)
		GameState.modify_resource("naira", -clinic_cost)
		# Restore baseline recovery energy
		GameState.resources.energy = 30
		exhaustion_message = "You slumped from pure Oshodi exhaustion! A kind street chemist gave you cold water and glucose (+30 Energy, -%s)." % GameState.format_naira(clinic_cost)
	
	var outcome = {
		"success": true,
		"option_id": option_id,
		"option_label": chosen_option.get("label", ""),
		"has_check": has_check,
		"stat_name": stat_name,
		"stat_val": stat_val,
		"roll": roll,
		"total": total,
		"difficulty": difficulty,
		"is_success": is_success,
		"result_text": result_text,
		"effects": effects,
		"exhaustion_triggered": exhaustion_triggered,
		"exhaustion_message": exhaustion_message
	}
	
	EventBus.situation_resolved.emit(outcome)
	return outcome
