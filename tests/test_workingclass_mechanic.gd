class_name TestWorkingClassMechanic
extends RefCounted

## Unit tests for Phase 7: Working Class & Overtime Mechanics

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_workingclass_character_creation()
	test_workingclass_work_mechanic()
	test_overtime_mechanic()
	test_workingclass_subclasses()
	test_workingclass_situations()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_workingclass_character_creation() -> void:
	GameState.create_character("Dele", "working_class")
	_assert_true(GameState.class_id == "working_class", "Working Class character created successfully")
	_assert_true(GameState.resources.naira == 15000, "Starting cash is ₦15,000")
	_assert_true(GameState.stats.stamina == 5, "Base Stamina is 5")
	_assert_true(GameState.stats.grit == 4, "Base Grit is 4")
	_assert_true(GameState.stats.hustle == 4, "Base Hustle is 4")
	_assert_true(GameState.has_perk("steady_hands"), "Possesses 'steady_hands' perk")

func test_workingclass_work_mechanic() -> void:
	GameState.create_character("Dele", "working_class")
	var initial_naira = GameState.resources.naira
	var initial_respect = GameState.resources.respect
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_work(rng)
	_assert_true(res.get("success", false), "Working Class shift performed successfully")
	# Steady hands reduces energy cost from 20 to 16
	_assert_true(res.get("energy_spent", 0) == 16, "Energy spent on shift was 16 via Steady Hands perk")
	_assert_true(GameState.resources.naira >= initial_naira + 3500, "Naira increased by at least base ₦3,500")
	_assert_true(GameState.resources.respect > initial_respect, "Respect increased from honest shift")

func test_overtime_mechanic() -> void:
	GameState.create_character("Dele", "working_class")
	var initial_naira = GameState.resources.naira
	var initial_energy = GameState.resources.energy
	
	var res = WorkingClassMechanic.request_overtime()
	_assert_true(res.get("success", false), "Overtime shift completed successfully")
	_assert_true(res.income > 5000, "Overtime yields substantial payout (got %d)" % res.income)
	_assert_true(GameState.resources.energy == initial_energy - 25, "Overtime energy cost is 25 with Steady Hands (100 -> 75)")
	_assert_true(GameState.xp >= 25, "Overtime grants bonus XP")
	
	# Exhaust character
	GameState.modify_resource("energy", -70)
	var fail_res = WorkingClassMechanic.request_overtime()
	_assert_true(not fail_res.get("success", true), "Overtime rejected when energy is too low")

func test_workingclass_subclasses() -> void:
	var subclasses = DataLoader.get_subclasses_for_class("working_class")
	_assert_true(subclasses.size() == 6, "Exactly 6 Working Class subclasses loaded (got %d)" % subclasses.size())
	
	var expected = ["mechanic", "factory_hand", "bank_clerk", "security_guard", "generator_repairer", "teacher_nurse"]
	for sc_id in expected:
		var sc = DataLoader.get_subclass_by_id(sc_id)
		_assert_true(not sc.is_empty(), "Subclass '%s' exists" % sc_id)
		_assert_true(sc.get("class_id", "") == "working_class", "Subclass '%s' belongs to working_class" % sc_id)

func test_workingclass_situations() -> void:
	var sit = DataLoader.get_situation_by_id("emergency_generator_repair")
	_assert_true(not sit.is_empty(), "Situation 'emergency_generator_repair' exists")
	_assert_true(sit.get("required_class", "") == "working_class", "Situation requires working_class")
	
	# Trader excluded
	var trader_eligible = DataLoader.get_eligible_situations("trader", "oshodi_underbridge", "morning")
	var has_sit = false
	for s in trader_eligible:
		if s.get("id", "") == "emergency_generator_repair":
			has_sit = true
			break
	_assert_true(not has_sit, "Trader excluded from Working Class situation")
