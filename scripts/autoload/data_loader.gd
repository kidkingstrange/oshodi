extends Node

## DataLoader
## Loads and validates game JSON data at startup per docs/03_DATA_SCHEMAS.md.
## Catches content errors early, reporting file, id, and field precisely.

signal data_loaded(success: bool)
signal data_validation_failed(errors: Array[String])

var classes: Dictionary = {}
var subclasses: Dictionary = {}
var economy: Dictionary = {}
var locations: Dictionary = {}
var events: Dictionary = {}
var situations: Dictionary = {}
var items: Dictionary = {}
var quests: Dictionary = {}
var npcs: Dictionary = {}
var dialogue: Dictionary = {}
var products: Array[Dictionary] = []

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
	locations.clear()
	events.clear()
	situations.clear()
	items.clear()
	quests.clear()
	npcs.clear()
	dialogue.clear()
	products.clear()
	
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
	
	# 4. Load Locations
	var locations_raw = _load_json_file(data_dir + "/locations.json")
	if locations_raw == null:
		load_errors.append("locations.json: Failed to read or parse JSON file.")
	else:
		_validate_locations(locations_raw)
	
	# 5. Load Events
	var events_raw = _load_json_file(data_dir + "/events.json")
	if events_raw == null:
		load_errors.append("events.json: Failed to read or parse JSON file.")
	else:
		_validate_events(events_raw)
	
	# 6. Load Situations
	var situations_raw = _load_json_file(data_dir + "/situations.json")
	if situations_raw == null:
		load_errors.append("situations.json: Failed to read or parse JSON file.")
	else:
		_validate_situations(situations_raw)
	
	# 7. Load Items
	var items_raw = _load_json_file(data_dir + "/items.json")
	if items_raw == null:
		load_errors.append("items.json: Failed to read or parse JSON file.")
	else:
		_validate_items(items_raw)
	
	# 8. Load Quests
	var quests_raw = _load_json_file(data_dir + "/quests.json")
	if quests_raw == null:
		load_errors.append("quests.json: Failed to read or parse JSON file.")
	else:
		_validate_quests(quests_raw)
	
	# 9. Load NPCs
	var npcs_raw = _load_json_file(data_dir + "/npcs.json")
	if npcs_raw == null:
		load_errors.append("npcs.json: Failed to read or parse JSON file.")
	else:
		_validate_npcs(npcs_raw)
	
	# 10. Load Dialogue
	var dialogue_raw = _load_json_file(data_dir + "/dialogue.json")
	if dialogue_raw == null:
		load_errors.append("dialogue.json: Failed to read or parse JSON file.")
	else:
		_validate_dialogue(dialogue_raw)
	
	# 11. Load In-App Products
	var products_raw = _load_json_file(data_dir + "/products.json")
	if products_raw != null and products_raw is Array:
		for p in products_raw:
			if p is Dictionary and p.has("id"):
				products.append(p)
	
	is_loaded = (load_errors.is_empty())
	if is_loaded:
		print("[DataLoader] Successfully loaded and validated %d classes, %d subclasses, %d locations, %d events, %d situations, %d items, %d quests, %d npcs, %d dialogue trees." % [
			classes.size(), subclasses.size(), locations.size(), events.size(), situations.size(), items.size(), quests.size(), npcs.size(), dialogue.size()
		])
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
		
		for str_field in ["name", "tagline", "signature_mechanic"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		var stats = item.get("base_stats", null)
		if not (stats is Dictionary):
			load_errors.append("%s: Missing or invalid 'base_stats' dictionary." % ctx)
		else:
			for stat_name in REQUIRED_STATS:
				var stat_val = stats.get(stat_name, null)
				if stat_val == null or not (stat_val is int or stat_val is float) or stat_val < 1:
					load_errors.append("%s: 'base_stats.%s' must be an integer >= 1." % [ctx, stat_name])
		
		var perk = item.get("passive_perk", null)
		if not (perk is Dictionary):
			load_errors.append("%s: Missing or invalid 'passive_perk' dictionary." % ctx)
		else:
			if not (perk.get("id", "") is String) or perk.get("id", "").is_empty():
				load_errors.append("%s: 'passive_perk.id' must be non-empty string." % ctx)
			if not (perk.get("text", "") is String) or perk.get("text", "").is_empty():
				load_errors.append("%s: 'passive_perk.text' must be non-empty string." % ctx)
		
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
		
		var class_id = item.get("class_id", "")
		if not (class_id is String) or class_id.is_empty():
			load_errors.append("%s: Missing or empty 'class_id' reference." % ctx)
		elif not classes.has(class_id):
			load_errors.append("%s: Referenced class_id '%s' does not exist in classes.json." % [ctx, class_id])
		
		for str_field in ["name", "fantasy", "weakness"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		var perks = item.get("perks", null)
		if not (perks is Array) or perks.is_empty():
			load_errors.append("%s: 'perks' must be a non-empty array of perks." % ctx)
		else:
			for p_idx in range(perks.size()):
				var p = perks[p_idx]
				if not (p is Dictionary) or not (p.get("id", "") is String) or not (p.get("text", "") is String):
					load_errors.append("%s: perks[%d] must have non-empty 'id' and 'text'." % [ctx, p_idx])
		
		var sit_sets = item.get("situation_sets", null)
		if not (sit_sets is Array):
			load_errors.append("%s: 'situation_sets' must be an array of strings." % ctx)
		
		subclasses[id_val] = item

## Validates locations array against schema
func _validate_locations(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("locations.json: Root must be a JSON Array of location objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "locations.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id' field." % ctx)
			continue
		
		ctx = "locations.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate location id detected." % ctx)
		seen_ids[id_val] = true
		
		for str_field in ["name", "district", "description"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		var act_list = item.get("activities", null)
		if not (act_list is Array) or act_list.is_empty():
			load_errors.append("%s: 'activities' must be a non-empty array." % ctx)
		
		var travel_list = item.get("travel", null)
		if not (travel_list is Array):
			load_errors.append("%s: 'travel' must be an array of destinations." % ctx)
		
		locations[id_val] = item

## Validates events array against schema
func _validate_events(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("events.json: Root must be a JSON Array of event objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "events.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id' field." % ctx)
			continue
		
		ctx = "events.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate event id detected." % ctx)
		seen_ids[id_val] = true
		
		for str_field in ["title", "description"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		var weight = item.get("weight", null)
		if weight == null or not (weight is int or weight is float) or weight < 1:
			load_errors.append("%s: 'weight' must be an integer >= 1." % ctx)
		
		var conditions = item.get("conditions", null)
		if not (conditions is Dictionary):
			load_errors.append("%s: 'conditions' must be a dictionary." % ctx)
		
		var effects = item.get("effects", null)
		if not (effects is Dictionary):
			load_errors.append("%s: 'effects' must be a dictionary." % ctx)
		
		events[id_val] = item

## Validates situations array against schema
func _validate_situations(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("situations.json: Root must be a JSON Array of situation objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "situations.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id' field." % ctx)
			continue
		
		ctx = "situations.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate situation id detected." % ctx)
		seen_ids[id_val] = true
		
		for str_field in ["title", "setup_text"]:
			var val = item.get(str_field, "")
			if not (val is String) or val.strip_edges().is_empty():
				load_errors.append("%s: Missing or empty required field '%s'." % [ctx, str_field])
		
		var options = item.get("options", null)
		if not (options is Array) or options.is_empty():
			load_errors.append("%s: 'options' must be a non-empty array of choices." % ctx)
		else:
			for o_idx in range(options.size()):
				var opt = options[o_idx]
				var opt_ctx = "%s options[%d]" % [ctx, o_idx]
				if not (opt is Dictionary):
					load_errors.append("%s: Expected option object." % opt_ctx)
					continue
				
				if not (opt.get("id", "") is String) or opt.get("id", "").is_empty():
					load_errors.append("%s: Missing or empty 'id' in option." % opt_ctx)
				if not (opt.get("label", "") is String) or opt.get("label", "").is_empty():
					load_errors.append("%s: Missing or empty 'label' in option." % opt_ctx)
				
				var check = opt.get("check", null)
				if check != null:
					if not (check is Dictionary):
						load_errors.append("%s: 'check' must be Dictionary or null." % opt_ctx)
					else:
						var stat = check.get("stat", "")
						if not (stat is String) or not REQUIRED_STATS.has(stat):
							load_errors.append("%s: 'check.stat' must be one of %s." % [opt_ctx, str(REQUIRED_STATS)])
						var diff = check.get("difficulty", null)
						if diff == null or not (diff is int or diff is float) or diff < 1:
							load_errors.append("%s: 'check.difficulty' must be an integer >= 1." % opt_ctx)
				
				var on_succ = opt.get("on_success", null)
				if not (on_succ is Dictionary) or not (on_succ.get("text", "") is String):
					load_errors.append("%s: 'on_success' must be Dictionary with 'text'." % opt_ctx)
		
		situations[id_val] = item

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

## Validates items array against schema
func _validate_items(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("items.json: Root must be a JSON Array.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "items.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Expected JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id'." % ctx)
			continue
		
		ctx = "items.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate item id detected." % ctx)
		seen_ids[id_val] = true
		
		for req_field in ["name", "type", "description"]:
			if not (item.get(req_field, "") is String) or item.get(req_field, "").strip_edges().is_empty():
				load_errors.append("%s: Missing or empty '%s'." % [ctx, req_field])
		
		if int(item.get("buy_price", -1)) < 0:
			load_errors.append("%s: 'buy_price' must be non-negative integer." % ctx)
		
		items[id_val] = item

## Validates quests array against schema
func _validate_quests(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("quests.json: Root must be a JSON Array of quest objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "quests.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Item must be a JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id'." % ctx)
			continue
		
		ctx = "quests.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate quest id detected." % ctx)
		seen_ids[id_val] = true
		
		for req_field in ["title", "giver", "description"]:
			if not (item.get(req_field, "") is String) or item.get(req_field, "").strip_edges().is_empty():
				load_errors.append("%s: Missing or empty '%s'." % [ctx, req_field])
		
		var steps = item.get("steps", null)
		if not (steps is Array) or steps.is_empty():
			load_errors.append("%s: 'steps' must be a non-empty Array." % ctx)
		else:
			for s_idx in range(steps.size()):
				var step = steps[s_idx]
				var s_ctx = "%s.steps[%d]" % [ctx, s_idx]
				if not (step is Dictionary):
					load_errors.append("%s: Step must be an Object." % s_ctx)
					continue
				if not (step.get("id", "") is String) or step.get("id", "").is_empty():
					load_errors.append("%s: Missing 'id'." % s_ctx)
				if not (step.get("text", "") is String) or step.get("text", "").is_empty():
					load_errors.append("%s: Missing 'text'." % s_ctx)
				if not (step.get("condition", null) is Dictionary):
					load_errors.append("%s: Missing 'condition' object." % s_ctx)
		
		if not (item.get("reward", null) is Dictionary):
			load_errors.append("%s: 'reward' must be a Dictionary." % ctx)
		
		quests[id_val] = item

## Validates npcs array against schema
func _validate_npcs(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("npcs.json: Root must be a JSON Array of npc objects.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "npcs.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Item must be a JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id'." % ctx)
			continue
		
		ctx = "npcs.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate npc id detected." % ctx)
		seen_ids[id_val] = true
		
		for req_field in ["name", "role"]:
			if not (item.get(req_field, "") is String) or item.get(req_field, "").strip_edges().is_empty():
				load_errors.append("%s: Missing or empty '%s'." % [ctx, req_field])
		
		if not (item.get("location_ids", null) is Array):
			load_errors.append("%s: 'location_ids' must be an Array." % ctx)
		if not (item.get("dialogue_ids", null) is Array):
			load_errors.append("%s: 'dialogue_ids' must be an Array." % ctx)
		
		npcs[id_val] = item

## Validates dialogue array against schema
func _validate_dialogue(raw_data: Variant) -> void:
	if not (raw_data is Array):
		load_errors.append("dialogue.json: Root must be a JSON Array of dialogue trees.")
		return
	
	var seen_ids: Dictionary = {}
	for idx in range(raw_data.size()):
		var item = raw_data[idx]
		var ctx = "dialogue.json[%d]" % idx
		if not (item is Dictionary):
			load_errors.append("%s: Item must be a JSON Object." % ctx)
			continue
		
		var id_val = item.get("id", "")
		if not (id_val is String) or id_val.strip_edges().is_empty():
			load_errors.append("%s: Missing or empty 'id'." % ctx)
			continue
		
		ctx = "dialogue.json (id: '%s')" % id_val
		if not _is_valid_id(id_val):
			load_errors.append("%s: ID must be lowercase alphanumeric with underscores." % ctx)
		
		if seen_ids.has(id_val):
			load_errors.append("%s: Duplicate dialogue id detected." % ctx)
		seen_ids[id_val] = true
		
		var lines = item.get("lines", null)
		if not (lines is Array) or lines.is_empty():
			load_errors.append("%s: 'lines' must be a non-empty Array." % ctx)
		else:
			for l_idx in range(lines.size()):
				var line_obj = lines[l_idx]
				var l_ctx = "%s.lines[%d]" % [ctx, l_idx]
				if not (line_obj is Dictionary):
					load_errors.append("%s: Line must be an Object." % l_ctx)
					continue
				if not (line_obj.get("speaker", "") is String) or line_obj.get("speaker", "").is_empty():
					load_errors.append("%s: Missing 'speaker'." % l_ctx)
				if not (line_obj.get("text", "") is String) or line_obj.get("text", "").is_empty():
					load_errors.append("%s: Missing 'text'." % l_ctx)
		
		dialogue[id_val] = item

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

func get_all_locations() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for l_id in locations:
		list.append(locations[l_id])
	return list

func get_location_by_id(loc_id: String) -> Dictionary:
	return locations.get(loc_id, {})

func get_all_events() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for e_id in events:
		list.append(events[e_id])
	return list

func get_event_by_id(event_id: String) -> Dictionary:
	return events.get(event_id, {})

func get_all_situations() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for s_id in situations:
		list.append(situations[s_id])
	return list

func get_situation_by_id(sit_id: String) -> Dictionary:
	return situations.get(sit_id, {})

func get_eligible_situations(class_id: String, location_id: String, time_block: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for s_id in situations:
		var s = situations[s_id]
		var req_class = s.get("required_class", null)
		if req_class != null and req_class != class_id:
			continue
		
		var loc_tags = s.get("location_tags", [])
		if not loc_tags.has("all") and not loc_tags.has(location_id):
			continue
		
		var valid_times = s.get("time_blocks", [])
		if not valid_times.is_empty() and not valid_times.has(time_block):
			continue
		
		list.append(s)
	return list

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

func get_work_income(class_id: String) -> int:
	var income_dict = economy.get("work_income_by_class", {})
	return income_dict.get(class_id, 2500)

func get_activity_costs() -> Dictionary:
	return economy.get("activity_costs", {
		"work_energy": 20,
		"work_xp": 15,
		"rest_energy_gain": 35,
		"socialise_naira": 500,
		"socialise_energy_gain": 10,
		"socialise_respect": 2,
		"socialise_xp": 8
	})

func get_daily_food_cost() -> int:
	var costs = economy.get("daily_costs", {})
	return costs.get("food_standard", 1500)

func get_random_morning_news(rng: RandomNumberGenerator = null) -> String:
	var news_list = economy.get("morning_street_news", [])
	if news_list.is_empty():
		return "Another busy day begins in the bustling commercial heart of Oshodi."
	var idx = 0
	if rng:
		idx = rng.randi_range(0, news_list.size() - 1)
	else:
		idx = randi() % news_list.size()
	return news_list[idx]

func get_all_items() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for i_id in items:
		list.append(items[i_id])
	return list

func get_item_by_id(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func get_xp_table() -> Array:
	return economy.get("level_xp_requirements", [0, 100, 250, 450, 700, 1000, 1400, 1900, 2500, 3200])

func get_all_quests() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for q_id in quests:
		list.append(quests[q_id])
	return list

func get_quest_by_id(quest_id: String) -> Dictionary:
	return quests.get(quest_id, {})

func get_all_npcs() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for n_id in npcs:
		list.append(npcs[n_id])
	return list

func get_npc_by_id(npc_id: String) -> Dictionary:
	return npcs.get(npc_id, {})

func get_npcs_for_location(loc_id: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for n_id in npcs:
		var n = npcs[n_id]
		var locs = n.get("location_ids", [])
		if locs.has(loc_id) or locs.has("all"):
			list.append(n)
	return list

func get_dialogue_by_id(dialogue_id: String) -> Dictionary:
	return dialogue.get(dialogue_id, {})

func get_all_products() -> Array[Dictionary]:
	return products

func get_product_by_id(prod_id: String) -> Dictionary:
	for p in products:
		if p.get("id", "") == prod_id:
			return p
	return {}
