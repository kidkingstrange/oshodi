class_name TestContentAndQuests
extends RefCounted

## Unit tests for Phase 6: Expanded Content, Quests, NPCs, Dialogue, and Audio

var passed_count: int = 0
var failed_count: int = 0
var messages: Array[String] = []

func run_all() -> bool:
	passed_count = 0
	failed_count = 0
	messages.clear()
	
	test_data_loader_content_counts()
	test_situations_expansion()
	test_npcs_and_dialogue_structure()
	test_quest_manager_lifecycle()
	test_dialogue_manager_effects()
	test_sound_manager_audio()
	
	return failed_count == 0

func _assert_true(cond: bool, msg: String) -> void:
	if cond:
		passed_count += 1
		messages.append("  [PASS] " + msg)
	else:
		failed_count += 1
		messages.append("  [FAIL] " + msg)

func test_data_loader_content_counts() -> void:
	var dl = DataLoader
	dl.load_and_validate_all()
	_assert_true(dl.load_errors.is_empty(), "DataLoader has 0 validation errors with Phase 6 content")
	_assert_true(dl.situations.size() >= 40, "At least 40 situations loaded in DataLoader (got %d)" % dl.situations.size())
	_assert_true(dl.quests.size() >= 10, "At least 10 quests loaded in DataLoader (got %d)" % dl.quests.size())
	_assert_true(dl.npcs.size() >= 8, "At least 8 NPCs loaded in DataLoader (got %d)" % dl.npcs.size())
	_assert_true(dl.dialogue.size() >= 15, "At least 15 dialogue trees loaded (got %d)" % dl.dialogue.size())

func test_situations_expansion() -> void:
	var trailer_sit = DataLoader.get_situation_by_id("broken_down_trailer")
	_assert_true(not trailer_sit.is_empty(), "Situation 'broken_down_trailer' exists")
	_assert_true(trailer_sit.get("options", []).size() >= 2, "Situation has at least 2 options")
	
	var pepper_sit = DataLoader.get_situation_by_id("heavy_cargo_overload")
	_assert_true(not pepper_sit.is_empty(), "Transporter situation 'heavy_cargo_overload' exists")
	_assert_true(pepper_sit.get("required_class", "") == "transporter", "Situation requires transporter class")

func test_npcs_and_dialogue_structure() -> void:
	var landlord = DataLoader.get_npc_by_id("npc_baba_landlord")
	_assert_true(not landlord.is_empty(), "NPC 'npc_baba_landlord' exists")
	_assert_true(landlord.get("role", "") == "Compound Landlord", "Landlord role is Compound Landlord")
	
	var starting_dia = DialogueManager.get_starting_dialogue_for_npc("npc_baba_landlord")
	_assert_true(not starting_dia.is_empty(), "Starting dialogue for landlord resolved")
	_assert_true(starting_dia.get("id", "") == "landlord_greeting", "Landlord starting dialogue is 'landlord_greeting'")
	
	var loc_npcs = DataLoader.get_npcs_for_location("bolade_junction")
	_assert_true(loc_npcs.size() >= 2, "Bolade Junction has at least 2 local NPCs")

func test_quest_manager_lifecycle() -> void:
	GameState.create_character("QuestTester", "trader")
	GameState.quest_progress.clear()
	
	_assert_true(not QuestManager.is_quest_active("rent_is_due"), "Quest 'rent_is_due' initially inactive")
	_assert_true(not QuestManager.is_quest_completed("rent_is_due"), "Quest 'rent_is_due' initially not completed")
	
	var started = QuestManager.start_quest("rent_is_due")
	_assert_true(started, "Successfully started quest 'rent_is_due'")
	_assert_true(QuestManager.is_quest_active("rent_is_due"), "Quest 'rent_is_due' is now active")
	
	# Initial trader cash is 12,000, rent requires 25,000
	_assert_true(not QuestManager.is_step_fulfilled("rent_is_due"), "Quest condition not yet fulfilled at ₦12,000")
	
	# Increase cash to 26,000
	GameState.modify_resource("naira", 14000)
	_assert_true(QuestManager.is_step_fulfilled("rent_is_due"), "Quest condition fulfilled after reaching ₦26,000")
	
	var old_respect = GameState.resources.respect
	var old_xp = GameState.xp
	var res = QuestManager.complete_quest("rent_is_due")
	_assert_true(not res.is_empty(), "Quest 'rent_is_due' completed successfully")
	_assert_true(QuestManager.is_quest_completed("rent_is_due"), "Quest 'rent_is_due' marked as completed")
	_assert_true(not QuestManager.is_quest_active("rent_is_due"), "Quest 'rent_is_due' no longer active")
	_assert_true(GameState.resources.respect > old_respect, "Player respect increased from quest reward")
	_assert_true(GameState.xp > old_xp, "Player XP increased from quest reward")
	
	# Cannot restart completed quest
	var re_start = QuestManager.start_quest("rent_is_due")
	_assert_true(not re_start, "Cannot restart already completed quest")

func test_dialogue_manager_effects() -> void:
	GameState.create_character("DialogueTester", "trader")
	var initial_respect = GameState.resources.respect
	
	var dummy_opt = {
		"label": "Help elder carry load",
		"effects": {"respect": 2, "energy": -5, "naira": 500}
	}
	var applied = DialogueManager.apply_option_effects(dummy_opt)
	_assert_true(applied.get("respect", 0) == 2, "Applied +2 respect from dialogue option")
	_assert_true(GameState.resources.respect == initial_respect + 2, "GameState respect updated correctly")
	_assert_true(GameState.resources.energy == 95, "GameState energy deducted correctly (100 -> 95)")

func test_sound_manager_audio() -> void:
	_assert_true(SoundManager != null, "SoundManager singleton exists")
	_assert_true(SoundManager.streams.has("click"), "SFX click stream loaded")
	_assert_true(SoundManager.streams.has("cash"), "SFX cash stream loaded")
	_assert_true(SoundManager.streams.has("success"), "SFX success stream loaded")
	_assert_true(SoundManager.streams.has("fail"), "SFX fail stream loaded")
	_assert_true(SoundManager.streams.has("event"), "SFX event stream loaded")
	_assert_true(SoundManager.streams.has("bgm"), "BGM stream loaded")
