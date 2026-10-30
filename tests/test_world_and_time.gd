class_name TestWorldAndTime
extends RefCounted

## Unit tests for Phase 2: Time blocks, locations, activities, expenses, and events

const TimeManager = preload("res://scripts/core/time_manager.gd")
const EventManager = preload("res://scripts/core/event_manager.gd")
const ActivityManager = preload("res://scripts/core/activity_manager.gd")

static func run_tests() -> Dictionary:
	var results = { "passed": 0, "failed": 0, "messages": [] }
	
	_test_location_data(results)
	_test_event_data(results)
	_test_time_progression_and_rollover(results)
	_test_work_activity(results)
	_test_rest_activity(results)
	_test_travel_activity(results)
	_test_socialise_activity(results)
	_test_seeded_event_trigger(results)
	
	return results

static func _assert_true(condition: bool, test_name: String, results: Dictionary) -> void:
	if condition:
		results.passed += 1
		results.messages.append("  [PASS] %s" % test_name)
	else:
		results.failed += 1
		results.messages.append("  [FAIL] %s" % test_name)

static func _test_location_data(results: Dictionary) -> void:
	DataLoader.load_and_validate_all("res://data")
	var locs = DataLoader.get_all_locations()
	_assert_true(locs.size() == 4, "Exact 4 Oshodi locations loaded", results)
	
	var underbridge = DataLoader.get_location_by_id("oshodi_underbridge")
	_assert_true(not underbridge.is_empty(), "oshodi_underbridge location exists", results)
	_assert_true(underbridge.get("travel", []).size() >= 3, "Underbridge has travel routes to other locations", results)

static func _test_event_data(results: Dictionary) -> void:
	var events = DataLoader.get_all_events()
	_assert_true(events.size() >= 8, "At least 8 street events loaded in pool", results)
	
	var gridlock = DataLoader.get_event_by_id("sudden_gridlock")
	_assert_true(not gridlock.is_empty(), "sudden_gridlock event exists", results)
	_assert_true(gridlock.get("weight", 0) > 0, "Event weight is positive", results)

static func _test_time_progression_and_rollover(results: Dictionary) -> void:
	GameState.create_character("TestTime", "trader")
	GameState.day = 1
	GameState.time_block = "morning"
	
	# Advance morning -> afternoon
	TimeManager.advance_time(1)
	_assert_true(GameState.time_block == "afternoon" and GameState.day == 1, "Time advances from morning to afternoon", results)
	
	# Advance afternoon -> evening
	TimeManager.advance_time(1)
	_assert_true(GameState.time_block == "evening", "Time advances to evening", results)
	
	# Advance evening -> night
	TimeManager.advance_time(1)
	_assert_true(GameState.time_block == "night", "Time advances to night", results)
	
	# Advance night -> morning (New Day!)
	var start_naira = GameState.resources.naira
	var report = TimeManager.advance_time(1)
	_assert_true(GameState.day == 2, "Day counter advances from 1 to 2", results)
	_assert_true(GameState.time_block == "morning", "Time block resets to morning at dawn", results)
	_assert_true(report.is_new_day == true, "Rollover report confirms new day", results)
	_assert_true(GameState.resources.naira == start_naira - 1500, "Daily food expense (₦1,500) deducted overnight", results)
	_assert_true(not report.morning_news.is_empty(), "Morning news headline generated", results)

static func _test_work_activity(results: Dictionary) -> void:
	GameState.create_character("TestWorker", "trader") # Trader work income: ₦3,200
	GameState.resources.energy = 50
	var old_naira = GameState.resources.naira
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_work(rng)
	_assert_true(res.success == true, "Work activity succeeds with sufficient energy", results)
	_assert_true(GameState.resources.naira == old_naira + res.income, "Trader receives scaled work income", results)
	_assert_true(res.energy_spent == 20, "Work consumes 20 energy", results)
	_assert_true(res.xp_gained == 15, "Work grants +15 XP", results)
	
	# Test exhaustion
	GameState.resources.energy = 5
	var fail_res = ActivityManager.perform_work(rng)
	_assert_true(fail_res.success == false, "Work fails when Energy is below 10", results)

static func _test_rest_activity(results: Dictionary) -> void:
	GameState.create_character("TestRester", "trader")
	GameState.resources.energy = 40
	
	# Pass an RNG with high seed so events don't trigger during pure stat verification
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_rest(rng)
	_assert_true(res.success == true, "Rest activity succeeds", results)
	_assert_true(res.energy_restored == 35, "Rest reports +35 Energy restored", results)
	
	# Rest does not exceed max energy (100)
	ActivityManager.perform_rest(rng)
	_assert_true(GameState.resources.energy <= 100, "Rest clamps energy within max_energy 100", results)

static func _test_travel_activity(results: Dictionary) -> void:
	GameState.create_character("TestTraveler", "trader")
	GameState.location_id = "oshodi_underbridge"
	var starting_cash = GameState.resources.naira
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	# Valid travel: Underbridge to Central Market (Fare: ₦200)
	var res = ActivityManager.perform_travel("oshodi_market", rng)
	_assert_true(res.success == true, "Travel succeeds for valid connected route", results)
	_assert_true(GameState.location_id == "oshodi_market", "Location updated to oshodi_market", results)
	_assert_true(res.fare_paid == 200, "Transport fare (₦200) reported in result", results)
	
	# Invalid travel: disconnected or non-existent route
	var bad_res = ActivityManager.perform_travel("non_existent_destination", rng)
	_assert_true(bad_res.success == false, "Travel rejected for invalid destination", results)
	
	# Insufficient fare
	GameState.resources.naira = 50
	var broke_res = ActivityManager.perform_travel("oshodi_bus_terminal", rng)
	_assert_true(broke_res.success == false, "Travel rejected if player lacks fare", results)

static func _test_socialise_activity(results: Dictionary) -> void:
	GameState.create_character("TestSocial", "trader")
	GameState.resources.energy = 50
	var old_cash = GameState.resources.naira
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_socialise(rng)
	_assert_true(res.success == true, "Socialise activity succeeds", results)
	_assert_true(res.fee_paid == 500, "Socialising fee (₦500) reported in result", results)
	_assert_true(res.respect_gained == 2, "Socialising grants +2 Respect", results)

static func _test_seeded_event_trigger(results: Dictionary) -> void:
	GameState.create_character("TestSeeded", "trader")
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	
	# Roll an event with seeded RNG in morning at Underbridge
	var ev_res = EventManager.roll_and_apply_event("morning", "oshodi_underbridge", rng)
	_assert_true(ev_res.triggered == true, "Seeded event roll successfully triggers an event", results)
	_assert_true(ev_res.has("event") and not ev_res.event.is_empty(), "Event result contains valid event data", results)
	_assert_true(ev_res.event.conditions.time_blocks.has("morning"), "Event adheres to morning time_block condition", results)
