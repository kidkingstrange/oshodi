class_name TestStressAndIntegrity
extends RefCounted

## TestStressAndIntegrity
## Deep stress testing, boundary analysis, fuzzing, and system integrity verification.
## Tests 600-day multi-class Monte Carlo simulation, exhaustive traversal of all 64 situations,
## all 10 quests, all 25 dialogue trees, numerical boundaries, and rapid save/load cycles.

const ActivityManager = preload("res://scripts/core/activity_manager.gd")
const SituationResolver = preload("res://scripts/core/situation_resolver.gd")
const QuestManager = preload("res://scripts/core/quest_manager.gd")
const DialogueManager = preload("res://scripts/core/dialogue_manager.gd")
const InventoryManager = preload("res://scripts/core/inventory_manager.gd")
const ShopManager = preload("res://scripts/core/shop_manager.gd")
const TimeManager = preload("res://scripts/core/time_manager.gd")

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_multi_class_100_day_simulation()
	test_all_64_situations_exhaustive_checks()
	test_numerical_and_economic_boundaries()
	test_all_quests_and_dialogue_graph_integrity()
	test_inventory_stress_and_item_consumption()
	test_rapid_save_load_stress_cycles()
	test_mobile_back_button_stack_stress()
	test_monetization_stress_and_caps()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

## 1. 100-Day Multi-Class Monte Carlo Simulation (600 Simulated Days Total)
func test_multi_class_100_day_simulation() -> void:
	var classes = ["trader", "transporter", "area_boy", "working_class", "road_official", "faith_leader"]
	var rng = RandomNumberGenerator.new()
	rng.seed = 987654321
	
	var total_days_simulated = 0
	var zero_violations = true
	var violation_reason = ""
	
	for cls in classes:
		GameState.create_character("Stress_%s" % cls, cls)
		
		for day_idx in range(1, 101):
			total_days_simulated += 1
			
			# Run 4 time blocks per day
			for block in range(4):
				# Ensure player has energy to act; if critically low, rest
				if GameState.resources.energy < 15:
					ActivityManager.perform_rest(rng)
				else:
					var action_pick = rng.randi_range(0, 3)
					match action_pick:
						0:
							ActivityManager.perform_work(rng)
						1:
							ActivityManager.perform_rest(rng)
						2:
							var loc_id = GameState.location_id
							var loc_data = DataLoader.get_location_by_id(loc_id)
							var routes = loc_data.get("travel", [])
							if routes.size() > 0:
								var dest = routes[rng.randi_range(0, routes.size() - 1)].get("to", "")
								if dest != "" and GameState.resources.naira >= 300:
									ActivityManager.perform_travel(dest, rng)
								else:
									ActivityManager.perform_rest(rng)
							else:
								ActivityManager.perform_rest(rng)
						3:
							if GameState.resources.naira >= 500:
								ActivityManager.perform_socialise(rng)
							else:
								ActivityManager.perform_rest(rng)
				
				# Check resource invariants after every action
				if GameState.resources.naira < 0:
					zero_violations = false
					violation_reason = "Negative Naira: %d" % GameState.resources.naira
					break
				if GameState.resources.energy < 0 or GameState.resources.energy > GameState.resources.max_energy:
					zero_violations = false
					violation_reason = "Invalid Energy: %d (max: %d)" % [GameState.resources.energy, GameState.resources.max_energy]
					break
				if GameState.resources.heat < 0 or GameState.resources.heat > 100:
					zero_violations = false
					violation_reason = "Invalid Heat: %d" % GameState.resources.heat
					break
				if GameState.resources.respect < 0:
					zero_violations = false
					violation_reason = "Negative Respect: %d" % GameState.resources.respect
					break
				for stat_name in ["stamina", "grit", "street_smarts", "hustle", "charisma"]:
					if int(GameState.stats.get(stat_name, 0)) < 1:
						zero_violations = false
						violation_reason = "Stat %s dropped below 1: %d" % [stat_name, GameState.stats[stat_name]]
						break
			
			if not zero_violations:
				break
			
			# Mid-simulation save/load verification at Day 25, 50, 75
			if day_idx in [25, 50, 75]:
				var save_ok = SaveSystem.save_game(1)
				if not save_ok:
					zero_violations = false
					violation_reason = "Save failed on Day %d for %s" % [day_idx, cls]
					break
				var saved_naira = GameState.resources.naira
				var saved_energy = GameState.resources.energy
				var load_ok = SaveSystem.load_game(1)
				if not load_ok or GameState.resources.naira != saved_naira or GameState.resources.energy != saved_energy:
					zero_violations = false
					violation_reason = "Load mismatch on Day %d for %s" % [day_idx, cls]
					break
	
	_assert_true(total_days_simulated == 600, "Simulated 600 full in-game days across all 6 classes (got %d)" % total_days_simulated)
	_assert_true(zero_violations, "Zero numerical, state, or invariant violations during 600-day simulation (%s)" % (violation_reason if not zero_violations else "Clean"))

## 2. Exhaustive Traversal of All 64 Situations
func test_all_64_situations_exhaustive_checks() -> void:
	var sits = DataLoader.situations
	_assert_true(sits.size() == 64, "Exactly 64 situations loaded in pool (got %d)" % sits.size())
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	
	var all_resolved_cleanly = true
	var bad_situation_id = ""
	var bad_option_id = ""
	var error_details = ""
	var total_options_tested = 0
	
	for sit_id in sits:
		var sit = sits[sit_id]
		var options = sit.get("options", [])
		if options.is_empty():
			all_resolved_cleanly = false
			bad_situation_id = sit_id
			error_details = "Situation has 0 options"
			break
		
		for opt in options:
			total_options_tested += 1
			var opt_id = opt.get("id", "")
			if opt_id == "":
				all_resolved_cleanly = false
				bad_situation_id = sit_id
				error_details = "Option has empty id"
				break
			
			# Check required stat existence if check is defined
			var check = opt.get("check", null)
			if check != null and check is Dictionary:
				var stat_key = check.get("stat", "")
				if not GameState.stats.has(stat_key):
					all_resolved_cleanly = false
					bad_situation_id = sit_id
					bad_option_id = opt_id
					error_details = "Option requires non-existent stat: '%s'" % stat_key
					break
			
			# Test resolution with low stats
			GameState.create_character("TestLow", "trader")
			for s in GameState.stats:
				GameState.stats[s] = 1
			var res_low = SituationResolver.resolve_option(sit, opt_id, rng)
			if not res_low.get("success", false) or res_low.get("result_text", "") == "":
				all_resolved_cleanly = false
				bad_situation_id = sit_id
				bad_option_id = opt_id
				error_details = "Failed low-stat resolution"
				break
			
			# Test resolution with high stats
			for s in GameState.stats:
				GameState.stats[s] = 10
			var res_high = SituationResolver.resolve_option(sit, opt_id, rng)
			if not res_high.get("success", false) or res_high.get("result_text", "") == "":
				all_resolved_cleanly = false
				bad_situation_id = sit_id
				bad_option_id = opt_id
				error_details = "Failed high-stat resolution"
				break
		
		if not all_resolved_cleanly:
			break
	
	_assert_true(all_resolved_cleanly, "All %d situation options across 64 situations resolved cleanly without error (%s, %s: %s)" % [
		total_options_tested, bad_situation_id, bad_option_id, error_details
	])

## 3. Numerical & Economic Boundaries
func test_numerical_and_economic_boundaries() -> void:
	GameState.create_character("BoundaryTester", "trader")
	
	# Test 1: Zero Naira Boundary
	GameState.resources.naira = 0
	GameState.modify_resource("naira", -5000)
	_assert_true(GameState.resources.naira == 0, "Naira strictly clamped to 0 on negative deduction")
	
	# Test 2: Extreme High Naira (₦500,000,000)
	GameState.resources.naira = 500000000
	var formatted = GameState.format_naira(GameState.resources.naira)
	_assert_true(formatted == "₦500,000,000", "Extreme high wealth formatted correctly (%s)" % formatted)
	
	# Test 3: Zero Energy & Forced Rest Clinic Recovery
	GameState.resources.naira = 2500
	GameState.resources.energy = 5
	GameState.modify_resource("energy", -20)
	_assert_true(GameState.resources.energy == 0, "Energy strictly clamped to 0 on negative drain")
	
	# Trigger forced rest via Situation with energy 0
	var test_sit = {
		"id": "exhaustion_test",
		"options": [
			{
				"id": "opt_drain",
				"on_success": { "text": "Drained", "effects": { "energy": -10 } }
			}
		]
	}
	var ex_res = SituationResolver.resolve_option(test_sit, "opt_drain")
	_assert_true(ex_res.get("exhaustion_triggered", false), "Exhaustion recovery triggered at 0 energy")
	_assert_true(GameState.resources.energy == 30, "Exhaustion restored +30 baseline energy")
	_assert_true(GameState.resources.naira == 1500, "Exhaustion clinic fee deducted (2500 - 1000 = 1500)")
	
	# Test 4: Heat Clamping (0 to 100)
	GameState.modify_resource("heat", 200)
	_assert_true(GameState.resources.heat == 100, "Heat clamped at maximum 100")
	GameState.modify_resource("heat", -500)
	_assert_true(GameState.resources.heat == 0, "Heat clamped at minimum 0")
	
	# Test 5: Stat Bounds (clamped >= 1)
	GameState.modify_stat("stamina", -20)
	_assert_true(GameState.stats.stamina == 1, "Stamina stat cannot be reduced below 1")

## 4. Quests & Dialogue Graph Integrity
func test_all_quests_and_dialogue_graph_integrity() -> void:
	GameState.create_character("QuestTester", "trader")
	var quests = DataLoader.quests
	_assert_true(quests.size() >= 10, "At least 10 quests loaded (got %d)" % quests.size())
	
	var quests_all_valid = true
	var failed_quest_id = ""
	
	for q_id in quests:
		var q = quests[q_id]
		var req_class = q.get("required_class", null)
		if req_class != null:
			GameState.class_id = req_class
		else:
			GameState.class_id = "trader"
		
		# Start quest
		var started = QuestManager.start_quest(q_id)
		if not started or not QuestManager.is_quest_active(q_id):
			quests_all_valid = false
			failed_quest_id = "start_%s" % q_id
			break
		
		# Fulfill potential conditions
		GameState.resources.naira = 500000
		GameState.resources.respect = 100
		GameState.level = 10
		GameState.resources.heat = 0
		InventoryManager.add_item("generator_parts", 5)
		
		# Complete quest if conditions met
		if QuestManager.is_step_fulfilled(q_id):
			var comp_res = QuestManager.complete_quest(q_id)
			if comp_res.is_empty() or not QuestManager.is_quest_completed(q_id):
				quests_all_valid = false
				failed_quest_id = "complete_%s" % q_id
				break
	
	_assert_true(quests_all_valid, "All %d quests started and evaluated successfully (%s)" % [quests.size(), failed_quest_id if not quests_all_valid else "Clean"])
	
	# Dialogue Graph Traversal
	var dialogues = DataLoader.dialogue
	_assert_true(dialogues.size() >= 25, "At least 25 dialogue trees loaded (got %d)" % dialogues.size())
	
	var dialogue_valid = true
	var bad_tree_id = ""
	var bad_opt_label = ""
	
	for d_id in dialogues:
		var tree = dialogues[d_id]
		var lines = tree.get("lines", [])
		if lines.is_empty():
			dialogue_valid = false
			bad_tree_id = d_id
			break
		
		var options = tree.get("options", [])
		for opt in options:
			var nxt_id = opt.get("next_dialogue_id", null)
			if nxt_id != null and nxt_id != "" and not dialogues.has(nxt_id):
				dialogue_valid = false
				bad_tree_id = d_id
				bad_opt_label = opt.get("label", "")
				break
		if not dialogue_valid:
			break
	
	_assert_true(dialogue_valid, "All 25 dialogue trees have valid lines and branching targets (%s: %s)" % [bad_tree_id, bad_opt_label])

## 5. Inventory Stress & Item Consumption
func test_inventory_stress_and_item_consumption() -> void:
	GameState.create_character("InvTester", "trader")
	GameState.inventory.clear()
	GameState.resources.naira = 500000
	
	# Trader max weight is 20 kg. "rice_bag_small" weight is 5 kg.
	# Fill inventory to 20 kg with 4 rice bags
	InventoryManager.add_item("rice_bag_small", 4) # 20 kg
	_assert_true(InventoryManager.get_total_weight() == 20, "Inventory weight reached max limit (20 kg)")
	
	# Attempt to buy another item via ShopManager -> should be rejected by weight check
	var buy_overflow = ShopManager.buy_item("rice_bag_small", 1)
	_assert_true(not buy_overflow.get("success", true), "Shop rejects item purchase when exceeding max weight")
	
	# Consume items test
	GameState.inventory.clear()
	var all_items = DataLoader.get_all_items()
	for it in all_items:
		var it_id = it.get("id", "")
		if it.get("type", "") == "consumable":
			InventoryManager.add_item(it_id, 2)
			var cur_count = InventoryManager.get_item_count(it_id)
			_assert_true(cur_count == 2, "Consumable '%s' added successfully (count: 2)" % it_id)
			
			# Consume one
			var consume_res = InventoryManager.use_consumable(it_id)
			_assert_true(consume_res.get("success", false), "Consumable '%s' consumed successfully" % it_id)
			_assert_true(InventoryManager.get_item_count(it_id) == 1, "Item count decremented to 1")

## 6. Rapid Save/Load Stress Cycles & Corruption Resistance
func test_rapid_save_load_stress_cycles() -> void:
	GameState.create_character("SaveStress", "trader")
	var cycles_passed = true
	var error_msg = ""
	
	for i in range(1, 31):
		var slot = (i % 3) + 1
		GameState.day = i
		GameState.resources.naira = 10000 + (i * 250)
		GameState.resources.energy = 20 + (i % 80)
		
		var save_res = SaveSystem.save_game(slot)
		if not save_res:
			cycles_passed = false
			error_msg = "Save failed on cycle %d (slot %d)" % [i, slot]
			break
		
		# Tamper in-memory state before loading
		GameState.resources.naira = 0
		GameState.day = 999
		
		var load_res = SaveSystem.load_game(slot)
		if not load_res or GameState.day != i or GameState.resources.naira != (10000 + (i * 250)):
			cycles_passed = false
			error_msg = "Load mismatch on cycle %d (slot %d)" % [i, slot]
			break
	
	_assert_true(cycles_passed, "Completed 30 rapid save/load cycles across slots 1-3 without corruption (%s)" % error_msg)
	
	# Corruption Resistance Test: Load corrupted data
	var corrupted_loaded = SaveSystem.load_from_dict({"corrupted_key": 12345})
	_assert_true(not corrupted_loaded, "SaveSystem rejects malformed save dictionary safely without crash")

## 7. Mobile Back Button Stack Stress
func test_mobile_back_button_stack_stress() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	var mm = tree.root.get_node_or_null("MobileManager")
	_assert_true(mm != null, "MobileManager singleton available for modal stack stress")
	if not mm:
		return
	
	# Clean existing stack
	mm.clear_modal_stack()
	
	# Push 25 dummy modal controls
	var dummies: Array[Control] = []
	for i in range(25):
		var ctrl = Control.new()
		ctrl.visible = true
		dummies.append(ctrl)
		mm.push_modal(ctrl)
	
	_assert_true(mm.modal_stack.size() == 25, "Successfully pushed 25 modals to modal stack")
	
	# Pop all 25 with back actions
	for i in range(25):
		mm.handle_back_action()
	
	_assert_true(mm.modal_stack.is_empty(), "All 25 modals popped cleanly via back button")
	
	# Test stack underflow immunity (pressing back with 0 modals open)
	for i in range(10):
		mm.handle_back_action()
	_assert_true(mm.modal_stack.is_empty(), "Stack underflow calls handled safely without crashing")
	
	for d in dummies:
		d.free()

## 8. Monetization Stress & Ad Caps
func test_monetization_stress_and_caps() -> void:
	GameState.create_character("AdStress", "trader")
	var saved_owned = Monetization.owned_products.duplicate()
	Monetization.owned_products.clear()
	Monetization.is_offline_override = false
	Monetization.daily_ad_views = 0
	
	var successful_ads = 0
	var rejected_ads = 0
	
	for i in range(10):
		if Monetization.can_show_rewarded_ad():
			Monetization.show_rewarded_ad("energy_boost")
			successful_ads += 1
		else:
			rejected_ads += 1
	
	_assert_true(successful_ads == Monetization.MAX_DAILY_ADS, "Exactly %d ads permitted by daily cap (got %d)" % [Monetization.MAX_DAILY_ADS, successful_ads])
	_assert_true(rejected_ads == 5, "Remaining 5 ads rejected by daily cap")
	
	# Rapid purchase test
	Monetization.purchase("remove_ads")
	_assert_true(Monetization.ads_removed(), "Purchased remove_ads entitlement verified")
	_assert_true(FileAccess.file_exists(Monetization.ENTITLEMENTS_FILE), "Entitlements cache file persisted reliably")
	
	# Restore initial state
	Monetization.owned_products = saved_owned
