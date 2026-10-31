extends Control

## SettingsScreen
## Manages audio volume, text size accessibility, motion toggles, language,
## and 3 save/load slots with metadata inspection and autosave recovery.

@onready var sfx_slider: HSlider = %SfxSlider
@onready var sfx_value_label: Label = %SfxValueLabel
@onready var music_slider: HSlider = %MusicSlider
@onready var music_value_label: Label = %MusicValueLabel
@onready var text_size_option: OptionButton = %TextSizeOption
@onready var reduce_motion_check: CheckBox = %ReduceMotionCheck
@onready var language_option: OptionButton = %LanguageOption

# Save Slot Nodes
@onready var slot1_card: PanelContainer = %Slot1Card
@onready var slot1_info: Label = %Slot1Info
@onready var slot1_save_btn: Button = %Slot1SaveBtn
@onready var slot1_load_btn: Button = %Slot1LoadBtn
@onready var slot1_del_btn: Button = %Slot1DelBtn

@onready var slot2_card: PanelContainer = %Slot2Card
@onready var slot2_info: Label = %Slot2Info
@onready var slot2_save_btn: Button = %Slot2SaveBtn
@onready var slot2_load_btn: Button = %Slot2LoadBtn
@onready var slot2_del_btn: Button = %Slot2DelBtn

@onready var slot3_card: PanelContainer = %Slot3Card
@onready var slot3_info: Label = %Slot3Info
@onready var slot3_save_btn: Button = %Slot3SaveBtn
@onready var slot3_load_btn: Button = %Slot3LoadBtn
@onready var slot3_del_btn: Button = %Slot3DelBtn

@onready var back_button: Button = %BackButton
@onready var notice_dialog: AcceptDialog = %NoticeDialog
@onready var confirm_dialog: ConfirmationDialog = %ConfirmDialog

var pending_action: Callable

func _ready() -> void:
	sfx_slider.value_changed.connect(_on_sfx_changed)
	music_slider.value_changed.connect(_on_music_changed)
	text_size_option.item_selected.connect(_on_text_size_changed)
	reduce_motion_check.toggled.connect(_on_reduce_motion_toggled)
	language_option.item_selected.connect(_on_language_changed)
	
	back_button.pressed.connect(_on_back_pressed)
	confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)
	
	if has_node("MarginContainer"):
		MobileManager.apply_safe_area_to_margin($MarginContainer, 24, 24)
	
	_wire_slot_buttons(1, slot1_save_btn, slot1_load_btn, slot1_del_btn)
	_wire_slot_buttons(2, slot2_save_btn, slot2_load_btn, slot2_del_btn)
	_wire_slot_buttons(3, slot3_save_btn, slot3_load_btn, slot3_del_btn)
	
	_load_current_settings_ui()
	_refresh_all_slots()

func _wire_slot_buttons(slot: int, save_btn: Button, load_btn: Button, del_btn: Button) -> void:
	save_btn.pressed.connect(func(): _on_save_slot_pressed(slot))
	load_btn.pressed.connect(func(): _on_load_slot_pressed(slot))
	del_btn.pressed.connect(func(): _on_del_slot_pressed(slot))

func _load_current_settings_ui() -> void:
	var s = SaveSystem.settings
	sfx_slider.value = float(s.get("sfx_volume", 0.8)) * 100.0
	sfx_value_label.text = "%d%%" % int(sfx_slider.value)
	
	music_slider.value = float(s.get("music_volume", 0.8)) * 100.0
	music_value_label.text = "%d%%" % int(music_slider.value)
	
	var ts = s.get("text_size", "standard")
	match ts:
		"large":
			text_size_option.selected = 1
		"extra_large":
			text_size_option.selected = 2
		_:
			text_size_option.selected = 0
	
	reduce_motion_check.button_pressed = bool(s.get("reduce_motion", false))
	
	var lang = s.get("language", "en")
	language_option.selected = 1 if lang == "pidgin" else 0

func _on_sfx_changed(val: float) -> void:
	sfx_value_label.text = "%d%%" % int(val)
	SaveSystem.save_settings({ "sfx_volume": val / 100.0 })

func _on_music_changed(val: float) -> void:
	music_value_label.text = "%d%%" % int(val)
	SaveSystem.save_settings({ "music_volume": val / 100.0 })

func _on_text_size_changed(idx: int) -> void:
	var val = "standard"
	if idx == 1:
		val = "large"
	elif idx == 2:
		val = "extra_large"
	SaveSystem.save_settings({ "text_size": val })

func _on_reduce_motion_toggled(pressed: bool) -> void:
	SaveSystem.save_settings({ "reduce_motion": pressed })

func _on_language_changed(idx: int) -> void:
	var lang = "pidgin" if idx == 1 else "en"
	SaveSystem.save_settings({ "language": lang })

func _refresh_all_slots() -> void:
	_refresh_slot_display(1, slot1_info, slot1_save_btn, slot1_load_btn, slot1_del_btn)
	_refresh_slot_display(2, slot2_info, slot2_save_btn, slot2_load_btn, slot2_del_btn)
	_refresh_slot_display(3, slot3_info, slot3_save_btn, slot3_load_btn, slot3_del_btn)

func _refresh_slot_display(slot: int, info_lbl: Label, save_btn: Button, load_btn: Button, del_btn: Button) -> void:
	var meta = SaveSystem.get_slot_metadata(slot)
	var has_char = GameState.has_character()
	save_btn.disabled = not has_char
	
	if meta.get("is_empty", true):
		info_lbl.text = "Slot %d: Empty Slot\nNo saved character." % slot
		info_lbl.theme_override_colors.font_color = Color(0.45, 0.48, 0.52, 1)
		load_btn.disabled = true
		del_btn.disabled = true
	else:
		var p_name = meta.get("player_name", "Ayo")
		var c_id = meta.get("class_id", "trader").capitalize()
		var lvl = meta.get("level", 1)
		var day_num = meta.get("day", 1)
		var tb = meta.get("time_block", "morning").capitalize()
		var cash = GameState.format_naira(int(meta.get("naira", 0)))
		var ts = meta.get("timestamp", "").replace("T", " ")
		
		info_lbl.text = "Slot %d: %s (Level %d %s)\nDay %d (%s) • Cash: %s • Saved: %s" % [
			slot, p_name, lvl, c_id, day_num, tb, cash, ts
		]
		info_lbl.theme_override_colors.font_color = Color(0.12, 0.14, 0.18, 1)
		load_btn.disabled = false
		del_btn.disabled = false

func _on_save_slot_pressed(slot: int) -> void:
	if not GameState.has_character():
		_show_notice("No active game to save. Start a character first.")
		return
	
	if SaveSystem.has_save(slot):
		pending_action = func():
			SaveSystem.save_game(slot)
			_refresh_all_slots()
			_show_notice("Game saved successfully to Slot %d." % slot)
		confirm_dialog.dialog_text = "Overwrite Slot %d? Existing save data will be replaced." % slot
		confirm_dialog.popup_centered()
	else:
		SaveSystem.save_game(slot)
		_refresh_all_slots()
		_show_notice("Game saved successfully to Slot %d." % slot)

func _on_load_slot_pressed(slot: int) -> void:
	pending_action = func():
		var success = SaveSystem.load_game(slot)
		if success:
			get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
		else:
			_show_notice("Failed to load save from Slot %d." % slot)
	
	confirm_dialog.dialog_text = "Load save from Slot %d? Any unsaved progress in your current session will be lost." % slot
	confirm_dialog.popup_centered()
	MobileManager.push_modal(confirm_dialog)

func _on_del_slot_pressed(slot: int) -> void:
	pending_action = func():
		SaveSystem.delete_save(slot)
		_refresh_all_slots()
		_show_notice("Slot %d save file deleted." % slot)
	
	confirm_dialog.dialog_text = "Are you sure you want to permanently delete Slot %d save?" % slot
	confirm_dialog.popup_centered()
	MobileManager.push_modal(confirm_dialog)

func _on_confirm_dialog_confirmed() -> void:
	if pending_action.is_valid():
		pending_action.call()

func _show_notice(msg: String) -> void:
	notice_dialog.dialog_text = msg
	notice_dialog.popup_centered()
	MobileManager.push_modal(notice_dialog)

func _on_back_pressed() -> void:
	if GameState.has_character():
		get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
