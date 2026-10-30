extends Node

## DataLoader
## Loads and validates game JSON data at startup per docs/03_DATA_SCHEMAS.md.
## Catches content errors early, reporting file, id, and field precisely.

signal data_loaded(success: bool)
signal data_validation_failed(errors: Array[String])

var classes: Dictionary = {}
var subclasses: Dictionary = {}
var economy: Dictionary = {}

var is_loaded: bool = false
var load_errors: Array[String] = []

const REQUIRED_STATS: Array[String] = ["hustle", "street_smarts", "charisma", "stamina", "grit"]

func _ready() -> void:
	load_and_validate_all()

## Loads all game data from data directory and validates schemas.
func load_and_validate_all(data_dir: String = "res://data") -> bool:
	load_errors.clear()
	classes.clear()
	subclasses.clear()
	economy.clear()
	
	# 1. Load Classes
	var classes_raw = _load_json_file(data_dir + "/classes.json")
	if classes_raw == null:
		load_errors.append("classes.json: Failed to read or parse JSON file.")
	else:
		_validate_classes(classes_raw)
	
	# 2. Load Subclasses
	var subclasses_raw = _load_json_file(data_dir + "/subclasses.json")
	if subclasses_raw == null:
		load_errors.append("subclasses.json: Failed to read or parse JSON file.")
	else:
		_validate_subclasses(subclasses_raw)
	
	# 3. Load Economy
	var economy_raw = _load_json_file(data_dir + "/economy.json")
	if economy_raw == null:
		load_errors.append("economy.json: Failed to read or parse JSON file.")
	else:
		_validate_economy(economy_raw)
	
	is_loaded = (load_errors.is_empty())
	if is_loaded:
		print("[DataLoader] Successfully loaded and validated %d classes, %d subclasses." % [classes.size(), subclasses.size()])
		data_loaded.emit(true)
		return true
	else:
		printerr("[DataLoader] Data validation encountered %d error(s):" % load_errors.size())
		for err in load_errors:
			printerr("  - " + err)
		data_loaded.emit(false)
		data_validation_failed.emit(load_errors)
		return false

## Validates classes array against schema
func _validate_classes(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("classes.json: Root must be a JSON Array of class objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "classes.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id' field." % ctx)
			continue
		
		ctx = "classes.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate class id detected." % ctx)
		seen_ids[id_val] = true
		
		# Validate required string fields
		for str_field in ["name", "tagline", "signature_mechanic"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		# Validate base_stats
		var stats = item.get("base_stats", null)
		if not (stats is Dictionary):
			load_errors.append("%s: Missing or invalid 'base_stats' dictionary." % ctx)
		else:
			for stat_name in REQUIRED_STATS:
				var stat_val = stats.get(stat_name, null)
				if stat_val == null or not (stat_val is int or stat_val is float) or stat_val < 1:
					load_errors.append("%s: 'base_stats.%s' must be an integer >= 1." % [ctx, stat_name])
		
		# Validate passive_perk
		var perk = item.get("passive_perk", null)
		if not (perk is Dictionary):
			load_errors.append("%s: Missing or invalid 'passive_perk' dictionary." % ctx)
		else:
			if not (perk.get("id", "") is String) or perk.get("id", "").is_empty():
				load_errors.append("%s: 'passive_perk.id' must be non-empty string." % ctx)
			if not (perk.get("text", "") is String) or perk.get("text", "").is_empty():
				load_errors.append("%s: 'passive_perk.text' must be non-empty string." % ctx)
		
		# Validate subclasses array
		var sub_list = item.get("subclasses", null)
		if not (sub_list is Array):
			load_errors.append("%s: Missing or invalid 'subclasses' array." % ctx)
		
		classes[id_val] = item

## Validates subclasses array against schema
func _validate_subclasses(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("subclasses.json: Root must be a JSON Array of subclass objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "subclasses.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id' field." % ctx)
			continue
		
		ctx = "subclasses.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate subclass id detected." % ctx)
		seen_ids[id_val] = true
		
		# Validate class_id reference
		var class_id = item.get("class_id", "")
		if not (class_id is String) or class_id.is_empty():
			load_errors.append("%s: Missing or empty 'class_id' reference." % ctx)
		elif not classes.has(class_id):
			load_errors.append("%s: Referenced class_id '%s' does not exist in classes.json." % [ctx, class_id])
		
		# Validate required string fields
		for str_field in ["name", "fantasy", "weakness"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		# Validate perks array
		var perks = item.get("perks", null)
		if not (perks is Array) or perks.is_empty():
			load_errors.append("%s: 'perks' must be a non-empty array of perks." % ctx)
		else:
			for p_idx in range(perks.size()):
				var p = perks[p_idx]
				if not (p is Dictionary) or not (p.get("id", "") is String) or not (p.get("text", "") is String):
					load_errors.append("%s: perks[%d] must have non-empty 'id' and 'text'." % [ctx, p_idx])
		
		# Validate situation_sets
		var sit_sets = item.get("situation_sets", null)
		if not (sit_sets is Array):
			load_errors.append("%s: 'situation_sets' must be an array of strings." % ctx)
		
		subclasses[id_val] = item

## Validates economy dictionary
func _validate_economy(raw_data: Variant) -> void:
	if not (raw_data is Dictionary):
		load_errors.append("economy.json: Root must be a JSON Object.")
		return
	
	if not raw_data.has("starting_naira_by_class") or not (raw_data["starting_naira_by_class"] is Dictionary):
		load_errors.append("economy.json: Missing 'starting_naira_by_class' dictionary.")
	
	if not raw_data.has("starting_resources") or not (raw_data["starting_resources"] is Dictionary):
		load_errors.append("economy.json: Missing 'starting_resources' dictionary.")
	
	if not raw_data.has("daily_costs") or not (raw_data["daily_costs"] is Dictionary):
		load_errors.append("economy.json: Missing 'daily_costs' dictionary.")
	
	economy = raw_data

## Helper to load and parse a JSON file safely
func _load_json_file(file_path: String) -> Variant:
	if not FileAccess.file_exists(file_path):
		return null
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return null
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result != OK:
		load_errors.append("JSON parse error in '%s' (line %d): %s" % [file_path, json.get_error_line(), json.get_error_message()])
		return null
	return json.data

## Validates snake_case identifier: lowercase letters, digits, and underscores
func _is_valid_id(id_string: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[a-z0-9_]+$")
	return regex.search(id_string) != null

# --- Public Accessors ---

func get_all_classes() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for c_id in classes:
		list.append(classes[c_id])
	return list

func get_class_by_id(class_id: String) -> Dictionary:
	return classes.get(class_id, {})

func get_subclasses_for_class(class_id: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for s_id in subclasses:
		if subclasses[s_id].get("class_id", "") == class_id:
			list.append(subclasses[s_id])
	return list

func get_subclass_by_id(subclass_id: String) -> Dictionary:
	return subclasses.get(subclass_id, {})

func get_starting_naira(class_id: String) -> int:
	var starting_dict = economy.get("starting_naira_by_class", {})
	return starting_dict.get(class_id, 5000)

func get_starting_resources() -> Dictionary:
	return economy.get("starting_resources", {
		"energy": 100,
		"max_energy": 100,
		"respect": 10,
		"heat": 0
	})
