extends Node

## SaveSystem
## Manages game saves across 3 slots and an autosave slot, handles save schema
## versioning, migrations, settings persistence, and mobile lifecycle pause events.

signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)
signal settings_changed(settings: Dictionary)

const CURRENT_SAVE_VERSION: int = 1
const MAX_SLOTS: int = 3
const SAVE_DIR: String = "user://saves"
const SETTINGS_FILE: String = "user://settings.json"

var settings: Dictionary = {
	"sfx_volume": 0.8,
	"music_volume": 0.8,
	"text_size": "standard",
	"reduce_motion": false,
	"language": "en"
}

func _ready() -> void:
	_ensure_save_dir()
	load_settings()
	print("[SaveSystem] Autoload initialized.")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if GameState.has_character():
			print("[SaveSystem] App paused/backgrounded. Performing autosave...")
			save_autosave()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func _get_slot_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]

func _get_autosave_path() -> String:
	return "%s/autosave.json" % SAVE_DIR

## Saves the active game session to the specified slot (1 to 3)
func save_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		printerr("[SaveSystem] Invalid save slot: %d" % slot)
		save_completed.emit(slot, false)
		return false
	
	_ensure_save_dir()
	var path = _get_slot_path(slot)
	var success = _write_save_file(path, slot)
	save_completed.emit(slot, success)
	return success

## Loads a game session from the specified slot (1 to 3)
func load_game(slot: int) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		printerr("[SaveSystem] Invalid load slot: %d" % slot)
		load_completed.emit(slot, false)
		return false
	
	var path = _get_slot_path(slot)
	var success = _read_and_apply_save(path)
	load_completed.emit(slot, success)
	return success

## Whether a valid save file exists for the slot
func has_save(slot: int) -> bool:
	if slot < 1 or slot > MAX_SLOTS:
		return false
	return FileAccess.file_exists(_get_slot_path(slot))

## Deletes the save file in the specified slot
func delete_save(slot: int) -> bool:
	if not has_save(slot):
		return false
	var path = _get_slot_path(slot)
	var err = DirAccess.remove_absolute(path)
	return (err == OK)

## Returns metadata preview for a save slot (for UI display)
func get_slot_metadata(slot: int) -> Dictionary:
	var path = _get_slot_path(slot)
	if not FileAccess.file_exists(path):
		return { "is_empty": true }
	
	var raw = _read_json_file(path)
	if raw.is_empty():
		return { "is_empty": true, "corrupted": true }
	
	var state_data = raw.get("game_state", {})
	return {
		"is_empty": false,
		"player_name": state_data.get("player_name", "Unknown"),
		"class_id": state_data.get("class_id", "trader"),
		"subclass_id": state_data.get("subclass_id", ""),
		"level": int(state_data.get("level", 1)),
		"day": int(state_data.get("day", 1)),
		"time_block": state_data.get("time_block", "morning"),
		"naira": int(state_data.get("resources", {}).get("naira", 0)),
		"timestamp": raw.get("timestamp", ""),
		"save_version": int(raw.get("save_version", 1))
	}

## Performs an end-of-day or background autosave
func save_autosave() -> bool:
	if not GameState.has_character():
		return false
	_ensure_save_dir()
	var path = _get_autosave_path()
	return _write_save_file(path, 0)

## Loads the autosave file if present
func load_autosave() -> bool:
	var path = _get_autosave_path()
	return _read_and_apply_save(path)

func has_autosave() -> bool:
	return FileAccess.file_exists(_get_autosave_path())

## Migrates old save versions forward to CURRENT_SAVE_VERSION
func migrate_save(data: Dictionary) -> Dictionary:
	var ver = int(data.get("save_version", 1))
	if ver == CURRENT_SAVE_VERSION:
		return data
	
	# Stub for future versions (e.g. migration from v1 to v2)
	# if ver < 2:
	#     data["game_state"]["new_field"] = "default_value"
	data["save_version"] = CURRENT_SAVE_VERSION
	return data

func _write_save_file(file_path: String, slot_id: int) -> bool:
	var payload = {
		"save_version": CURRENT_SAVE_VERSION,
		"slot": slot_id,
		"timestamp": Time.get_datetime_string_from_system(),
		"game_state": GameState.to_dict()
	}
	
	var json_str = JSON.stringify(payload, "\t")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		printerr("[SaveSystem] Failed to open save path for write: %s (Error: %d)" % [file_path, FileAccess.get_open_error()])
		return false
	
	file.store_string(json_str)
	file.close()
	print("[SaveSystem] Saved game successfully to %s" % file_path)
	return true

func _read_and_apply_save(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		printerr("[SaveSystem] Save file does not exist: %s" % file_path)
		return false
	
	var data = _read_json_file(file_path)
	if data.is_empty():
		printerr("[SaveSystem] Save file is empty or corrupted: %s" % file_path)
		return false
	
	# Apply migration if needed
	data = migrate_save(data)
	var state_data = data.get("game_state", {})
	var success = GameState.from_dict(state_data)
	if success:
		print("[SaveSystem] Loaded game successfully from %s" % file_path)
	return success

func _read_json_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	var text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	if json.data is Dictionary:
		return json.data
	return {}

# --- Settings Persistence ---

func load_settings() -> Dictionary:
	if FileAccess.file_exists(SETTINGS_FILE):
		var saved = _read_json_file(SETTINGS_FILE)
		if not saved.is_empty():
			for k in saved:
				settings[k] = saved[k]
	return settings

func save_settings(new_settings: Dictionary = {}) -> bool:
	if not new_settings.is_empty():
		for k in new_settings:
			settings[k] = new_settings[k]
	
	var json_str = JSON.stringify(settings, "\t")
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(json_str)
	file.close()
	settings_changed.emit(settings)
	return true
