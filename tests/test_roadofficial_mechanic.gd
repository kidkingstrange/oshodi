class_name TestRoadOfficialMechanic
extends RefCounted

## Unit tests for Phase 7: Road Official Class & Checkpoint Mechanics

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_roadofficial_character_creation()
	test_roadofficial_work_mechanic()
	test_conduct_inspection_stop()
	test_roadofficial_subclasses()
	test_roadofficial_situations()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_roadofficial_character_creation() -> void:
	GameState.create_character("Inspector Bello", "road_official")
	_assert_true(GameState.class_id == "road_official", "Road Official character created successfully")
	_assert_true(GameState.resources.naira == 10000, "Starting cash is ₦10,000")
	_assert_true(GameState.stats.charisma == 5, "Base Charisma is 5")
	_assert_true(GameState.stats.street_smarts == 4, "Base Street Smarts is 4")
	_assert_true(GameState.stats.grit == 4, "Base Grit is 4")
	_assert_true(GameState.stats.stamina == 3, "Base Stamina is 3")
	_assert_true(GameState.stats.hustle == 3, "Base Hustle is 3")
	_assert_true(GameState.has_perk("official_command"), "Possesses 'official_command' perk")

func test_roadofficial_work_mechanic() -> void:
	GameState.create_character("Inspector Bello", "road_official")
	var initial_naira = GameState.resources.naira
	var initial_respect = GameState.resources.respect
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_work(rng)
	_assert_true(res.get("success", false), "Road Official shift performed successfully")
	_assert_true(res.get("energy_spent", 0) == 20, "Work consumes standard 20 Energy")
	_assert_true(GameState.resources.naira >= initial_naira + 3000, "Naira increased by at least base ₦3,000")
	_assert_true(GameState.resources.respect > initial_respect, "Respect increased from official duty shift")

func test_conduct_inspection_stop() -> void:
	GameState.create_character("Inspector Bello", "road_official")
	var initial_energy = GameState.resources.energy
	var initial_naira = GameState.resources.naira
	
	var res = RoadOfficialMechanic.conduct_inspection_stop()
	_assert_true(res.get("success", false), "Vehicle inspection stop succeeded")
	_assert_true(GameState.resources.energy == initial_energy - 15, "Inspection stop consumes 15 Energy (100 -> 85)")
	_assert_true(GameState.resources.naira > initial_naira, "Compliance clearance fee or penalty paid")
	_assert_true(GameState.xp >= 20, "Inspection grants XP")
	
	# Exhaust character
	GameState.modify_resource("energy", -80)
	var fail_res = RoadOfficialMechanic.conduct_inspection_stop()
	_assert_true(not fail_res.get("success", true), "Inspection rejected when Energy is below 15")

func test_roadofficial_subclasses() -> void:
	var subclasses = DataLoader.get_subclasses_for_class("road_official")
	_assert_true(subclasses.size() == 6, "Exactly 6 Road Official subclasses loaded (got %d)" % subclasses.size())
	
	var expected = ["lastma_officer", "traffic_warden", "police_checkpoint_officer", "vehicle_inspector", "tow_truck_operator", "road_safety_volunteer"]
	for sc_id in expected:
		var sc = DataLoader.get_subclass_by_id(sc_id)
		_assert_true(not sc.is_empty(), "Subclass '%s' exists" % sc_id)
		_assert_true(sc.get("class_id", "") == "road_official", "Subclass '%s' belongs to road_official" % sc_id)

func test_roadofficial_situations() -> void:
	var sit = DataLoader.get_situation_by_id("one_way_contravention")
	_assert_true(not sit.is_empty(), "Situation 'one_way_contravention' exists")
	_assert_true(sit.get("required_class", "") == "road_official", "Situation requires road_official")
	
	# Trader excluded
	var trader_eligible = DataLoader.get_eligible_situations("trader", "oshodi_underbridge", "morning")
	var has_sit = false
	for s in trader_eligible:
		if s.get("id", "") == "one_way_contravention":
			has_sit = true
			break
	_assert_true(not has_sit, "Trader excluded from Road Official situation")
