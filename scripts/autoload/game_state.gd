extends Node

## GameState
## The single source of truth for player data, world state, and current session.
## Fully decoupled from UI; changes are signaled to listeners via signals.

signal player_data_changed
signal resources_changed(resources: Dictionary)
signal stats_changed(stats: Dictionary)
signal time_advanced(day: int, time_block: String)
signal location_changed(new_location_id: String)

# Player Data
var player_name: String = ""
var class_id: String = ""
var subclass_id: String = ""
var level: int = 1
var xp: int = 0

var stats: Dictionary = {
	"hustle": 1,
	"street_smarts": 1,
	"charisma": 1,
	"stamina": 1,
	"grit": 1
}

var resources: Dictionary = {
	"energy": 100,
	"max_energy": 100,
	"naira": 5000,
	"respect": 10,
	"heat": 0
}

var inventory: Array[Dictionary] = []
var flags: Dictionary = {}

# World State
var day: int = 1
var time_block: String = "morning" # "morning", "afternoon", "evening", "night"
var location_id: String = "oshodi_market"
var quest_progress: Dictionary = {}

func _ready() -> void:
	print("[GameState] Autoload initialized.")

## Initializes player character from creation form
func create_character(p_name: String, p_class_id: String) -> bool:
	player_name = p_name.strip_edges()
	if player_name.is_empty():
		player_name = "Ayo"
	
	var class_data = DataLoader.get_class_by_id(p_class_id)
	if class_data.is_empty():
		printerr("[GameState] Cannot create character with invalid class_id '%s'" % p_class_id)
		return false
	
	class_id = p_class_id
	subclass_id = ""
	level = 1
	xp = 0
	
	# Load base stats from class
	var base_stats = class_data.get("base_stats", {})
	for stat_key in stats.keys():
		stats[stat_key] = int(base_stats.get(stat_key, 3))
	
	# Load starting economy and resources
	var starting_naira = DataLoader.get_starting_naira(class_id)
	var base_res = DataLoader.get_starting_resources()
	resources = {
		"energy": int(base_res.get("energy", 100)),
		"max_energy": int(base_res.get("max_energy", 100)),
		"naira": starting_naira,
		"respect": int(base_res.get("respect", 10)),
		"heat": int(base_res.get("heat", 0))
	}
	
	inventory.clear()
	flags.clear()
	
	# World initialization
	day = 1
	time_block = "morning"
	location_id = "oshodi_market"
	quest_progress.clear()
	
	print("[GameState] Character created: '%s', Class: '%s', Naira: ₦%d" % [player_name, class_id, resources.naira])
	player_data_changed.emit()
	resources_changed.emit(resources)
	stats_changed.emit(stats)
	return true

## Whether a valid player character has been created
func has_character() -> bool:
	return not player_name.is_empty() and not class_id.is_empty()

## Returns class dictionary from DataLoader
func get_class_data() -> Dictionary:
	return DataLoader.get_class_by_id(class_id)

## Returns subclass dictionary from DataLoader (if unlocked)
func get_subclass_data() -> Dictionary:
	if subclass_id.is_empty():
		return {}
	return DataLoader.get_subclass_by_id(subclass_id)

## Checks whether the player currently has the specified perk (from class or subclass)
func has_perk(perk_id: String) -> bool:
	var c_data = get_class_data()
	var class_perk = c_data.get("passive_perk", {})
	if class_perk.get("id", "") == perk_id:
		return true
	
	var sc_data = get_subclass_data()
	var perks = sc_data.get("perks", [])
	for p in perks:
		if p.get("id", "") == perk_id:
			return true
	return false

## Safely modify a resource (energy, naira, respect, heat)
func modify_resource(res_key: String, delta: int) -> void:
	if not resources.has(res_key):
		resources[res_key] = 0
	
	if res_key == "energy":
		resources.energy = clampi(resources.energy + delta, 0, resources.max_energy)
	elif res_key == "heat":
		resources.heat = maxi(0, resources.heat + delta)
	elif res_key == "respect":
		resources.respect = maxi(0, resources.respect + delta)
	elif res_key == "naira":
		resources.naira = maxi(0, resources.naira + delta)
	else:
		resources[res_key] += delta
	
	resources_changed.emit(resources)

## Safely modify a core stat
func modify_stat(stat_key: String, delta: int) -> void:
	if stats.has(stat_key):
		stats[stat_key] = maxi(1, stats[stat_key] + delta)
		stats_changed.emit(stats)

## Format currency with standard Lagos Naira sign
static func format_naira(amount: int) -> String:
	return "₦%s" % _format_number_with_commas(amount)

static func _format_number_with_commas(num: int) -> String:
	var s = str(num)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0 and s[i-1] != "-":
			result = "," + result
	return result

## Serializes the entire GameState to a Dictionary
func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"class_id": class_id,
		"subclass_id": subclass_id,
		"level": level,
		"xp": xp,
		"stats": stats.duplicate(true),
		"resources": resources.duplicate(true),
		"inventory": inventory.duplicate(true),
		"flags": flags.duplicate(true),
		"day": day,
		"time_block": time_block,
		"location_id": location_id,
		"quest_progress": quest_progress.duplicate(true)
	}

## Deserializes GameState from a Dictionary, restoring state and notifying listeners
func from_dict(data: Dictionary) -> bool:
	if data.is_empty() or not data.has("player_name") or not data.has("class_id"):
		return false
	
	player_name = data.get("player_name", "Ayo")
	class_id = data.get("class_id", "trader")
	subclass_id = data.get("subclass_id", "")
	level = int(data.get("level", 1))
	xp = int(data.get("xp", 0))
	
	stats = data.get("stats", {}).duplicate(true)
	resources = data.get("resources", {}).duplicate(true)
	
	inventory.clear()
	var raw_inv = data.get("inventory", [])
	if raw_inv is Array:
		for it in raw_inv:
			if it is Dictionary:
				inventory.append(it.duplicate(true))
	
	flags = data.get("flags", {}).duplicate(true)
	
	day = int(data.get("day", 1))
	time_block = data.get("time_block", "morning")
	location_id = data.get("location_id", "oshodi_market")
	quest_progress = data.get("quest_progress", {}).duplicate(true)
	
	player_data_changed.emit()
	resources_changed.emit(resources)
	stats_changed.emit(stats)
	time_advanced.emit(day, time_block)
	location_changed.emit(location_id)
	return true
