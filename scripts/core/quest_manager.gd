class_name QuestManager
extends RefCounted

## QuestManager
## Evaluates quest objectives, step progression, and reward grants per docs/03_DATA_SCHEMAS.md.

## Checks if a quest is currently active in GameState.
static func is_quest_active(quest_id: String) -> bool:
	if not GameState.quest_progress.has(quest_id):
		return false
	var state = GameState.quest_progress[quest_id]
	return state.get("status", "") == "active"

## Checks if a quest has already been completed.
static func is_quest_completed(quest_id: String) -> bool:
	if not GameState.quest_progress.has(quest_id):
		return false
	var state = GameState.quest_progress[quest_id]
	return state.get("status", "") == "completed"

## Activates a quest if eligible and not already completed or active.
static func start_quest(quest_id: String) -> bool:
	var q = DataLoader.get_quest_by_id(quest_id)
	if q.is_empty():
		return false
	if is_quest_completed(quest_id) or is_quest_active(quest_id):
		return false
	
	var req_class = q.get("required_class", null)
	if req_class != null and req_class != GameState.class_id:
		return false
	
	GameState.quest_progress[quest_id] = {
		"status": "active",
		"started_day": GameState.day,
		"current_step": 0
	}
	return true

## Checks if all conditions for the quest's active step are fulfilled.
static func is_step_fulfilled(quest_id: String) -> bool:
	if not is_quest_active(quest_id):
		return false
	
	var q = DataLoader.get_quest_by_id(quest_id)
	if q.is_empty():
		return false
	
	var steps = q.get("steps", [])
	if steps.is_empty():
		return true
	
	var cur_step_idx = int(GameState.quest_progress[quest_id].get("current_step", 0))
	if cur_step_idx >= steps.size():
		return true
	
	var step = steps[cur_step_idx]
	var cond = step.get("condition", {})
	var c_type = cond.get("type", "")
	var target_val = cond.get("value", 0)
	
	match c_type:
		"naira_at_least":
			return GameState.resources.naira >= target_val
		"respect_at_least":
			return GameState.resources.respect >= target_val
		"level_at_least":
			return GameState.level >= target_val
		"heat_at_most":
			return GameState.resources.heat <= target_val
		"inventory_count_at_least":
			var total_items = 0
			for it in GameState.inventory:
				total_items += int(it.get("quantity", 1))
			return total_items >= target_val
		_:
			return false

## Completes the quest if fulfilled, awards rewards, and records completion.
static func complete_quest(quest_id: String) -> Dictionary:
	if not is_step_fulfilled(quest_id):
		return {}
	
	var q = DataLoader.get_quest_by_id(quest_id)
	if q.is_empty():
		return {}
	
	var reward = q.get("reward", {})
	var xp_gain = int(reward.get("xp", 0))
	var respect_gain = int(reward.get("respect", 0))
	var naira_gain = int(reward.get("naira", 0))
	
	if xp_gain > 0:
		Levelling.add_xp(xp_gain)
	if respect_gain != 0:
		GameState.modify_resource("respect", respect_gain)
	if naira_gain > 0:
		GameState.modify_resource("naira", naira_gain)
	
	GameState.quest_progress[quest_id]["status"] = "completed"
	GameState.quest_progress[quest_id]["completed_day"] = GameState.day
	
	return {
		"quest_id": quest_id,
		"title": q.get("title", ""),
		"xp": xp_gain,
		"respect": respect_gain,
		"naira": naira_gain
	}

## Returns all currently active quests.
static func get_active_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for q_id in DataLoader.quests:
		if is_quest_active(q_id):
			var q = DataLoader.get_quest_by_id(q_id).duplicate(true)
			q["is_ready_to_claim"] = is_step_fulfilled(q_id)
			result.append(q)
	return result

## Returns quests eligible to be taken by the player.
static func get_available_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for q_id in DataLoader.quests:
		if is_quest_active(q_id) or is_quest_completed(q_id):
			continue
		var q = DataLoader.get_quest_by_id(q_id)
		var req_class = q.get("required_class", null)
		if req_class != null and req_class != GameState.class_id:
			continue
		result.append(q)
	return result

## Returns all completed quests.
static func get_completed_quests() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for q_id in DataLoader.quests:
		if is_quest_completed(q_id):
			result.append(DataLoader.get_quest_by_id(q_id))
	return result
