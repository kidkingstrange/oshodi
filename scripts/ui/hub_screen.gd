extends Control

## HubScreen
## Primary game hub representing the world, location, time cycle, resources,
## activity choices (Work, Rest, Travel, Socialise), and street event resolution.

const TimeManager = preload("res://scripts/core/time_manager.gd")
const EventManager = preload("res://scripts/core/event_manager.gd")
const ActivityManager = preload("res://scripts/core/activity_manager.gd")
const Levelling = preload("res://scripts/core/levelling.gd")

# Header Nodes
@onready var day_label: Label = %DayLabel
@onready var time_badge_label: Label = %TimeBadgeLabel
@onready var location_title_label: Label = %LocationTitleLabel
@onready var level_badge_label: Label = %LevelBadgeLabel

# Resource Nodes
@onready var naira_label: Label = %NairaLabel
@onready var energy_label: Label = %EnergyLabel
@onready var respect_label: Label = %RespectLabel
@onready var heat_label: Label = %HeatLabel

# Content Cards
@onready var location_desc_label: Label = %LocationDescLabel
@onready var street_news_label: Label = %StreetNewsLabel
@onready var feed_label: Label = %FeedLabel

# Action Buttons
@onready var work_button: Button = %WorkButton
@onready var rest_button: Button = %RestButton
@onready var travel_button: Button = %TravelButton
@onready var socialise_button: Button = %SocialiseButton
@onready var situation_button: Button = %SituationButton
@onready var talk_button: Button = %TalkButton
@onready var quest_button: Button = %QuestButton
@onready var shop_button: Button = %ShopButton
@onready var subclass_button: Button = %SubclassButton
@onready var stats_button: Button = %StatsButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton

# Dialogs
@onready var travel_dialog: ConfirmationDialog = %TravelDialog
@onready var travel_options_list: ItemList = %TravelOptionsList
@onready var event_dialog: AcceptDialog = %EventDialog
@onready var morning_dialog: AcceptDialog = %MorningDialog
@onready var npc_dialog: ConfirmationDialog = %NpcDialog
@onready var npc_list: ItemList = %NpcList

var current_connected_routes: Array[Dictionary] = []
var current_local_npcs: Array[Dictionary] = []
var activity_feed_history: Array[String] = []

func _ready() -> void:
	work_button.pressed.connect(_on_work_pressed)
	rest_button.pressed.connect(_on_rest_pressed)
	travel_button.pressed.connect(_on_travel_pressed)
	socialise_button.pressed.connect(_on_socialise_pressed)
	situation_button.pressed.connect(_on_situation_pressed)
	if talk_button:
		talk_button.pressed.connect(_on_talk_pressed)
	if quest_button:
		quest_button.pressed.connect(_on_quest_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	subclass_button.pressed.connect(_on_subclass_pressed)
	stats_button.pressed.connect(_on_stats_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	travel_dialog.confirmed.connect(_on_travel_confirmed)
	if npc_dialog:
		npc_dialog.confirmed.connect(_on_npc_dialog_confirmed)
	
	GameState.resources_changed.connect(_on_resources_changed)
	GameState.time_advanced.connect(_on_time_advanced)
	
	# Initial default news
	street_news_label.text = "Morning Street News: " + DataLoader.get_random_morning_news()
	
	_add_feed_entry("Welcome to Oshodi! Pick an activity to begin your daily hustle.")
	_refresh_display()

func _refresh_display() -> void:
	var loc_data = DataLoader.get_location_by_id(GameState.location_id)
	
	day_label.text = "Day %d" % GameState.day
	time_badge_label.text = TimeManager.get_time_block_display_name(GameState.time_block)
	location_title_label.text = loc_data.get("name", "Oshodi").to_upper()
	location_desc_label.text = loc_data.get("description", "")
	
	# Update Resources
	naira_label.text = GameState.format_naira(GameState.resources.naira)
	energy_label.text = "%d / %d" % [GameState.resources.energy, GameState.resources.max_energy]
	respect_label.text = str(GameState.resources.respect)
	heat_label.text = str(GameState.resources.heat)
	
	# Dynamic button labels with preview info
	var class_info = GameState.get_class_data().get("name", "Hustler")
	var sc_info = GameState.get_subclass_data().get("name", "")
	var role_title = ("%s (%s)" % [class_info, sc_info]) if not sc_info.is_empty() else class_info
	var xp_to_next = Levelling.xp_to_next_level()
	level_badge_label.text = "Level %d %s • XP: %d (Next: %d XP)" % [
		GameState.level, role_title, GameState.xp, xp_to_next
	]
	
	subclass_button.visible = (GameState.level >= 5 and GameState.subclass_id.is_empty())
	
	if GameState.class_id == "transporter":
		var fuel = int(GameState.flags.get("fuel", 50))
		work_button.text = "Drive Route (Fuel: %dL, -20 Energy)" % fuel
	elif GameState.class_id == "trader":
		work_button.text = "Trade & Stock Market (-20 Energy)"
	elif GameState.class_id == "area_boy":
		work_button.text = "Control Turf & Dues (-20 Energy)"
	elif GameState.class_id == "working_class":
		var energy_cost = 16 if GameState.has_perk("steady_hands") else 20
		work_button.text = "Work Shift (+%s, -%d Energy)" % [GameState.format_naira(3500), energy_cost]
	else:
		var income = DataLoader.get_work_income(GameState.class_id)
		work_button.text = "Work Shift (+%s, -20 Energy)" % GameState.format_naira(income)
	
	# Low energy alert
	if GameState.resources.energy < 15:
		energy_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 1))
	else:
		energy_label.add_theme_color_override("font_color", Color(0.85, 0.45, 0.05, 1))

func _on_resources_changed(_res: Dictionary) -> void:
	_refresh_display()

func _on_time_advanced(_day: int, _time_block: String) -> void:
	_refresh_display()

func _add_feed_entry(entry: String) -> void:
	var timestamp = "[%s]" % GameState.time_block.capitalize()
	activity_feed_history.push_front("%s %s" % [timestamp, entry])
	if activity_feed_history.size() > 8:
		activity_feed_history.resize(8)
	feed_label.text = "\n\n".join(activity_feed_history)

func _on_work_pressed() -> void:
	SoundManager.play_click()
	var res = ActivityManager.perform_work()
	if not res.get("success", false):
		SoundManager.play_fail()
		_show_notice(res.get("message", "Cannot work."))
		return
	
	SoundManager.play_cash()
	_add_feed_entry(res.get("message", ""))
	_process_activity_outcome(res)

func _on_rest_pressed() -> void:
	SoundManager.play_click()
	var res = ActivityManager.perform_rest()
	_add_feed_entry(res.get("message", ""))
	_process_activity_outcome(res)

func _on_socialise_pressed() -> void:
	SoundManager.play_click()
	var res = ActivityManager.perform_socialise()
	if not res.get("success", false):
		SoundManager.play_fail()
		_show_notice(res.get("message", "Cannot socialise."))
		return
	
	SoundManager.play_cash()
	_add_feed_entry(res.get("message", ""))
	_process_activity_outcome(res)

func _on_travel_pressed() -> void:
	var loc_data = DataLoader.get_location_by_id(GameState.location_id)
	current_connected_routes = loc_data.get("travel", [])
	
	travel_options_list.clear()
	for idx in range(current_connected_routes.size()):
		var r = current_connected_routes[idx]
		var dest_name = r.get("name", r.get("to", "").capitalize())
		var fare = int(r.get("cost_naira", 200))
		travel_options_list.add_item("%s — Fare: %s" % [dest_name, GameState.format_naira(fare)], null, true)
	
	if current_connected_routes.is_empty():
		_show_notice("No travel routes available from here.")
		return
	
	travel_options_list.select(0)
	travel_dialog.popup_centered()

func _on_travel_confirmed() -> void:
	var selected_items = travel_options_list.get_selected_items()
	if selected_items.is_empty():
		return
	var selected_idx = selected_items[0]
	if selected_idx < 0 or selected_idx >= current_connected_routes.size():
		return
	
	var route = current_connected_routes[selected_idx]
	var dest_id = route.get("to", "")
	var res = ActivityManager.perform_travel(dest_id)
	if not res.get("success", false):
		_show_notice(res.get("message", "Travel failed."))
		return
	
	_add_feed_entry(res.get("message", ""))
	_process_activity_outcome(res)

func _process_activity_outcome(res: Dictionary) -> void:
	_refresh_display()
	
	# Check for overnight rollover
	var time_report = res.get("time_report", {})
	if time_report.get("is_new_day", false):
		var news = time_report.get("morning_news", "")
		street_news_label.text = "Morning Street News: " + news
		
		var summary = "Night has passed. Day %d begins!\n\n" % time_report.get("new_day", 1)
		summary += "• Daily Food Expense: %s paid\n" % GameState.format_naira(time_report.get("food_cost_paid", 1500))
		if time_report.get("hunger_penalty", false):
			summary += "• WARNING: You couldn't afford a full dinner! Suffered -10 Energy.\n"
		else:
			summary += "• Good night's rest restored +20 Energy.\n"
		summary += "\nStreet News: \"%s\"" % news
		
		morning_dialog.dialog_text = summary
		morning_dialog.popup_centered()
		return
	
	# Check for triggered random event
	var event_result = res.get("event_result", {})
	if event_result.get("triggered", false):
		var ev = event_result.get("event", {})
		var eff = event_result.get("effects", {})
		var ev_msg = eff.get("message", "")
		
		_add_feed_entry("EVENT: %s — %s" % [ev.get("title", ""), ev_msg])
		
		event_dialog.title = "Street Event: " + ev.get("title", "Notice")
		event_dialog.dialog_text = "%s\n\nOutcome: %s" % [ev.get("description", ""), ev_msg]
		event_dialog.popup_centered()
	else:
		# If no daily event occurred, 25% chance of encountering an active street situation
		var sit_check = ActivityManager.maybe_trigger_situation(0.25)
		if sit_check.get("triggered", false):
			var sit = sit_check.get("situation", {})
			GameState.flags["active_situation_id"] = sit.get("id", "")
			get_tree().change_scene_to_file("res://scenes/situation_screen.tscn")

func _on_situation_pressed() -> void:
	var eligible = DataLoader.get_eligible_situations(GameState.class_id, GameState.location_id, GameState.time_block)
	if eligible.is_empty():
		eligible = DataLoader.get_all_situations()
	if eligible.is_empty():
		_show_notice("No street situations available right now.")
		return
	var sit = eligible[randi() % eligible.size()]
	GameState.flags["active_situation_id"] = sit.get("id", "")
	get_tree().change_scene_to_file("res://scenes/situation_screen.tscn")

func _on_stats_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/stats_screen.tscn")

func _on_shop_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/shop_screen.tscn")

func _on_subclass_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/subclass_select.tscn")

func _on_settings_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")

func _on_menu_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quest_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/quest_log.tscn")

func _on_talk_pressed() -> void:
	SoundManager.play_click()
	current_local_npcs = DataLoader.get_npcs_for_location(GameState.location_id)
	if current_local_npcs.is_empty():
		current_local_npcs = DataLoader.get_all_npcs()
	
	if current_local_npcs.is_empty():
		_show_notice("No locals are around right now.")
		return
	
	if current_local_npcs.size() == 1:
		_open_npc_dialogue(current_local_npcs[0].get("id", ""))
		return
	
	if npc_list:
		npc_list.clear()
		for n in current_local_npcs:
			var label = "%s — %s" % [n.get("name", "Local"), n.get("role", "Resident")]
			npc_list.add_item(label)
		if npc_dialog:
			npc_dialog.popup_centered()

func _on_npc_dialog_confirmed() -> void:
	var selected = npc_list.get_selected_items()
	if selected.is_empty():
		if npc_list.item_count > 0:
			var n = current_local_npcs[0]
			_open_npc_dialogue(n.get("id", ""))
		return
	var idx = selected[0]
	if idx >= 0 and idx < current_local_npcs.size():
		var n = current_local_npcs[idx]
		_open_npc_dialogue(n.get("id", ""))

func _open_npc_dialogue(npc_id: String) -> void:
	var dia_scene = load("res://scenes/dialogue_overlay.tscn")
	if dia_scene:
		var instance = dia_scene.instantiate()
		add_child(instance)
		instance.start_conversation(npc_id)
		instance.dialogue_finished.connect(_on_dialogue_closed)

func _on_dialogue_closed() -> void:
	_refresh_display()

func _show_notice(msg: String) -> void:
	event_dialog.title = "Action Notice"
	event_dialog.dialog_text = msg
	event_dialog.popup_centered()
