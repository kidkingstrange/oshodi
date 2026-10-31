class_name DialogueManager
extends RefCounted

## DialogueManager
## Handles dialogue retrieval, branch transitions, and option effect application per docs/03_DATA_SCHEMAS.md.

## Fetches the starting dialogue tree for an NPC.
static func get_starting_dialogue_for_npc(npc_id: String) -> Dictionary:
	var npc = DataLoader.get_npc_by_id(npc_id)
	if npc.is_empty():
		return {}
	var d_ids = npc.get("dialogue_ids", [])
	if d_ids.is_empty():
		return {}
	return DataLoader.get_dialogue_by_id(d_ids[0])

## Applies option effects to GameState and returns applied changes.
static func apply_option_effects(option_dict: Dictionary) -> Dictionary:
	var effects = option_dict.get("effects", {})
	if effects.is_empty():
		return {}
	
	var applied: Dictionary = {}
	
	if effects.has("naira"):
		var diff = int(effects["naira"])
		GameState.modify_resource("naira", diff)
		applied["naira"] = diff
	
	if effects.has("energy"):
		var diff = int(effects["energy"])
		GameState.modify_resource("energy", diff)
		applied["energy"] = diff
	
	if effects.has("respect"):
		var diff = int(effects["respect"])
		GameState.modify_resource("respect", diff)
		applied["respect"] = diff
	
	if effects.has("heat"):
		var diff = int(effects["heat"])
		GameState.modify_resource("heat", diff)
		applied["heat"] = diff
	
	if effects.has("xp"):
		var gain = int(effects["xp"])
		Levelling.add_xp(gain)
		applied["xp"] = gain
	
	return applied
