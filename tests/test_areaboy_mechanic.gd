class_name TestAreaBoyMechanic
extends RefCounted

## Unit tests for Phase 7: Area Boy Class & Turf Mechanics

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_areaboy_character_creation()
	test_turf_work_mechanic()
	test_lay_low_heat_reduction()
	test_areaboy_subclasses()
	test_areaboy_situations()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_areaboy_character_creation() -> void:
	GameState.create_character("Scorpion", "area_boy")
	_assert_true(GameState.class_id == "area_boy", "Area Boy character created successfully")
	_assert_true(GameState.resources.naira == 3000, "Starting cash is ₦3,000")
	_assert_true(GameState.stats.grit == 5, "Base Grit is 5")
	_assert_true(GameState.stats.hustle == 4, "Base Hustle is 4")
	_assert_true(GameState.resources.heat == 0, "Initial Heat is 0")
	_assert_true(GameState.resources.respect == 10, "Initial Respect is 10")

func test_turf_work_mechanic() -> void:
	GameState.create_character("Scorpion", "area_boy")
	var initial_naira = GameState.resources.naira
	var initial_heat = GameState.resources.heat
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_work(rng)
	_assert_true(res.get("success", false), "Area Boy work shift performed successfully")
	_assert_true(res.get("energy_spent", 0) == 20, "Energy spent on Area Boy work was 20")
	_assert_true(GameState.resources.naira > initial_naira, "Naira increased from turf levies")
	_assert_true(GameState.resources.heat > initial_heat, "Heat increased from street levy collection")

func test_lay_low_heat_reduction() -> void:
	GameState.create_character("Scorpion", "area_boy")
	GameState.modify_resource("heat", 6)
	_assert_true(GameState.resources.heat == 6, "Heat raised to 6 for lay low test")
	
	var res = AreaBoyMechanic.lay_low()
	_assert_true(res.get("success", false), "Lay low action succeeded")
	_assert_true(GameState.resources.heat == 3, "Heat reduced from 6 to 3")
	_assert_true(GameState.resources.energy == 90, "Energy reduced by 10 (100 -> 90)")
	
	# Lay low again to reduce to 0
	AreaBoyMechanic.lay_low()
	_assert_true(GameState.resources.heat == 0, "Heat reduced to 0 and clamps at 0")

func test_areaboy_subclasses() -> void:
	var subclasses = DataLoader.get_subclasses_for_class("area_boy")
	_assert_true(subclasses.size() == 6, "Exactly 6 Area Boy subclasses loaded in DataLoader (got %d)" % subclasses.size())
	
	var expected = ["agbero", "vigilante", "one_chance_operator", "landlords_enforcer", "pickpocket", "politicians_youth_wing"]
	for sc_id in expected:
		var sc = DataLoader.get_subclass_by_id(sc_id)
		_assert_true(not sc.is_empty(), "Subclass '%s' exists" % sc_id)
		_assert_true(sc.get("class_id", "") == "area_boy", "Subclass '%s' belongs to area_boy" % sc_id)

func test_areaboy_situations() -> void:
	var sit = DataLoader.get_situation_by_id("turf_boundary_clash")
	_assert_true(not sit.is_empty(), "Situation 'turf_boundary_clash' exists")
	_assert_true(sit.get("required_class", "") == "area_boy", "Situation requires area_boy class")
	
	# Trader cannot encounter area boy situation
	var trader_eligible = DataLoader.get_eligible_situations("trader", "oshodi_underbridge", "morning")
	var has_ab_sit = false
	for s in trader_eligible:
		if s.get("id", "") == "turf_boundary_clash":
			has_ab_sit = true
			break
	_assert_true(not has_ab_sit, "Trader is excluded from Area Boy turf situation")
