class_name TestSaveSystem
extends RefCounted

## Unit tests for Phase 5: Save/load and settings
## Tests GameState serialization, SaveSystem 3-slot save/load, autosave,
## metadata inspection, save deletion, schema versioning/migration, and settings.

static func run_tests() -> Dictionary:
	var results = { "passed": 0, "failed": 0, "messages": [] }
	
	_test_serialization_roundtrip(results)
	_test_save_and_load_slot(results)
	_test_autosave_roundtrip(results)
	_test_delete_save_slot(results)
	_test_settings_persistence(results)
	_test_save_migration_stub(results)
	
	return results

static func _assert_true(condition: bool, test_name: String, results: Dictionary) -> void:
	if condition:
		results.passed += 1
		results.messages.append("  [PASS] %s" % test_name)
	else:
		results.failed += 1
		results.messages.append("  [FAIL] %s" % test_name)

static func _test_serialization_roundtrip(results: Dictionary) -> void:
	GameState.create_character("Ibrahim", "trader")
	GameState.level = 3
	GameState.xp = 350
	GameState.resources.naira = 45000
	GameState.resources.energy = 85
	GameState.resources.respect = 24
	GameState.resources.heat = 2
	GameState.day = 5
	GameState.time_block = "evening"
	GameState.location_id = "bolade_junction"
	GameState.inventory = [
		{ "id": "tomato_crate", "quantity": 4 },
		{ "id": "energy_drink", "quantity": 2 }
	]
	GameState.flags = { "met_area_boy": true, "subclass_unlocked": false }
	
	var data = GameState.to_dict()
	_assert_true(not data.is_empty(), "GameState serialized to non-empty dictionary", results)
	_assert_true(data.get("player_name", "") == "Ibrahim", "Serialized player_name matches", results)
	_assert_true(data.get("level", 0) == 3, "Serialized level matches 3", results)
	_assert_true(data.get("resources", {}).get("naira", 0) == 45000, "Serialized naira matches 45,000", results)
	
	# Wipe GameState
	GameState.create_character("TempReset", "transporter")
	_assert_true(GameState.player_name == "TempReset", "GameState wiped to temporary character", results)
	
	# Restore from data
	var success = GameState.from_dict(data)
	_assert_true(success == true, "GameState successfully deserialized", results)
	_assert_true(GameState.player_name == "Ibrahim", "Restored player_name is Ibrahim", results)
	_assert_true(GameState.class_id == "trader", "Restored class_id is trader", results)
	_assert_true(GameState.level == 3, "Restored level is 3", results)
	_assert_true(GameState.resources.naira == 45000, "Restored naira is 45,000", results)
	_assert_true(GameState.day == 5 and GameState.time_block == "evening", "Restored day 5 evening", results)
	_assert_true(GameState.location_id == "bolade_junction", "Restored location is bolade_junction", results)
	_assert_true(GameState.inventory.size() == 2, "Restored 2 inventory item types", results)

static func _test_save_and_load_slot(results: Dictionary) -> void:
	GameState.create_character("Bimpe", "transporter")
	GameState.level = 2
	GameState.resources.naira = 18500
	GameState.flags["fuel"] = 45
	
	# Save to Slot 1
	var save_ok = SaveSystem.save_game(1)
	_assert_true(save_ok == true, "SaveSystem successfully saved to Slot 1", results)
	_assert_true(SaveSystem.has_save(1) == true, "has_save(1) confirms file exists", results)
	
	# Inspect metadata without loading full session
	var meta = SaveSystem.get_slot_metadata(1)
	_assert_true(meta.get("is_empty", true) == false, "Slot 1 metadata confirms slot is not empty", results)
	_assert_true(meta.get("player_name", "") == "Bimpe", "Slot 1 metadata player_name is Bimpe", results)
	_assert_true(meta.get("level", 0) == 2, "Slot 1 metadata level is 2", results)
	_assert_true(meta.get("naira", 0) == 18500, "Slot 1 metadata naira is 18,500", results)
	_assert_true(meta.get("save_version", 0) == SaveSystem.CURRENT_SAVE_VERSION, "Save version matches current version", results)
	
	# Mutate GameState
	GameState.resources.naira = 500
	GameState.flags["fuel"] = 5
	_assert_true(GameState.resources.naira == 500, "GameState mutated before load test", results)
	
	# Load from Slot 1
	var load_ok = SaveSystem.load_game(1)
	_assert_true(load_ok == true, "SaveSystem successfully loaded from Slot 1", results)
	_assert_true(GameState.player_name == "Bimpe", "Loaded player name is Bimpe", results)
	_assert_true(GameState.resources.naira == 18500, "Loaded naira restored to 18,500", results)
	_assert_true(int(GameState.flags.get("fuel", 0)) == 45, "Loaded fuel restored to 45", results)

static func _test_autosave_roundtrip(results: Dictionary) -> void:
	GameState.create_character("Chidi", "trader")
	GameState.day = 4
	GameState.resources.naira = 32000
	
	var auto_saved = SaveSystem.save_autosave()
	_assert_true(auto_saved == true, "Autosave saved successfully", results)
	_assert_true(SaveSystem.has_autosave() == true, "has_autosave confirms autosave file exists", results)
	
	GameState.resources.naira = 1000
	var auto_loaded = SaveSystem.load_autosave()
	_assert_true(auto_loaded == true, "Autosave loaded successfully", results)
	_assert_true(GameState.resources.naira == 32000, "Autosave restored naira to 32,000", results)

static func _test_delete_save_slot(results: Dictionary) -> void:
	GameState.create_character("Dele", "trader")
	SaveSystem.save_game(3)
	_assert_true(SaveSystem.has_save(3) == true, "Slot 3 saved before deletion test", results)
	
	var del_ok = SaveSystem.delete_save(3)
	_assert_true(del_ok == true, "SaveSystem successfully deleted Slot 3", results)
	_assert_true(SaveSystem.has_save(3) == false, "has_save(3) reports false after deletion", results)
	
	var meta = SaveSystem.get_slot_metadata(3)
	_assert_true(meta.get("is_empty", false) == true, "Metadata confirms slot 3 is empty after deletion", results)

static func _test_settings_persistence(results: Dictionary) -> void:
	var custom_settings = {
		"sfx_volume": 0.65,
		"music_volume": 0.40,
		"text_size": "large",
		"reduce_motion": true,
		"language": "en"
	}
	
	var save_res = SaveSystem.save_settings(custom_settings)
	_assert_true(save_res == true, "Settings saved to user://settings.json", results)
	
	var loaded = SaveSystem.load_settings()
	_assert_true(is_equal_approx(float(loaded.get("sfx_volume", 0.0)), 0.65), "Loaded sfx_volume matches 0.65", results)
	_assert_true(is_equal_approx(float(loaded.get("music_volume", 0.0)), 0.40), "Loaded music_volume matches 0.40", results)
	_assert_true(loaded.get("text_size", "") == "large", "Loaded text_size matches 'large'", results)
	_assert_true(loaded.get("reduce_motion", false) == true, "Loaded reduce_motion is true", results)

static func _test_save_migration_stub(results: Dictionary) -> void:
	# Simulate legacy save from version 0
	var legacy_save = {
		"save_version": 0,
		"slot": 1,
		"timestamp": "2026-10-30T12:00:00",
		"game_state": {
			"player_name": "LegacyPlayer",
			"class_id": "trader"
		}
	}
	
	var migrated = SaveSystem.migrate_save(legacy_save)
	_assert_true(migrated.get("save_version", 0) == SaveSystem.CURRENT_SAVE_VERSION, "Legacy save migrated to CURRENT_SAVE_VERSION", results)
	_assert_true(migrated.get("game_state", {}).get("player_name", "") == "LegacyPlayer", "Migrated save preserved player_name", results)
