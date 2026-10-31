extends Control

## TestRunner
## Executes all unit test suites (TestDataLoader, TestGameState) and displays the results.

const TestDataLoader = preload("res://tests/test_data_loader.gd")
const TestGameState = preload("res://tests/test_game_state.gd")
const TestWorldAndTime = preload("res://tests/test_world_and_time.gd")
const TestSituations = preload("res://tests/test_situations.gd")
const TestClassMechanics = preload("res://tests/test_class_mechanics.gd")
const TestSaveSystem = preload("res://tests/test_save_system.gd")
const TestContentAndQuests = preload("res://tests/test_content_and_quests.gd")
const TestAreaBoyMechanic = preload("res://tests/test_areaboy_mechanic.gd")
const TestWorkingClassMechanic = preload("res://tests/test_workingclass_mechanic.gd")

@onready var output_label: Label = %OutputLabel
@onready var summary_label: Label = %SummaryLabel
@onready var run_again_button: Button = %RunAgainButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	run_again_button.pressed.connect(_run_all_tests)
	back_button.pressed.connect(_on_back_pressed)
	_run_all_tests()

func _run_all_tests() -> void:
	var total_passed = 0
	var total_failed = 0
	var all_messages: Array[String] = []
	
	all_messages.append("=== RUNNING TEST SUITES ===")
	
	# Suite 1: DataLoader tests
	all_messages.append("\n[Suite: DataLoader Validation]")
	var dl_res = TestDataLoader.run_tests()
	total_passed += dl_res.passed
	total_failed += dl_res.failed
	for msg in dl_res.messages:
		all_messages.append(msg)
	
	# Suite 2: GameState tests
	all_messages.append("\n[Suite: GameState Initialization & Resources]")
	var gs_res = TestGameState.run_tests()
	total_passed += gs_res.passed
	total_failed += gs_res.failed
	for msg in gs_res.messages:
		all_messages.append(msg)
	
	# Suite 3: World, Time, Activities & Events (Phase 2)
	all_messages.append("\n[Suite: World, Time, Activities & Events (Phase 2)]")
	var wt_res = TestWorldAndTime.run_tests()
	total_passed += wt_res.passed
	total_failed += wt_res.failed
	for msg in wt_res.messages:
		all_messages.append(msg)
	
	# Suite 4: Situations & Conflict System (Phase 3)
	all_messages.append("\n[Suite: Situations & Conflict System (Phase 3)]")
	var sit_res = TestSituations.run_tests()
	total_passed += sit_res.passed
	total_failed += sit_res.failed
	for msg in sit_res.messages:
		all_messages.append(msg)
	
	# Suite 5: Class Mechanics, Progression & Shop (Phase 4)
	all_messages.append("\n[Suite: Class Mechanics, Progression & Shop (Phase 4)]")
	var cm_res = TestClassMechanics.run_tests()
	total_passed += cm_res.passed
	total_failed += cm_res.failed
	for msg in cm_res.messages:
		all_messages.append(msg)
	
	# Suite 6: SaveSystem, Settings & Migrations (Phase 5)
	all_messages.append("\n[Suite: SaveSystem, Settings & Migrations (Phase 5)]")
	var ss_res = TestSaveSystem.run_tests()
	total_passed += ss_res.passed
	total_failed += ss_res.failed
	for msg in ss_res.messages:
		all_messages.append(msg)
	
	# Suite 7: Content Expansion, Quests, NPCs, Dialogue & Audio (Phase 6)
	all_messages.append("\n[Suite: Content Expansion, Quests, NPCs, Dialogue & Audio (Phase 6)]")
	var cq_test = TestContentAndQuests.new()
	cq_test.run_all()
	total_passed += cq_test.passed_count
	total_failed += cq_test.failed_count
	for msg in cq_test.messages:
		all_messages.append(msg)
	
	# Suite 8: Area Boy Class & Turf Mechanics (Phase 7A)
	all_messages.append("\n[Suite: Area Boy Class & Turf Mechanics (Phase 7A)]")
	var ab_test = TestAreaBoyMechanic.new()
	ab_test.run_all()
	total_passed += ab_test.passed_count
	total_failed += ab_test.failed_count
	for msg in ab_test.messages:
		all_messages.append(msg)
	
	# Suite 9: Working Class & Overtime Mechanics (Phase 7B)
	all_messages.append("\n[Suite: Working Class & Overtime Mechanics (Phase 7B)]")
	var wc_test = TestWorkingClassMechanic.new()
	wc_test.run_all()
	total_passed += wc_test.passed_count
	total_failed += wc_test.failed_count
	for msg in wc_test.messages:
		all_messages.append(msg)
	
	# Summary
	all_messages.append("\n===========================")
	var summary_text = "Results: %d Passed, %d Failed" % [total_passed, total_failed]
	all_messages.append(summary_text)
	
	for line in all_messages:
		print(line)
	
	var file = FileAccess.open("res://tests/test_results.txt", FileAccess.WRITE)
	if file:
		file.store_string("\n".join(all_messages))
		file.close()
	
	if output_label:
		output_label.text = "\n".join(all_messages)
	
	if summary_label:
		if total_failed == 0:
			summary_label.text = "ALL TESTS PASSED (%d/%d)" % [total_passed, total_passed]
			summary_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
		else:
			summary_label.text = "TEST FAILURES DETECTED: %d failed" % total_failed
			summary_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4, 1))
	
	if DisplayServer.get_name() == "headless":
		get_tree().quit(total_failed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
