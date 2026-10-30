class_name TestDataLoader
extends RefCounted

## Unit tests for DataLoader schema validation

static func run_tests() -> Dictionary:
	var results = { "passed": 0, "failed": 0, "messages": [] }
	
	_test_valid_production_data(results)
	_test_broken_json_syntax(results)
	_test_missing_required_fields(results)
	_test_invalid_id_format(results)
	_test_duplicate_id(results)
	_test_bad_subclass_class_reference(results)
	_test_invalid_stats(results)
	
	return results

static func _assert_true(condition: bool, test_name: String, results: Dictionary) -> void:
	if condition:
		results.passed += 1
		results.messages.append("  [PASS] %s" % test_name)
	else:
		results.failed += 1
		results.messages.append("  [FAIL] %s" % test_name)

static func _test_valid_production_data(results: Dictionary) -> void:
	var success = DataLoader.load_and_validate_all("res://data")
	_assert_true(success, "Production JSON in res://data loads with 0 errors", results)
	_assert_true(DataLoader.classes.size() >= 6, "At least 6 classes loaded", results)
	_assert_true(DataLoader.subclasses.size() >= 12, "At least 12 subclasses loaded", results)

static func _test_broken_json_syntax(results: Dictionary) -> void:
	# Test parse error handling
	var temp_errors: Array[String] = []
	var json = JSON.new()
	var err = json.parse("{ unquoted_bad_json: 123 ")
	_assert_true(err != OK, "JSON parser catches malformed JSON syntax", results)

static func _test_missing_required_fields(results: Dictionary) -> void:
	var broken_classes = [
		{
			"id": "broken_trader",
			# Missing "name", "tagline", "signature_mechanic"
			"base_stats": { "hustle": 5, "street_smarts": 4, "charisma": 4, "stamina": 3, "grit": 3 },
			"passive_perk": { "id": "test", "text": "test" },
			"subclasses": []
		}
	]
	
	var original_errors = DataLoader.load_errors.duplicate()
	DataLoader.load_errors.clear()
	DataLoader._validate_classes(broken_classes)
	
	var has_missing_field_err = false
	for e in DataLoader.load_errors:
		if "Missing or empty required field" in e:
			has_missing_field_err = true
			break
	
	_assert_true(has_missing_field_err, "Validator catches missing required fields in class object", results)
	DataLoader.load_errors = original_errors

static func _test_invalid_id_format(results: Dictionary) -> void:
	var bad_id_classes = [
		{
			"id": "Trader With Spaces And UPPERCASE",
			"name": "Trader",
			"tagline": "Test",
			"signature_mechanic": "test",
			"base_stats": { "hustle": 5, "street_smarts": 4, "charisma": 4, "stamina": 3, "grit": 3 },
			"passive_perk": { "id": "p", "text": "t" },
			"subclasses": []
		}
	]
	
	var original_errors = DataLoader.load_errors.duplicate()
	DataLoader.load_errors.clear()
	DataLoader._validate_classes(bad_id_classes)
	
	var caught_bad_id = false
	for e in DataLoader.load_errors:
		if "ID must be lowercase alphanumeric" in e:
			caught_bad_id = true
			break
	
	_assert_true(caught_bad_id, "Validator rejects non-snake_case uppercase ID", results)
	DataLoader.load_errors = original_errors

static func _test_duplicate_id(results: Dictionary) -> void:
	var dup_classes = [
		{
			"id": "dup_class",
			"name": "Class 1",
			"tagline": "T1",
			"signature_mechanic": "m1",
			"base_stats": { "hustle": 1, "street_smarts": 1, "charisma": 1, "stamina": 1, "grit": 1 },
			"passive_perk": { "id": "p", "text": "t" },
			"subclasses": []
		},
		{
			"id": "dup_class",
			"name": "Class 2",
			"tagline": "T2",
			"signature_mechanic": "m2",
			"base_stats": { "hustle": 1, "street_smarts": 1, "charisma": 1, "stamina": 1, "grit": 1 },
			"passive_perk": { "id": "p", "text": "t" },
			"subclasses": []
		}
	]
	
	var original_errors = DataLoader.load_errors.duplicate()
	DataLoader.load_errors.clear()
	DataLoader._validate_classes(dup_classes)
	
	var caught_duplicate = false
	for e in DataLoader.load_errors:
		if "Duplicate class id detected" in e:
			caught_duplicate = true
			break
	
	_assert_true(caught_duplicate, "Validator detects and rejects duplicate class IDs", results)
	DataLoader.load_errors = original_errors

static func _test_bad_subclass_class_reference(results: Dictionary) -> void:
	var bad_subclasses = [
		{
			"id": "ghost_subclass",
			"class_id": "non_existent_class_999",
			"name": "Ghost",
			"fantasy": "Does not exist",
			"weakness": "None",
			"perks": [{ "id": "p", "text": "t" }],
			"situation_sets": []
		}
	]
	
	var original_errors = DataLoader.load_errors.duplicate()
	DataLoader.load_errors.clear()
	DataLoader._validate_subclasses(bad_subclasses)
	
	var caught_bad_ref = false
	for e in DataLoader.load_errors:
		if "does not exist in classes.json" in e:
			caught_bad_ref = true
			break
	
	_assert_true(caught_bad_ref, "Validator catches broken foreign key reference in subclass", results)
	DataLoader.load_errors = original_errors

static func _test_invalid_stats(results: Dictionary) -> void:
	var bad_stat_classes = [
		{
			"id": "zero_stat_class",
			"name": "Zero Stat",
			"tagline": "T",
			"signature_mechanic": "m",
			"base_stats": { "hustle": 0, "street_smarts": 4, "charisma": 4, "stamina": 3, "grit": 3 }, # hustle is 0
			"passive_perk": { "id": "p", "text": "t" },
			"subclasses": []
		}
	]
	
	var original_errors = DataLoader.load_errors.duplicate()
	DataLoader.load_errors.clear()
	DataLoader._validate_classes(bad_stat_classes)
	
	var caught_bad_stat = false
	for e in DataLoader.load_errors:
		if "must be an integer >= 1" in e:
			caught_bad_stat = true
			break
	
	_assert_true(caught_bad_stat, "Validator catches invalid stat value (< 1)", results)
	DataLoader.load_errors = original_errors
