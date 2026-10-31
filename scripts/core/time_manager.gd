class_name TimeManager
extends RefCounted

## TimeManager
## Handles the in-game 4-block day cycle, day rollover, daily expenses, and dawn news.
## Pure core logic with zero UI dependencies.

const TIME_BLOCKS: Array[String] = ["morning", "afternoon", "evening", "night"]

## Advances in-game time by specified number of blocks (default 1)
static func advance_time(blocks: int = 1, rng: RandomNumberGenerator = null) -> Dictionary:
	var current_block = GameState.time_block
	var current_idx = TIME_BLOCKS.find(current_block)
	if current_idx == -1:
		current_idx = 0
	
	var rollover_report: Dictionary = {
		"is_new_day": false,
		"old_day": GameState.day,
		"new_day": GameState.day,
		"time_block": "",
		"food_cost_paid": 0,
		"hunger_penalty": false,
		"morning_news": ""
	}
	
	for i in range(blocks):
		current_idx += 1
		if current_idx >= TIME_BLOCKS.size():
			# Rollover from Night into a New Day
			current_idx = 0
			GameState.day += 1
			rollover_report.is_new_day = true
			rollover_report.new_day = GameState.day
			
			# Process overnight living expenses (food)
			var food_cost = DataLoader.get_daily_food_cost()
			if GameState.resources.naira >= food_cost:
				GameState.modify_resource("naira", -food_cost)
				rollover_report.food_cost_paid = food_cost
				# Sleeping well restores baseline energy (+20)
				GameState.modify_resource("energy", 20)
			else:
				# Cannot afford full meal: takes whatever is left and suffers fatigue
				rollover_report.food_cost_paid = GameState.resources.naira
				GameState.resources.naira = 0
				GameState.modify_resource("energy", -10)
				rollover_report.hunger_penalty = true
			
			# Generate morning street news
			rollover_report.morning_news = DataLoader.get_random_morning_news(rng)
			
			# Trigger day-end autosave
			SaveSystem.save_autosave()
	
	GameState.time_block = TIME_BLOCKS[current_idx]
	rollover_report.time_block = GameState.time_block
	
	GameState.time_advanced.emit(GameState.day, GameState.time_block)
	return rollover_report

## Returns human-readable label for time block
static func get_time_block_display_name(block: String) -> String:
	match block:
		"morning":
			return "Morning (Rush Hour)"
		"afternoon":
			return "Afternoon (Market Peak)"
		"evening":
			return "Evening (Return Rush)"
		"night":
			return "Night (Quiet Streets)"
		_:
			return block.capitalize()
