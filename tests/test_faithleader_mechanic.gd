class_name TestFaithLeaderMechanic
extends RefCounted

## Unit tests for Phase 7: Faith Leader Class & Congregation Mechanics

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_faithleader_character_creation()
	test_faithleader_work_mechanic()
	test_community_outreach()
	test_faithleader_subclasses()
	test_faithleader_situations()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_faithleader_character_creation() -> void:
	GameState.create_character("Pastor Emmanuel", "faith_leader")
	_assert_true(GameState.class_id == "faith_leader", "Faith Leader character created successfully")
	_assert_true(GameState.resources.naira == 6000, "Starting cash is ₦6,000")
	_assert_true(GameState.stats.charisma == 5, "Base Charisma is 5")
	_assert_true(GameState.stats.street_smarts == 4, "Base Street Smarts is 4")
	_assert_true(GameState.stats.hustle == 4, "Base Hustle is 4")
	_assert_true(GameState.stats.stamina == 3, "Base Stamina is 3")
	_assert_true(GameState.stats.grit == 3, "Base Grit is 3")
	_assert_true(GameState.has_perk("blessed_words"), "Possesses 'blessed_words' perk")

func test_faithleader_work_mechanic() -> void:
	GameState.create_character("Pastor Emmanuel", "faith_leader")
	var initial_naira = GameState.resources.naira
	var initial_respect = GameState.resources.respect
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 99999
	
	var res = ActivityManager.perform_work(rng)
	_assert_true(res.get("success", false), "Sanctuary shift performed successfully")
	_assert_true(res.get("energy_spent", 0) == 20, "Work consumes standard 20 Energy")
	_assert_true(GameState.resources.naira >= initial_naira + 2500, "Naira increased by at least base ₦2,500")
	_assert_true(GameState.resources.respect > initial_respect, "Respect increased from pastoral sanctuary service")

func test_community_outreach() -> void:
	GameState.create_character("Pastor Emmanuel", "faith_leader")
	var initial_energy = GameState.resources.energy
	var initial_naira = GameState.resources.naira
	var initial_respect = GameState.resources.respect
	
	var res = FaithLeaderMechanic.organize_community_outreach()
	_assert_true(res.get("success", false), "Welfare outreach succeeded")
	_assert_true(GameState.resources.energy == initial_energy - 15, "Outreach consumes 15 Energy (100 -> 85)")
	_assert_true(GameState.resources.naira == initial_naira - 1000, "Benevolence budget (₦1,000) deducted")
	_assert_true(GameState.resources.respect >= initial_respect + 4, "Respect increased by at least +4")
	_assert_true(GameState.xp >= 25, "Outreach grants bonus XP")
	
	# Test low funds failure
	GameState.resources.naira = 200
	var poor_res = FaithLeaderMechanic.organize_community_outreach()
	_assert_true(not poor_res.get("success", true), "Outreach rejected when funds below ₦1,000")

func test_faithleader_subclasses() -> void:
	var subclasses = DataLoader.get_subclasses_for_class("faith_leader")
	_assert_true(subclasses.size() == 6, "Exactly 6 Faith Leader subclasses loaded (got %d)" % subclasses.size())
	
	var expected = ["pastor", "imam", "prophet_prayer_warrior", "evangelist", "usher_choirmaster", "traditional_priest"]
	for sc_id in expected:
		var sc = DataLoader.get_subclass_by_id(sc_id)
		_assert_true(not sc.is_empty(), "Subclass '%s' exists" % sc_id)
		_assert_true(sc.get("class_id", "") == "faith_leader", "Subclass '%s' belongs to faith_leader" % sc_id)

func test_faithleader_situations() -> void:
	var sit = DataLoader.get_situation_by_id("tenement_dispute_mediation")
	_assert_true(not sit.is_empty(), "Situation 'tenement_dispute_mediation' exists")
	_assert_true(sit.get("required_class", "") == "faith_leader", "Situation requires faith_leader")
	
	# Trader excluded
	var trader_eligible = DataLoader.get_eligible_situations("trader", "oshodi_underbridge", "morning")
	var has_sit = false
	for s in trader_eligible:
		if s.get("id", "") == "tenement_dispute_mediation":
			has_sit = true
			break
	_assert_true(not has_sit, "Trader excluded from Faith Leader situation")
