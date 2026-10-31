class_name Levelling
extends RefCounted

## Levelling
## Handles XP accumulation, level-up checks, stat boosts on level-up,
## and subclass unlock eligibility at level 5.
## Pure core logic with zero UI code.

## Adds XP to player and automatically checks/applies level-ups.
static func add_xp(amount: int) -> Dictionary:
	GameState.xp += amount
	return check_and_apply_levelups()

## Checks if the player has enough XP to level up and applies all pending level-ups.
## Returns a report dictionary describing what happened.
static func check_and_apply_levelups() -> Dictionary:
	var xp_table = DataLoader.get_xp_table()
	var levels_gained: Array[int] = []
	var stat_boosts: Array[Dictionary] = []
	var subclass_unlocked = false
	var old_level = GameState.level
	
	while GameState.level < xp_table.size():
		var next_level = GameState.level + 1
		if next_level > xp_table.size():
			break
		var xp_needed = int(xp_table[GameState.level]) if GameState.level < xp_table.size() else 999999
		if GameState.xp < xp_needed:
			break
		
		GameState.level = next_level
		levels_gained.append(next_level)
		
		# Grant stat boost on level-up: +1 to class primary stat
		var boost = _get_level_stat_boost(GameState.class_id, next_level)
		if not boost.is_empty():
			for stat_key in boost:
				GameState.modify_stat(stat_key, int(boost[stat_key]))
			stat_boosts.append(boost)
		
		# Increase max energy every 3 levels
		if next_level % 3 == 0:
			GameState.resources.max_energy += 10
			GameState.modify_resource("energy", 10)
		
		# Check subclass unlock
		if next_level == 5 and GameState.subclass_id.is_empty():
			subclass_unlocked = true
	
	return {
		"levelled_up": not levels_gained.is_empty(),
		"old_level": old_level,
		"new_level": GameState.level,
		"levels_gained": levels_gained,
		"stat_boosts": stat_boosts,
		"subclass_unlocked": subclass_unlocked
	}

## Returns the XP required to reach the NEXT level from the current one.
static func xp_to_next_level() -> int:
	var xp_table = DataLoader.get_xp_table()
	if GameState.level >= xp_table.size():
		return 0 # Max level
	return int(xp_table[GameState.level]) - GameState.xp

## Returns progress fraction (0.0 to 1.0) towards the next level.
static func xp_progress_fraction() -> float:
	var xp_table = DataLoader.get_xp_table()
	if GameState.level >= xp_table.size():
		return 1.0
	var current_threshold = int(xp_table[GameState.level - 1]) if GameState.level > 1 else 0
	var next_threshold = int(xp_table[GameState.level])
	var range_size = next_threshold - current_threshold
	if range_size <= 0:
		return 1.0
	return clampf(float(GameState.xp - current_threshold) / float(range_size), 0.0, 1.0)

## Determines which stat gets boosted at a given level for a given class.
static func _get_level_stat_boost(class_id: String, level: int) -> Dictionary:
	# Alternating primary and secondary stats based on class
	match class_id:
		"trader":
			if level % 2 == 0:
				return { "hustle": 1 }
			else:
				return { "charisma": 1 }
		"transporter":
			if level % 2 == 0:
				return { "stamina": 1 }
			else:
				return { "grit": 1 }
		"area_boy":
			if level % 2 == 0:
				return { "grit": 1 }
			else:
				return { "street_smarts": 1 }
		"working_class":
			if level % 2 == 0:
				return { "stamina": 1 }
			else:
				return { "hustle": 1 }
		"road_official":
			if level % 2 == 0:
				return { "charisma": 1 }
			else:
				return { "street_smarts": 1 }
		"faith_leader":
			if level % 2 == 0:
				return { "charisma": 1 }
			else:
				return { "hustle": 1 }
		_:
			return { "hustle": 1 }

## Applies a chosen subclass to the player.
static func apply_subclass(subclass_id: String) -> Dictionary:
	var sc_data = DataLoader.get_subclass_by_id(subclass_id)
	if sc_data.is_empty():
		return { "success": false, "message": "Unknown subclass id." }
	
	var sc_class = sc_data.get("class_id", "")
	if sc_class != GameState.class_id:
		return { "success": false, "message": "Subclass does not belong to your class." }
	
	if GameState.level < 5:
		return { "success": false, "message": "You must be at least Level 5 to unlock a subclass." }
	
	GameState.subclass_id = subclass_id
	
	# Apply first perk as a passive stat boost
	var perks = sc_data.get("perks", [])
	# Subclass perks are narrative; we don't need to apply stat changes here
	# The perk effects are checked during activities via flags
	GameState.flags["subclass_unlocked"] = true
	GameState.flags["subclass_perks"] = true
	
	return {
		"success": true,
		"subclass_name": sc_data.get("name", ""),
		"message": "You have specialised as a %s!" % sc_data.get("name", "Specialist")
	}
