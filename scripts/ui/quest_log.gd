extends Control

## QuestLog
## UI Controller for inspecting active, available, and completed neighbourhood quests.

@onready var active_container: VBoxContainer = %ActiveContainer
@onready var available_container: VBoxContainer = %AvailableContainer
@onready var completed_container: VBoxContainer = %CompletedContainer
@onready var back_button: Button = %BackButton
@onready var notice_dialog: AcceptDialog = %NoticeDialog

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	_render_quest_lists()

func _render_quest_lists() -> void:
	_clear_container(active_container)
	_clear_container(available_container)
	_clear_container(completed_container)
	
	# 1. Active Quests
	var active = QuestManager.get_active_quests()
	if active.is_empty():
		var lbl = Label.new()
		lbl.text = "No active quests. Talk to neighbourhood locals to take on tasks!"
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		active_container.add_child(lbl)
	else:
		for q in active:
			active_container.add_child(_create_active_quest_card(q))
	
	# 2. Available Quests
	var available = QuestManager.get_available_quests()
	if available.is_empty():
		var lbl = Label.new()
		lbl.text = "No new quests currently available."
		available_container.add_child(lbl)
	else:
		for q in available:
			available_container.add_child(_create_available_quest_card(q))
	
	# 3. Completed Quests
	var completed = QuestManager.get_completed_quests()
	if completed.is_empty():
		var lbl = Label.new()
		lbl.text = "No quests completed yet."
		completed_container.add_child(lbl)
	else:
		for q in completed:
			completed_container.add_child(_create_completed_quest_card(q))

func _clear_container(c: VBoxContainer) -> void:
	if not c:
		return
	for child in c.get_children():
		child.queue_free()

func _create_active_quest_card(q: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = q.get("title", "Quest").to_upper()
	title.add_theme_color_override("font_color", Color(0.85, 0.45, 0.05, 1))
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var desc = Label.new()
	desc.text = q.get("description", "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	var steps = q.get("steps", [])
	if not steps.is_empty():
		var step_lbl = Label.new()
		step_lbl.text = "Objective: " + steps[0].get("text", "")
		step_lbl.add_theme_color_override("font_color", Color(0.2, 0.3, 0.6, 1))
		vbox.add_child(step_lbl)
	
	var is_ready = q.get("is_ready_to_claim", false)
	if is_ready:
		var claim_btn = Button.new()
		claim_btn.text = "Claim Quest Reward"
		claim_btn.custom_minimum_size = Vector2(0, 44)
		claim_btn.pressed.connect(_on_claim_reward_pressed.bind(q.get("id", "")))
		vbox.add_child(claim_btn)
	else:
		var pending_lbl = Label.new()
		pending_lbl.text = "Status: In Progress"
		pending_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		vbox.add_child(pending_lbl)
	
	return card

func _create_available_quest_card(q: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = q.get("title", "Available Quest")
	title.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title)
	
	var desc = Label.new()
	desc.text = q.get("description", "")
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc)
	
	var accept_btn = Button.new()
	accept_btn.text = "Accept Quest"
	accept_btn.custom_minimum_size = Vector2(0, 42)
	accept_btn.pressed.connect(_on_accept_quest_pressed.bind(q.get("id", "")))
	vbox.add_child(accept_btn)
	
	return card

func _create_completed_quest_card(q: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	margin.add_child(hbox)
	
	var title = Label.new()
	title.text = "[Done] " + q.get("title", "")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color(0.2, 0.5, 0.2, 1))
	hbox.add_child(title)
	
	return card

func _on_accept_quest_pressed(quest_id: String) -> void:
	SoundManager.play_click()
	QuestManager.start_quest(quest_id)
	_render_quest_lists()

func _on_claim_reward_pressed(quest_id: String) -> void:
	var res = QuestManager.complete_quest(quest_id)
	if not res.is_empty():
		SoundManager.play_success()
		if notice_dialog:
			notice_dialog.dialog_text = "Quest Completed: %s!\nRewards: +%d XP, +%d Respect, %s" % [
				res.get("title", ""),
				res.get("xp", 0),
				res.get("respect", 0),
				GameState.format_naira(res.get("naira", 0))
			]
			notice_dialog.popup_centered()
		_render_quest_lists()

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
