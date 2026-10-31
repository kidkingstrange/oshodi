extends Control

## MainMenu
## Main menu controller for Oshodimushin RPG.
## Handles navigation to Character Creation, Game Hub, and Settings.

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var info_dialog: AcceptDialog = %InfoDialog

func _ready() -> void:
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	if has_node("MarginContainer"):
		MobileManager.apply_safe_area_to_margin($MarginContainer, 64, 48)
	
	_update_menu_state()

func _update_menu_state() -> void:
	# Check if active character exists or any saved slot/autosave exists
	var can_continue = GameState.has_character() or SaveSystem.has_autosave() or SaveSystem.has_save(1) or SaveSystem.has_save(2) or SaveSystem.has_save(3)
	
	if continue_button:
		if can_continue:
			continue_button.visible = true
			if GameState.has_character():
				continue_button.text = "Continue Game (%s - Day %d)" % [GameState.player_name, GameState.day]
			else:
				continue_button.text = "Continue Saved Game"
		else:
			continue_button.visible = false

func _on_continue_pressed() -> void:
	if GameState.has_character():
		get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
	else:
		# Try loading autosave or first valid slot
		var loaded = false
		if SaveSystem.has_autosave():
			loaded = SaveSystem.load_autosave()
		if not loaded:
			for slot in range(1, 4):
				if SaveSystem.has_save(slot):
					loaded = SaveSystem.load_game(slot)
					if loaded:
						break
		if loaded:
			get_tree().change_scene_to_file("res://scenes/hub_screen.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_creation.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_screen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
