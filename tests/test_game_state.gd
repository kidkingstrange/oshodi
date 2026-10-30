class_name TestGameState
extends RefCounted

## Unit tests for GameState initialization and resource manipulation

static func run_tests() -> Dictionary:
	var results = { "passed": 0, "failed": 0, "messages": [] }
	
	_test_character_creation(results)
	_test_resource_clamping(results)
	_test_stat_modification(results)
	_test_invalid_class_rejection(results)
	
	return results

static func _assert_true(condition: bool, test_name: String, results: Dictionary) -> void:
	if condition:
		results.passed += 1
		results.messages.append("  [PASS] %s" % test_name)
	else:
		results.failed += 1
		results.messages.append("  [FAIL] %s" % test_name)

static func _test_character_creation(results: Dictionary) -> void:
	DataLoader.load_and_validate_all("res://data")
	
	var success = GameState.create_character("Folake", "trader")
	_assert_true(success, "Character creation returns true for valid inputs", results)
	_assert_true(GameState.player_name == "Folake", "Player name is set correctly", results)
	_assert_true(GameState.class_id == "trader", "Class ID is set to trader", results)
	_assert_true(GameState.level == 1, "Initial level is 1", results)
	_assert_true(GameState.xp == 0, "Initial XP is 0", results)
	_assert_true(GameState.stats.hustle == 5, "Trader base hustle is 5", results)
	_assert_true(GameState.resources.energy == 100, "Initial energy is 100", results)
	_assert_true(GameState.resources.naira == 12000, "Trader starting cash is ₦12,000", results)
	_assert_true(GameState.resources.respect == 10, "Initial respect is 10", results)
	_assert_true(GameState.resources.heat == 0, "Initial heat is 0", results)
	_assert_true(GameState.has_character(), "GameState.has_character() returns true", results)

static func _test_resource_clamping(results: Dictionary) -> void:
	# Test Energy upper bound clamping (should not exceed max_energy 100)
	GameState.modify_resource("energy", 50)
	_assert_true(GameState.resources.energy == 100, "Energy does not exceed max_energy (100)", results)
	
	# Test Energy lower bound clamping (should not drop below 0)
	GameState.modify_resource("energy", -150)
	_assert_true(GameState.resources.energy == 0, "Energy clamps at 0 on massive drain", results)
	
	# Test Heat lower bound (cannot be negative)
	GameState.modify_resource("heat", -10)
	_assert_true(GameState.resources.heat == 0, "Heat clamps at 0 minimum", results)
	
	# Test Naira lower bound (cannot be negative)
	GameState.modify_resource("naira", -999999)
	_assert_true(GameState.resources.naira == 0, "Naira cannot drop below 0", results)
	
	# Reset resources for clean state
	GameState.resources.energy = 100
	GameState.resources.naira = 12000

static func _test_stat_modification(results: Dictionary) -> void:
	var starting_hustle = GameState.stats.hustle
	GameState.modify_stat("hustle", 2)
	_assert_true(GameState.stats.hustle == starting_hustle + 2, "modify_stat increases stat value", results)
	
	# Stat cannot drop below 1
	GameState.modify_stat("hustle", -100)
	_assert_true(GameState.stats.hustle == 1, "Stats cannot be reduced below 1", results)

static func _test_invalid_class_rejection(results: Dictionary) -> void:
	var bad_creation = GameState.create_character("BadPlayer", "non_existent_class_xyz")
	_assert_true(bad_creation == false, "create_character rejects unknown class ID", results)
